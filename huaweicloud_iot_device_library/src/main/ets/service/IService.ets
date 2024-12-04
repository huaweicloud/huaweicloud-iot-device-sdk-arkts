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

import { IotResult } from "../client/IotResult";
import { Command } from "../requests/Command";
import { CommandRsp } from "../requests/CommandRsp";
import { DeviceEvent } from "../requests/DeviceEvent";

/**
 * 服务接口类
 */
export interface IService {
  /**
   * 读属性回调
   *
   * @param fields 指定读取的字段名，不指定则读取全部可读字段
   * @return 属性值，json格式
   */
  onRead(fields?: string[]): object;

  /**
   * 写属性回调
   *
   * @param properties 属性期望值
   * @return 操作结果jsonObject
   */
  onWrite(properties: object): IotResult;

  /**
   * 命令回调
   *
   * @param command 命令
   * @return 执行结果
   */
  onCommand(command: Command): CommandRsp;

  /**
   * 事件回调
   *
   * @param deviceEvent 事件
   */
  onEvent(deviceEvent: DeviceEvent): void;
}

