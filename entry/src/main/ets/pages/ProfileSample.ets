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

import { IoTDevice, CommandRsp, AbstractService, IotResult} from '@huaweicloud/iot-device-sdk';
import { LogUtil } from './utils/LogUtil';

@Builder
export function ProfileSampleBuilder(name: string, para: object) {
  ProfileSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "ProfileSample#";
@Component
struct ProfileSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器
  @State logArr: string[] = [];
  @State isEnableAutoReport: boolean = false;

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_profile_title'))
          .margin({ top: 10 })
          .width(300)

        Button($r('app.string.set_profile'))
          .enabled(!this.isEnableAutoReport)
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            this.isEnableAutoReport = true;
            const smokeDetector = new SmokeDetector();
            this.device.addService("smokeDetector", smokeDetector);
            // 启动自动上报
            smokeDetector.enableAutoReport(10000);
            this.logArr.unshift(`${new Date()}: add service success and enable auto report`)
          })

        Button($r('app.string.disable_auto_report'))
          .enabled(this.isEnableAutoReport)
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            // 取消自动上报
            this.device.services.get('smokeDetector')?.disableAutoReport();
            this.isEnableAutoReport = false;
            this.logArr.unshift(`${new Date()}: disable auto report success`)
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
      this.device = this.pageInfos.getParamByName("profileSample")[0] as IoTDevice;
    })
  }

}

class SmokeDetector extends AbstractService {

  // 按照设备模型定义属性，注意属性的name和类型需要和模型一致，writeable表示属性知否可写，name指定属性名
  @Reflect.metadata("Property", { name: "alarm", writeable: true })
  private _smokeAlarm: number = 1;

  public set smokeAlarm(value: number) {
    this._smokeAlarm = value;
    if (value == 0) {
      LogUtil.info(TAG, "alarm is cleared by app");
    }
  }

  public get smokeAlarm(): number {
    return this._smokeAlarm;
  }

  @Reflect.metadata("Property", { name: "smokeConcentration", writeable: false })
  private _concentration: number = 0;

  public set concentration(value: number) {
    // 只读字段不需要实现set接口
  }

  public get concentration(): number {
    return Math.floor(Math.random() * 100);
  }

  @Reflect.metadata("Property", { name: "humidity", writeable: false })
  private _humidity: number = 0;

  public set humidity(value: number) {
    // 只读字段不需要实现set接口
  }

  public get humidity(): number {
    return Math.floor(Math.random() * 100);
  }

  @Reflect.metadata("Property", { name: "temperature", writeable: false })
  private _temperature: number = 10;

  public set temperature(value: number) {
    // 只读字段不需要实现set接口
  }

  public get temperature(): number {
    return Math.floor(Math.random() * 100);
  }

  // 定义命令，注意接口入参和返回值类型是固定的不能修改，否则会出现运行时错误
  @Reflect.metadata("DeviceCommand", {
    name: "ringAlarm",
    method: (paras: object): CommandRsp => {
      let duration: number = paras['duration'];
      LogUtil.log(TAG, `duration is ${duration}`);
			return IotResult.SUCCESS;
		}
  })
  private _alarm: Function = () => {};

  constructor() {
    super();
    const fields = Object.getOwnPropertyNames(this);
    this.init(fields);
  }
}