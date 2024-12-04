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

import { IoTDevice, IoTMqttResponse, CommandListener, CommandRsp } from '@huaweicloud/iot-device-sdk';
import { ScrollerLogComponent } from './components/ScrollerLog';
import { LogUtil } from './utils/LogUtil';

@Builder
export function CommandSampleBuilder(name: string, para: object) {
  CommandSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "CommandSample#";

@Component
struct CommandSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  @State isSetCommandListener: boolean = false;
  @State logArr: string[] = [];

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_command_title'))
          .margin({ top: 10 })
          .width(300)

        Button($r('app.string.set_command_listener'))
          .enabled(!this.isSetCommandListener)
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              this.logArr.unshift(`${new Date()}: mqtt not connect`)
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }

            let commandListener: CommandListener = {
              onCommand: (requestId: string, serviceId: string, commandName: string, paras: object): void => {
                const command =
                  `requestId is ${requestId}, serviceId is ${serviceId}, commandName is ${commandName}, paras is ${JSON.stringify(paras)}`;
                LogUtil.info(TAG, `received command is ${command}`);
                this.logArr.unshift(`${new Date()}: onCommand, ${command}`)
                // 用户可以在该处进行命令处理

                const commandRsp: CommandRsp = {
                  result_code: 0
                }
                this.device?.client.respondCommand(requestId, commandRsp).then((data: IoTMqttResponse) => {
                  LogUtil.info(TAG, `respond command success ${JSON.stringify(data)}`);
                  this.logArr.unshift(`${new Date()}: onCommand, respond command success`)
                }).catch((err: IoTMqttResponse | string) => {
                  LogUtil.error(TAG, `respond command failed ${JSON.stringify(err)}`);
                  this.logArr.unshift(`${new Date()}: respond command failed ${JSON.stringify(err)}`)
                })
              }
            }
            this.device.client.commandListener = commandListener;
            this.isSetCommandListener = true;
          })

        ScrollerLogComponent({logArr: this.logArr})
      }
      .height('100%')
      .width('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("commandSample")[0] as IoTDevice;
    })
  }
}
