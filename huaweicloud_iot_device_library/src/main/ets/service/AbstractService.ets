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
import { AbstractDevice } from "./AbstractDevice";
import { IService } from "./IService";
import "reflect-metadata"
import { IoTUtil } from "../utils/IoTUtil";
import { LogUtil } from "../utils/LogUtil";

export interface Property {
  name: string;
  writeable: boolean;
}

export interface DeviceCommand {
  name: string;
  method: Function;
}

export abstract class AbstractService implements IService {
  private commands: Map<string, Function> = new Map();
  private writeableFields: Map<string, string> = new Map();
  private readableFields: Map<string, string> = new Map();
  private timer: number | null = null;
  private _serviceId: string | null = null;

  public set serviceId(value: string | null) {
    this._serviceId = value;
  }

  public get serviceId(): string | null {
    return this._serviceId;
  }

  private _iotDevice: AbstractDevice | null = null;

  public set iotDevice(value: AbstractDevice | null) {
    this._iotDevice = value;
  }

  public get iotDevice(): AbstractDevice | null {
    return this._iotDevice;
  }

  init(fields: string[]) {
    fields.forEach(field => {
      const property: Property = Reflect.getMetadata('Property', this, field);
      if (property) {
        let propertyName: string = property.name || field;
        if (property.writeable) {
          this.writeableFields.set(propertyName, field);
        }
        this.readableFields.set(field, propertyName);
        return;
      }
      const deviceCommand: DeviceCommand = Reflect.getMetadata("DeviceCommand", this, field);
      if (deviceCommand) {
        let commandName: string = deviceCommand.name || field;
        this.commands.set(commandName, deviceCommand.method);
      }

    })
    LogUtil.debug(`writeableFields is ${JSON.stringify(IoTUtil.mapToJson(this.writeableFields))}`);
    LogUtil.debug(`readableFields is ${JSON.stringify(IoTUtil.mapToJson(this.readableFields))}`);
    LogUtil.debug(`commands is ${JSON.stringify(IoTUtil.mapToJson(this.commands))}`);
  }


  /**
   * 开启自动周期上报属性
   *
   * @param reportInterval 上报周期，单位ms
   */
  public enableAutoReport(reportInterval: number): void {
    if (this.timer != null) {
      LogUtil.error("timer is already enabled");
      return;
    }

    this.timer = setInterval(() => {
      this.firePropertiesChanged()
    }, reportInterval)
  }


  /**
   * 关闭自动周期上报，您可以通过firePropertiesChanged触发上报
   */
  public disableAutoReport(): void {
    if (this.timer != null) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  /**
   * 通知服务属性变化
   *
   * @param properties 变化的属性，不指定默认读取全部可读属性
   */
  public firePropertiesChanged(properties?: string[]): void {
    if (this.iotDevice === null || this.serviceId === null) {
      return;
    }
    this.iotDevice.firePropertiesChanged(this.serviceId, properties);
  }

  /**
   * 读属性回调
   *
   * @param fields 指定读取的字段名，不指定则读取全部可读字段
   * @return 属性值
   */
  onRead(fields?: string[]): object {
    let result: Map<string, object> = new Map();
    // 读取指定字段
    if (fields && fields.length > 0) {
      fields.forEach(field => {
        const propertyName = this.readableFields.get(field);
        if (propertyName === null || propertyName === undefined) {
          LogUtil.log(`field is not readable ${field}`);
          return;
        }
        const value = this.getFieldValue(field);
        if (value !== null && value !== undefined) {
          result.set(propertyName, value);
        }
      })
      return IoTUtil.mapToJson(result);
    }

    // 读取全部字段
    this.readableFields.forEach((propertyName: string, field: string) => {
      const value = this.getFieldValue(field);
      if (value !== null && value !== undefined) {
        result.set(propertyName, value);
      }
    })
    return IoTUtil.mapToJson(result);
  }

  /**
   * 写属性。收到平台下发的写属性操作时此接口被自动调用。
   * 如果用户希望在写属性时增加额外处理，可以重写此接口
   *
   * @param properties 平台期望属性的值
   * @return 操作结果
   */
  onWrite(properties: object): IotResult {
    let changeProps: string[] = [];
    let result = IotResult.SUCCESS;
    Object.keys(properties).every((propertyName: string) => {
      const field = this.writeableFields.get(propertyName);
      if (field === null || field === undefined) {
        LogUtil.error(`field not found or not writeable ${propertyName}` );
        result = {
          result_code: -1,
          result_desc: `"field not found or not writeable ${propertyName}`,
        }
        return false;
      }
      let setMethodName = field;
      if (field.startsWith("_")) {
        setMethodName = field.substring(1, field.length);
      }
      Reflect.set(this, setMethodName, properties[propertyName]);
      changeProps.push(field);
      return true;
    })

    // 上报属性变化
    if (changeProps.length > 0) {
      this.firePropertiesChanged(changeProps);
    }
    return result;
  }

  onCommand(command: Command): CommandRsp {
    const method = this.commands.get(command.command_name);
    if (method === null || method === undefined) {
      return {
        result_code: -1,
        paras: "command not found"
      }
    }

    try {
      return method(command.paras) as CommandRsp
    } catch (e) {
      LogUtil.error(`call command failed ${JSON.stringify(e)}`)
      return {
        result_code: -1,
        paras: `call command failed ${JSON.stringify(e)}`
      }
    }
  }

  /**
   * 事件处理。收到平台下发的事件时此接口被自动调用。默认为空实现
   *
   * @param deviceEvent 服务事件
   */
  onEvent(deviceEvent: DeviceEvent): void {
    LogUtil.log("onEvent")
  }

  private getFieldValue(field: string): Object | null {
    const propertyName = this.readableFields.get(field);
    if (!propertyName) {
      LogUtil.log(`propertyName does not exist ${field}}`);
      return null;
    }
    let getMethodName = field;
    if (field.startsWith("_")) {
      getMethodName = field.substring(1, field.length);
    }
    return Reflect.get(this, getMethodName) as Object;
  }
}