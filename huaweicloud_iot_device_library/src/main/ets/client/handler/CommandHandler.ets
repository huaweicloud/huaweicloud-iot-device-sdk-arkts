import { Command } from "../../requests/Command";
import { RawMessage } from "../../requests/RawMessage";
import { IoTUtil } from "../../utils/IoTUtil";
import { LogUtil } from "../../utils/LogUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";

export class CommandHandler implements MessageReceivedHandler {
  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }


  messageHandler(message: RawMessage): void {
    const requestId = IoTUtil.getRequestId(message.topic);

    try {
      const command: Command = JSON.parse(message.payload);
      const commandListener = this.deviceClient.commandListener;
      if (commandListener !== null
        && (command.object_device_id == null || command.object_device_id === this.deviceClient.device.deviceId)) {
        commandListener.onCommand(requestId, command.service_id, command.command_name, command.paras);
        return;
      }

      this.deviceClient.device.onCommand(requestId, command);
    } catch (e) {
      LogUtil.error("invalid command");
      return;
    }

  }
}