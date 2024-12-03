import {
  IoTDevice,
  IoTMqttResponse,
  ShadowListener,
  ShadowRequest,
  ShadowData
} from '@huaweicloud/iot-device-sdk';
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
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器

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
      this.device = this.pageInfos.getParamByName("shadowSample")[0] as IoTDevice;
    })
  }
}