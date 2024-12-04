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

import { PropertiesData } from "./PropertiesData";

export interface ShadowData {
  /**
   * 服务id，和设备模型里一致
   */
  service_id: string;

  /**
   * 设备影子desired区的属性列表
   */
  desired?: PropertiesData;

  /**
   * 设备影子reported区的属性列表
   */
  reported?: PropertiesData;

  /**
   * 设备影子版本信息
   */
  version?: number;
}
