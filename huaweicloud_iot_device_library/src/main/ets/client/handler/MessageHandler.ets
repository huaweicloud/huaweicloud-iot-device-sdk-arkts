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
      console.log("receive message in custom format ", message)
      this.deviceClient.rawDeviceMessageListener.onRawDeviceMessage(rawDeviceMessage);
    }

    try {
      // 处理系统格式消息
      const deviceMessage: DeviceMessage = JSON.parse(message.payload);
      const deviceMessageKeys = ["name", "id", "content", "object_device_id"];
      const keys = Object.keys(deviceMessage);
      const isSystemFormat = keys.every((value, index) => deviceMessageKeys.indexOf(value) > -1);
      console.log("deviceMessage is systemFormat ", isSystemFormat);

      if (isSystemFormat) {
        const isCurrentDevice: boolean = (deviceMessage.object_device_id === null
          || deviceMessage.object_device_id === this.deviceClient.device.deviceId);
        const deviceMessageListener = this.deviceClient.deviceMessageListener;
        if (deviceMessageListener !== null && isCurrentDevice) {
          deviceMessageListener.onDeviceMessage(deviceMessage);
          return
        }
        this.deviceClient.device.onDeviceMessage(deviceMessage);
      }

    } catch (e) {
      console.error("the message is not systemFormat")
    }

  }
}