import { ShadowData } from "./ShadowData";

export interface Shadow {
  /**
   * 设备ID
   */
  object_device_id: string;

  /**
   * 设备影子数据
   */
  shadow?: ShadowData[];
}