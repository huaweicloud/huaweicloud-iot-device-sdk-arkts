import { ServiceProperty } from "./ServiceProperty";

/**
 * 写属性操作
 */
export interface PropsSet {
  /**
   * 设备ID，直连设备时不懈怠该参数
   */
  object_device_id?: string;

  /**
   * 设备服务数据列表
   */
  services: ServiceProperty[];

}