export class IotResult {

  static readonly SUCCESS = new IotResult(0, "Success");

  static readonly FAIL = new IotResult(1, "Fail");

  static readonly TIMEOUT = new IotResult(2, "Timeout");

  /**
   * 结果码，0表示成功，其他为失败
   */
  result_code: number;

  /**
   * 结果描述
   */
  result_desc: string;

  /**
   * 处理结果
   *
   * @param resultCode 结果码
   * @param resultDesc 结果描述
   */
  constructor(resultCode: number, resultDesc: string) {
    this.result_code = resultCode;
    this.result_desc = resultDesc;
  }
}