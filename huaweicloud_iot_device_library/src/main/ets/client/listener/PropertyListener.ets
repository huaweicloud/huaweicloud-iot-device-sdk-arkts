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
