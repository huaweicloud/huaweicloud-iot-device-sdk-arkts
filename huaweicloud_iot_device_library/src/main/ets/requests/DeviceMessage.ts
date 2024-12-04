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
 * 设备消息
 */
export interface DeviceMessage {
  /**
   * 设备id，可选，默认为客户端本身的设备id
   */
  object_device_id?: string;

  /**
   * 消息名，可选
   */
  name?: string;

  /**
   * 消息id，可选
   */
  id?: string;

  /**
   * 消息具体内容
   */
  content: string;
}
