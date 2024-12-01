import { DeviceMessage } from "../../requests/DeviceMessage";
import { RawDeviceMessage } from "../../requests/RawDeviceMessage";
import { RawMessage } from "../../requests/RawMessage";
import { LogUtil } from "../../utils/LogUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";

export class MessageHandler implements MessageReceivedHandler {
  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {

    const rawDeviceMessage: RawDeviceMessage = { payload: message.payload };

    if (this.deviceClient.rawDeviceMessageListener !== null) {
      LogUtil.log(`receive message ${JSON.stringify(message)}`)
      this.deviceClient.rawDeviceMessageListener.onRawDeviceMessage(rawDeviceMessage);
    }

  }
}