import { PropertiesData } from "./PropertiesData";

export interface ShadowData {
  /**
   * 服务id，和设备模型里一致
   */
  service_id: string;

  /**
   * 设备影子desired区的属性列表
   */
  desired?: PropertiesData;

  /**
   * 设备影子reported区的属性列表
   */
  reported?: PropertiesData;

  /**
   * 设备影子版本信息
   */
  version?: number;
}