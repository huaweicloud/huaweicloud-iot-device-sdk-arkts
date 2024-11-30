export interface ShadowRequest {
  /**
   * 设备ID
   */
  object_device_id?: string;

  /**
   * 服务ID，不携带时查询所有
   */
  service_id?: string;
}