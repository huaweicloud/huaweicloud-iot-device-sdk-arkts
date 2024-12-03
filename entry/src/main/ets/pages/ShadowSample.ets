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
  ShadowListener,
  ShadowRequest,
  ShadowData
} from '@huaweicloud/iot-device-sdk';
import { ScrollerLogComponent } from './components/ScrollerLog';
import { LogUtil } from './utils/LogUtil';

@Builder
export function ShadowSampleBuilder(name: string, para: object) {
  ShadowSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "ShadowSample#";

@Component
struct ShadowSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  @State logArr: string[] = [];

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_shadow_title'))
          .margin({ top: 10 })
          .width(300)

        Button($r('app.string.set_shadow_listener'))
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }

            // 设置设备影子监听器
            let shadowListener: ShadowListener = {
              onShadow: (requestId: string, shadowDataList?: ShadowData[]): void => {
                this.logArr.unshift(`${new Date()}: onShadow, requestId is ${requestId}, shadowDataList is ${JSON.stringify(shadowDataList)}`)
                LogUtil.info(TAG, `requestId is ${requestId}`);
              }
            }
            this.device.client.shadowListener = shadowListener;

            const shadowRequest: ShadowRequest = {
              object_device_id: this.device.deviceId,
              service_id: 'smokeDetector'
            }
            this.device.client.getShadow(shadowRequest)
              .then((data: IoTMqttResponse) => {
                this.logArr.unshift(`${new Date()}: getShadow success`)
                LogUtil.info(TAG, "getShadow success")
              })
              .catch((err: IoTMqttResponse | string) => {
                this.logArr.unshift(`${new Date()}: getShadow failed. ${JSON.stringify(err)}`)
                LogUtil.error(TAG, `getShadow failed ${JSON.stringify(err)}`)
              })
          })

        ScrollerLogComponent({logArr: this.logArr})
      }
      .height('100%')
      .width('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("shadowSample")[0] as IoTDevice;
    })
  }
}