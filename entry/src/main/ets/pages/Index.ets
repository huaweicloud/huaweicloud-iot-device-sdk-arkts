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
import { promptAction } from '@kit.ArkUI';

const TAG: string = "Login#"

@Entry
@Component
struct Index {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  @State serverUri: string = "";
  @State deviceId: string = "";
  @State deviceSecret: string = "";
  @State isConnecting: boolean = false;

  build() {
    Navigation(this.pageInfos) {
      Column() {
        TextInput({ placeholder: $r('app.string.input_serverUri_placeholder') })
          .margin({ top: 20 })
          .onChange((value: string) => {
            this.serverUri = value;
          })
        TextInput({ placeholder: $r('app.string.input_deviceId_placeholder') })
          .margin({ top: 20 })
          .onChange((value: string) => {
            this.deviceId = value;
          })
        TextInput({ placeholder: $r('app.string.input_secret_placeholder') })
          .type(InputType.Password)
          .margin({ top: 20 })
          .onChange((value: string) => {
            this.deviceSecret = value;
          })
        if (!this.isConnecting) {
          Button($r('app.string.iotda_connect'))
            .width(300)
            .margin({ top: 20 })
            .onClick(async () => {
              LogUtil.debug(TAG, "click mqtt connect button");
              this.isConnecting = true;
              if (this.device?.client && await this.device.client.isConnected()) {
                LogUtil.info(TAG, "mqtt is connected");
                this.isConnecting = false;
                this.pageInfos.pushPathByName("mqttConnectSuccess", this.device);
                return;
              }
              // 证书文件放在resource/resfile下，连接华为云时请使用对应的证书。
              this.device = new IoTDevice(this.serverUri, this.deviceId, this.deviceSecret, 'GlobalSign-rootca.pem');
              this.device.init().then(async (data: boolean) => {
                LogUtil.info(TAG, `mqtt connect result is ${data}`);
                this.isConnecting = false;
                if (await this.device?.client.isConnected()) {
                  promptAction.showToast({
                    message: 'Connect Success',
                    duration: 2000
                  })
                  this.pageInfos.pushPathByName("mqttConnectSuccess", this.device);
                }
              }).catch((err: string) => {
                this.isConnecting = false;
                LogUtil.error(TAG, `mqtt connect failed ${JSON.stringify(err)}`);
                promptAction.showDialog({
                  title: 'Connect Failed',
                  message: `Reason: ${JSON.stringify(err)}`,
                })
              })
            })
        } else {
          LoadingProgress()
            .color(Color.Blue)
            .margin({top: 20})
            .width(40)
        }

      }
    }
    .title($r('app.string.iotda_title'))
  }
}