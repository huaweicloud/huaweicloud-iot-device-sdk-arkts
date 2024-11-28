import { ServiceProperty } from "./ServiceProperty";

/**
 * 设备属性内容
 */
export interface DeviceProperties {
  /**
   * 服务属性列表
   */
  services: ServiceProperty[];
}