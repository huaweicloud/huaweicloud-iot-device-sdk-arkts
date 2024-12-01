import { ServiceProperty } from "../../requests/ServiceProperty";

/**
 * 属性监听器，用于接收平台下发的属性读写操作
 */
export interface PropertyListener {

  /**
   * 处理写属性操作
   *
   * @param requestId 请求id
   * @param services  服务属性列表
   */
  onPropertiesSet: (requestId: string, services: ServiceProperty[]) => void;

  /**
   * 处理读属性操作
   *
   * @param requestId 请求id
   * @param serviceId 服务id，可选
   */
  onPropertiesGet: (requestId: string, serviceId?: string) => void;
}
