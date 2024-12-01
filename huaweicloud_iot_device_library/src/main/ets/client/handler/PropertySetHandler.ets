import { PropsSet } from "../../requests/PropsSet";
import { RawMessage } from "../../requests/RawMessage";
import { IoTUtil } from "../../utils/IoTUtil";
import { LogUtil } from "../../utils/LogUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";


export class PropertySetHandler implements MessageReceivedHandler {
  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {
    const requestId = IoTUtil.getRequestId(message.topic);
    try {
      const propsSet: PropsSet = JSON.parse(message.payload);
      const propertyListener = this.deviceClient.propertyListener;
      if (propertyListener !== null && (propsSet.object_device_id == null || propsSet.object_device_id
        === this.deviceClient.device.deviceId)) {
        propertyListener.onPropertiesSet(requestId, propsSet.services);
        return;
      }

      this.deviceClient.device.onPropertiesSet(requestId, propsSet);
    } catch (e) {
      LogUtil.error("invalid propsSet");
      return;
    }

  }
}