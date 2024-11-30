import { RawMessage } from "../../requests/RawMessage";
import { Shadow } from "../../requests/Shadow";
import { IoTUtil } from "../../utils/IoTUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";


export class ShadowHandler implements MessageReceivedHandler {

  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {
    const requestId = IoTUtil.getRequestId(message.topic);
    try {
      const shadow: Shadow = JSON.parse(message.payload);
      const shadowListener = this.deviceClient.shadowListener;
      if (shadowListener !== null && (shadow.object_device_id == null || shadow.object_device_id
        === this.deviceClient.device.deviceId)) {
        shadowListener.onShadow(requestId, shadow.shadow);
        return;
      }

      this.deviceClient.device.onShadow(requestId, shadow);
    } catch (e) {
      console.error("invalid shadow");
      return;
    }

  }

}