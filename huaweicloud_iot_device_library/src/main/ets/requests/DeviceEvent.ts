/**
 * 服务的事件
 */
export interface DeviceEvent {
  /**
   * 事件所属服务id
   */
  service_id: string;

  /**
   * 事件类型
   */
  event_type: string;

  /**
   * 事件发生的事件
   */
  event_time: string;

  /**
   * 事件具体的参数
   */
  paras: object;

  /**
   * 事件具体的参数
   */
  event_id?: string;
}