import { DeviceEvent } from "./DeviceEvent";

/**
 * 设备事件
 */
export interface DeviceEvents {
  /**
   * 设备id
   */
  object_device_id: string;

  /**
   * 服务事件列表
   */
  services: DeviceEvent[];
}