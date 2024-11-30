/**
 * 命令响应
 */
export interface CommandRsp {

  /**
   * 结果码，0表示成功，其他表示失败。不带默认认为成功
   */
  result_code?: number;

  /**
   * 命令的响应名称，在设备关联的产品模型中定义。可选
   */
  response_name?: string;

  /**
   * 命令的响应参数，具体字段在设备关联的产品模型中定义。可选
   */
  paras?: Object;


}