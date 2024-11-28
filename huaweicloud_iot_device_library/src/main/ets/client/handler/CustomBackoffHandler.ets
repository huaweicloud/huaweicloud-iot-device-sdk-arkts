export interface CustomBackoffHandler {
  /**
   * 自定义断线重连
   * @return 0 代表重连成功， 其他代表重连失败
   */
  backoffHandler(): number;
}