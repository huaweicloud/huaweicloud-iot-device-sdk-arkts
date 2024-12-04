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

import { ShadowData } from "../../requests/ShadowData";

/**
 * 设备影子监听器，用于设备向平台获取设备影子数据
 */
export interface ShadowListener {
  /**
   *
   * @param requestId       请求id
   * @param shadowDataList  服务影子数据
   */
  onShadow: (requestId: string, shadowDataList?: ShadowData[]) => void;
}

