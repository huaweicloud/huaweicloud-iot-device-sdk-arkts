/**
 * 命令监听器，用于接收平台下发的命令
 */
export interface CommandListener {
  /**
   * 命令处理
   *
   * @param requestId   请求id
   * @param serviceId   服务id
   * @param commandName 命令名
   * @param paras       命令参数
   */
  onCommand: (requestId: string, serviceId: string, commandName: string, paras: object) => void;
}