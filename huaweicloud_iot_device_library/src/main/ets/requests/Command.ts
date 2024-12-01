/**
 * 设备命令
 */
export interface Command {
  /**
   * 命令所属服务id
   */
  service_id: string;

  /**
   * 命令名称
   */
  command_name: string;

  /**
   * 设备ID
   */
  object_device_id: string;

  /**
   * 命令具体参数
   */
  paras: object;
}