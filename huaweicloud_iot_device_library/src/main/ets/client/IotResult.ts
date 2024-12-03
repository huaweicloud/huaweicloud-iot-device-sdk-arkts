// Copyright 2024 Huawei Cloud IoT Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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