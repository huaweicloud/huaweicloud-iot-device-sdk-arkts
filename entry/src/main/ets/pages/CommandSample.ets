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
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器
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

        Scroll(this.scroller) {                  // 绑定滚动控制器
          Column() {
            ForEach(this.logArr, (log: string) => {      // ForEach语法循环创建子组件
              Text(log)
                .fontSize(12)
                .width('98%')
                .borderRadius(10)
                .backgroundColor(Color.White)
                .margin({top: 10})
            })
          }
          .width("100%")
        }
        .scrollable(ScrollDirection.Vertical)    // 设置竖直方向滚动
        .scrollBarColor(Color.Gray)             // 设置滚动条颜色
        .scrollBarWidth(10)                      // 设置滚动条宽度
        .scrollBar(BarState.On)                  // 设置滚动条永久显示
        .width('100%')
        .height(220)
        .padding({top: 10, bottom: 10})
        .border({ width: 0.5 })

        if (this.logArr.length > 0) {
          Button($r('app.string.clear_log'))
            .width(300)
            .margin({ top: 10 })
            .onClick(() => {
              this.logArr = []
            })
        }
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