import { RawMessage } from "../../requests/RawMessage";

/**
 * 原始消息接收监听器
 */
export interface RawMessageListener {
  /**
   * 收到消息通知
   *
   * @param message 原始消息
   */
  onMessageReceived: (message: RawMessage) => void;
}