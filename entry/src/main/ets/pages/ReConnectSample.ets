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

import { IoTDevice, CustomOptions, CustomBackoffHandler } from '@huaweicloud/iot-device-sdk';
import { LogUtil } from './utils/LogUtil';

@Builder
export function ReConnectSampleBuilder(name: string, para: object) {
  ReConnectSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "ReConnectSample#";

@Component
struct ReConnectSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  private retryTimes: number = 0;
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器
  @State logArr: string[] = [];
  @State isSetOptions: boolean = false;


  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_reconnect_title'))
          .margin({ top: 10 })
          .width(300)

        Button($r('app.string.set_reconnect_option'))
          .enabled(!this.isSetOptions)
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }

            // 不使用默认断线重连
            // 重连也可以定义在首次连接之前
            const customOptions: CustomOptions = new CustomOptions();
            customOptions.reConnect = false;
            let customBackoffHandler: CustomBackoffHandler = {
              backoffHandler: (async () => {
                if (this.device === null) {
                  throw new Error("device is empty")
                }
                let time = 5000;
                // 退避重连
                if (this.retryTimes > 10) {
                  time = 30000;
                }
                try {
                  await this.sleep(time);
                } catch (e) {
                  LogUtil.error(TAG, `sleep failed, the reason is ${e.getMessage()}`);
                }
                this.retryTimes++;
                try {
                  this.logArr.unshift(`${new Date()}: reconnect, retry times is ${this.retryTimes}`)
                  const connectResult = await this.device.client.connect();
                  if (connectResult) {
                    this.logArr.unshift(`${new Date()}: reconnect success, retry times is ${this.retryTimes}`)
                    this.retryTimes = 0;
                  } else {
                    this.logArr.unshift(`${new Date()}: reconnect failed, retry times is ${this.retryTimes}`)
                  }
                  return connectResult;
                } catch (e) {
                  this.logArr.unshift(`${new Date()}: reconnect failed, retry times is ${this.retryTimes}`)
                  return false;
                }

              })
            }
            customOptions.customBackoffHandler = customBackoffHandler;
            this.device.client.customOptions = customOptions;
            this.isSetOptions = true;
            this.logArr.unshift(`${new Date()}: set customOptions success`)
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
      this.device = this.pageInfos.getParamByName("reConnectSample")[0] as IoTDevice;
    })
  }

  private async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
