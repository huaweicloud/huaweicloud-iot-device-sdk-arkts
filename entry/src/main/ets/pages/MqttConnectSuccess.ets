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

import { IoTDevice } from '@huaweicloud/iot-device-sdk';
import { LogUtil } from './utils/LogUtil';

@Builder
export function MqttConnectSuccessBuilder(name: string, para: object) {
  MqttConnectSuccess()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "MqttConnectSuccess";

@Component
struct MqttConnectSuccess {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.connect_success_title'))
          .margin({ top: 20 })
          .width(300)

        Button($r('app.string.property'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            this.pageInfos.pushPathByName("propertySample", this.device);
          })
        Button($r('app.string.message'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            this.pageInfos.pushPathByName("messageSample", this.device);
          })
        Button($r('app.string.command'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            this.pageInfos.pushPathByName("commandSample", this.device);
          })
        Button($r('app.string.shadow'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            this.pageInfos.pushPathByName("shadowSample", this.device);
          })
        Button($r('app.string.profile'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            this.pageInfos.pushPathByName("profileSample", this.device);
          })
        Button($r('app.string.reconnect'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            this.pageInfos.pushPathByName("reConnectSample", this.device);
          })
        Button($r('app.string.disconnect'))
          .width(300)
          .margin({ top: 20 })
          .role(ButtonRole.ERROR)
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              this.pageInfos.clear();
              return;
            }
            await this.device?.client.disconnect();
            await this.device?.client.destroy();
            this.pageInfos.clear();
          })
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("mqttConnectSuccess")[0] as IoTDevice;
    })
  }
}