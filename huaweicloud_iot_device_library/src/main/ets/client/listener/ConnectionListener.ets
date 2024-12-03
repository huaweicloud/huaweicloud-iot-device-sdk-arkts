/**
 * 连接监听器
 */
export interface ConnectListener {
  /**
   * 连接丢失通知
   *
   */
  connectionLost: () => void;

  /**
   * 连接成功通知
   */
  connectComplete: () => void;

}
