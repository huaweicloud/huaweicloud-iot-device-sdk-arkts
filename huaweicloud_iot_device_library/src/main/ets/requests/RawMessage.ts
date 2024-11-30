export interface RawMessage {
  /**
   * topic主题
   */
  topic: string;

  /**
   * 服务质量 0或1
   */
  qos: number;

  /**
   * 原始数据
   */
  payload: string;
}