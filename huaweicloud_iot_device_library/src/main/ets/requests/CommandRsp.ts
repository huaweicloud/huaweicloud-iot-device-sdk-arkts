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