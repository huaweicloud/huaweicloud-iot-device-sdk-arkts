export interface PropertiesData {
  /**
   * 设备服务的属性列表，具体字段在产品模型中定义
   */
  properties: object;

  /**
   * 设备属性UTC时间，格式：yyyyMMddTHHmmssZ
   */
  event_time?: string;
}