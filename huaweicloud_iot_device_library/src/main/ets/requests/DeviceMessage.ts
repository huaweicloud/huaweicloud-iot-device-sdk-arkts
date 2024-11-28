/**
 * 设备消息
 */
export interface DeviceMessage {
  /**
   * 设备id，可选，默认为客户端本身的设备id
   */
  object_device_id?: string;

  /**
   * 消息名，可选
   */
  name?: string;

  /**
   * 消息id，可选
   */
  id?: string;

  /**
   * 消息具体内容
   */
  content: string;
}