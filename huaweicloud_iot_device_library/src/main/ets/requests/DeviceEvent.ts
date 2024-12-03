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
 * 服务的事件
 */
export interface DeviceEvent {
  /**
   * 事件所属服务id
   */
  service_id: string;

  /**
   * 事件类型
   */
  event_type: string;

  /**
   * 事件发生的事件
   */
  event_time: string;

  /**
   * 事件具体的参数
   */
  paras: object;

  /**
   * 事件具体的参数
   */
  event_id?: string;
}