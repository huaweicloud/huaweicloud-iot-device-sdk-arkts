/**
 * 连接监听器
 */
export interface ConnectListener {
  /**
   * 连接丢失通知
   *
   * @param cause 连接丢失原因
   */
  connectionLost: () => void;

}
