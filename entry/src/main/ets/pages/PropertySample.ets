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

import {
  IoTDevice,
  IoTMqttResponse,
  IotResult,
  PropertyListener,
  ServiceProperty
} from '@huaweicloud/iot-device-sdk';
import { ScrollerLogComponent } from './components/ScrollerLog';
import { LogUtil } from './utils/LogUtil';

@Builder
export function PropertySampleBuilder(name: string, para: object) {
  PropertySample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "PropertySample#";

@Component
struct PropertySample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  @State properties: string = "";
  @State isPropertyListenerSet: boolean = false;
  @State logArr: string[] = [];

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_property_title'))
          .margin({ top: 10 })
          .width(300)
        TextArea({
          placeholder: $r('app.string.input_property_placeholder'),
          text: JSON.stringify(this.getDefaultProperties())
        })
          .margin({ top: 10 })
          .width(300)
          .height(200)
          .onChange((value: string) => {
            this.properties = value;
          })

        Button($r('app.string.report_property'))
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              this.logArr.unshift(`${new Date()}: mqtt not connect`)
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            const properties: ServiceProperty[] = JSON.parse(this.properties);
            this.device.client.reportProperties(properties)
              .then((data: IoTMqttResponse) => {
                LogUtil.info(TAG, `report properties success ${JSON.stringify(data)}`);
                this.logArr.unshift(`${new Date()}: report properties success`)
              })
              .catch((error: IoTMqttResponse | string) => {
                LogUtil.error(TAG, `report properties failed ${JSON.stringify(error)}`);
                this.logArr.unshift(`${new Date()}: report properties failed`)
              })
          })
        Button($r('app.string.set_property_listener'))
          .width(300)
          .margin({ top: 10 })
          .enabled(!this.isPropertyListenerSet)
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              this.logArr.unshift(`${new Date()}: mqtt not connect`)
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            this.setPropertyListener();
            this.logArr.unshift(`${new Date()}: set property listener`)
          })
        ScrollerLogComponent({logArr: this.logArr})

      }

    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("propertySample")[0] as IoTDevice;
    })
  }

  private getDefaultProperties() {
    const properties: ServiceProperty[] = [
      {
        "service_id": "smokeDetector",
        "properties": {
          "alarm": 1,
          "temperature": Math.random() * 100,
          "humidity": Math.random() * 100,
          "smokeConcentration": Math.random() * 100,
        }
      }
    ]
    return properties;
  }

  private setPropertyListener() {
    if (this.device === null) {
      return;
    }
    let propertyListener: PropertyListener = {
      onPropertiesSet: (requestId: string, services: ServiceProperty[]): void => {
        this.logArr.unshift(`${new Date()}: onPropertiesSet requestId is ${requestId}, services is ${JSON.stringify(services)}`)
        // 遍历services
        services.forEach(serviceProperty => {
          LogUtil.info("onPropertiesSet, serviceId is ", serviceProperty.service_id);
          // 遍历属性
          Object.keys(serviceProperty.properties).forEach(name => {
            LogUtil.log(TAG, `property name is ${name}`);
            LogUtil.log(TAG, `set property value is ${serviceProperty.properties["name"]}`);
          })
        })

        // 修改本地的属性
        this.device?.client.respondPropsSet(requestId, IotResult.SUCCESS);
      },
      onPropertiesGet: (requestId: string, serviceId?: string): void => {
        this.logArr.unshift(`${new Date()}: onPropertiesGet requestId is ${requestId}, serviceId is ${serviceId} and respondPropsGet`)
        LogUtil.info(TAG, `onPropertiesGet, the serviceId is ${serviceId}`);
        const serviceProperties = this.getDefaultProperties();
        this.device?.client.respondPropsGet(requestId, serviceProperties);
      }
    }
    // 设置属性监听器
    this.device.client.propertyListener = propertyListener;
    this.isPropertyListenerSet = true;
  }
}