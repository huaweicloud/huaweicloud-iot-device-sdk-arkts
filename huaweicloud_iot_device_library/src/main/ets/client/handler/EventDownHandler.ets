import { DeviceEvents } from "../../requests/DeviceEvents";
import { RawMessage } from "../../requests/RawMessage";
import { LogUtil } from "../../utils/LogUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";

export class EventDownHandler implements MessageReceivedHandler {
  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {
    const topic = message.topic;
    if (!topic) {
      LogUtil.error("topic is empty");
      return;
    }
    try {
      const deviceEvents: DeviceEvents = JSON.parse(message.payload);
      this.deviceClient.device.onEvent(deviceEvents);
    } catch (e) {
      LogUtil.error("invalid deviceEvent");
      return;
    }
  }
}
