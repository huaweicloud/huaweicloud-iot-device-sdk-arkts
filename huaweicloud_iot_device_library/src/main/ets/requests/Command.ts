/**
 * 设备命令
 */
export interface Command {
  service_id: string;

  command_name: string;

  object_device_id: string;

  paras: object;
}