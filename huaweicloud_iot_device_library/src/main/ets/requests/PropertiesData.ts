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
