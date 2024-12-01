import { RawMessage } from "../../requests/RawMessage";

export interface MessageReceivedHandler {
  messageHandler(message: RawMessage): void;
}