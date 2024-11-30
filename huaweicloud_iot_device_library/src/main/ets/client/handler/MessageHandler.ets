import { DeviceMessage } from "../../requests/DeviceMessage";
import { RawDeviceMessage } from "../../requests/RawDeviceMessage";
import { RawMessage } from "../../requests/RawMessage";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";

export class MessageHandler implements MessageReceivedHandler {

  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {

    const rawDeviceMessage: RawDeviceMessage = {payload: message.payload};

    if (this.deviceClient.rawDeviceMessageListener !== null) {
      console.log("receive message ", message)
      this.deviceClient.rawDeviceMessageListener.onRawDeviceMessage(rawDeviceMessage);
    }

  }
}