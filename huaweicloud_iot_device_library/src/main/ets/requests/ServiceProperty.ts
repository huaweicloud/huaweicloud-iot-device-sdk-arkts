/**
 * 服务的属性
 */
export interface ServiceProperty {
  /**
   * 服务id，和设备模型里一致
   */
  service_id: string

  /**
   * 属性值，具体字段由设备模型定义
   */
  properties: object;

  /**
   * 属性变化的时间，格式：yyyyMMddTHHmmssZ，可选，不带以平台收到的时间为准
   */
  event_time?: string;
}