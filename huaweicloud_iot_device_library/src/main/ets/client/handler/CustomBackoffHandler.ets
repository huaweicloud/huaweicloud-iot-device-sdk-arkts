export interface CustomBackoffHandler {
  /**
   * 自定义断线重连
   * @return true 代表重连成功， false代表重连失败
   */
  backoffHandler: () => Promise<boolean>;
}