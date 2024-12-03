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

import { ClientConf } from "../client/ClinetConf";
import { DeviceClient } from "../client/DeviceClient";
import { IoTMqttResponse } from "../client/IoTMqttResponse";
import { IotResult } from "../client/IotResult";
import { Command } from "../requests/Command";
import { DeviceEvents } from "../requests/DeviceEvents";
import { DeviceMessage } from "../requests/DeviceMessage";
import { PropsGet } from "../requests/PropsGet";
import { PropsSet } from "../requests/PropsSet";
import { ServiceProperty } from "../requests/ServiceProperty";
import { Shadow } from "../requests/Shadow";
import { IoTUtil } from "../utils/IoTUtil";
import { LogUtil } from "../utils/LogUtil";
import { AbstractService } from "./AbstractService";

export class AbstractDevice {
  private _client: DeviceClient;

  public set client(value: DeviceClient) {
    this._client = value;
  }

  public get client(): DeviceClient {
    return this._client;
  }

  private _deviceId: string;

  public set deviceId(value: string) {
    this._deviceId = value;
  }

  public get deviceId(): string {
    return this._deviceId;
  }

  private _services: Map<string, AbstractService> = new Map();

  public set services(value: Map<string, AbstractService>) {
    this._services = value;
  }

  public get services(): Map<string, AbstractService> {
    return this._services;
  }

  constructor(serverUri: string, deviceId: string, deviceSecret: string, caFilePath?: string) {
    this._deviceId = deviceId;
    const clientConf: ClientConf = {
      deviceId: deviceId,
      secret: deviceSecret,
      serverUri: serverUri,
      caFilePath: caFilePath
    }
    this._client = new DeviceClient(clientConf, this);
  }

  init() {
    return this.client.connect();
  }

  /**
   * 添加服务。用户基于AbstractService定义自己的设备服务，并添加到设备
   *
   * @param serviceId     服务id，要和设备模型定义一致
   * @param deviceService 服务实例
   */
  public addService(serviceId: string, deviceService: AbstractService): void {

    deviceService.iotDevice = this;
    deviceService.serviceId = serviceId;
    if (!this.services.has(serviceId)) {
      this.services.set(serviceId, deviceService)
    }
  }

  /**
   * 删除服务
   *
   * @param serviceId 服务id
   */
  public delService(serviceId: string): void {
    this.services.delete(serviceId);
  }

  /**
   * 查询服务
   *
   * @param serviceId 服务id
   * @return AbstractService 服务实例
   */
  public getService(serviceId: string): AbstractService | undefined {
    return this.services.get(serviceId);
  }

  /**
   * 命令回调函数，由SDK自动调用
   *
   * @param requestId 请求id
   * @param command   命令
   */
  public onCommand(requestId: string, command: Command): void {

    const service = this.getService(command.service_id);

    if (service !== null && service !== undefined) {
      const rsp = service.onCommand(command);
      this.client.respondCommand(requestId, rsp);
      return;
    }
    this.client?.respondCommand(requestId, { result_code: -1, paras: `service not found ${command.service_id}` })
  }

  /**
   * 属性设置回调，，由SDK自动调用
   *
   * @param requestId 请求id
   * @param propsSet  属性设置请求
   */
  public onPropertiesSet(requestId: string, propsSet: PropsSet): void {
    let ret = IotResult.SUCCESS;
    propsSet.services.every((serviceProp) => {
      const deviceService = this.getService(serviceProp.service_id);

      if (deviceService !== null && deviceService !== undefined) {
        // 如果部分失败直接返回
        const result = deviceService.onWrite(serviceProp.properties);
        if (result.result_code != IotResult.SUCCESS.result_code) {
          ret = result;
          return false;
        }
      }
      return true;
    })

    this.client.respondPropsSet(requestId, ret);

  }

  /**
   * 属性查询回调，由SDK自动调用
   *
   * @param requestId 请求id
   * @param propsGet  属性查询请求
   */
  public onPropertiesGet(requestId: string, propsGet: PropsGet): void {
    let serviceProperties: ServiceProperty[] = [];

    // 查询所有
    if (propsGet.service_id === null || propsGet.service_id === undefined) {
      this.services.forEach((service: AbstractService, serviceId: string) => {
        const deviceService = this.getService(serviceId);
        if (deviceService !== null && deviceService !== undefined) {
          const properties = deviceService.onRead();
          const serviceProperty: ServiceProperty = {
            service_id: serviceId,
            properties: properties
          }
          serviceProperties.push(serviceProperty);
        }
      })

    } else {
      const deviceService = this.getService(propsGet.service_id);
      if (deviceService !== null && deviceService !== undefined) {
        const properties = deviceService.onRead();
        const serviceProperty: ServiceProperty = {
          service_id: propsGet.service_id,
          properties: properties
        }
        serviceProperties.push(serviceProperty);
      }
    }

    this.client.respondPropsGet(requestId, serviceProperties);

  }

  /**
   * 事件回调，由SDK自动调用
   *
   * @param deviceEvents 设备事件
   */
  public onEvent(deviceEvents: DeviceEvents): void {

  }


  /**
   * 消息回调，由SDK自动调用
   *
   * @param message 消息
   */
  public onDeviceMessage(message: DeviceMessage): void {

  }

  /**
   * 影子回调函数，由SDK自动调用
   *
   * @param requestId 请求id
   * @param shadow   影子
   */
  public onShadow(requestId: string, shadow: Shadow): void {

  }

  /**
   * 触发属性变化，SDK会上报变化的属性
   *
   * @param serviceId  服务id
   * @param properties 属性列表
   */
  public firePropertiesChanged(serviceId: string, properties?: string[]): void {
    const deviceService = this.getService(serviceId);
    if (deviceService === null || deviceService === undefined || deviceService.serviceId === null) {
      return;
    }
    const props = deviceService.onRead(properties);
    const serviceProperty: ServiceProperty = {
      service_id: deviceService.serviceId,
      properties: props,
      event_time: IoTUtil.getEventTimestamp(),
    }
    this.client.reportProperties([serviceProperty]).then((data: IoTMqttResponse) => {
      LogUtil.debug(`report properties success ${JSON.stringify(data)}`)
    }).catch((err: IoTMqttResponse | string) => {
      LogUtil.error(`report properties failed ${JSON.stringify(err)}`)
    })
  }

  /**
   * 触发多个服务的属性变化，SDK自动上报变化的属性到平台
   *
   * @param serviceIds 发生变化的服务id列表
   */
  public fireServicesChanged(serviceIds: string[]): void {
    const serviceProperties: ServiceProperty[] = [];
    serviceIds.forEach(serviceId => {
      const deviceService = this.getService(serviceId);
      if (deviceService === null || deviceService === undefined || deviceService.serviceId === null) {
        LogUtil.error(`service not found: ${serviceId}`);
        return;
      }

      const props = deviceService.onRead();
      const serviceProperty: ServiceProperty = {
        service_id: deviceService.serviceId,
        properties: props,
        event_time: IoTUtil.getEventTimestamp(),
      }
      serviceProperties.push(serviceProperty)
    })

    if (serviceProperties.length === 0) {
      return;
    }
    this.client.reportProperties(serviceProperties).then((data: IoTMqttResponse) => {
      LogUtil.debug(`report properties success ${JSON.stringify(data)}`)
    }).catch((err: IoTMqttResponse | string) => {
      LogUtil.error(`report properties failed ${JSON.stringify(err)}`)
    })
  }
}