import { IoTDevice, IoTMqttResponse, ShadowListener, ShadowRequest,
  ShadowData } from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

@Builder
export function ShadowSampleBuilder(name: string, para: object) {
  ShadowSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "ShadowSample";
@Component
struct ShadowSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_shadow_title'))
          .margin({ top: 20 })
          .width(300)

        Button($r('app.string.set_shadow_listener'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              // this.pageInfos.clear();
              return;
            }

            // 设置设备影子监听器
            let shadowListener: ShadowListener = {
              onShadow: (requestId: string, shadowDataList: ShadowData[]): void => {
                LogUtil.info(TAG, `requestId is ${requestId}`);
              }
            }
            this.device.client.shadowListener = shadowListener;

            const shadowRequest: ShadowRequest = {
              object_device_id: this.device.deviceId,
              service_id: 'smokeDetector'
            }
            this.device.client.getShadow(shadowRequest).then((data: IoTMqttResponse) => {
              LogUtil.info(TAG, "getShadow success")
            }).catch((err: IoTMqttResponse | string) => {
              LogUtil.error(TAG, `getShadow failed ${JSON.stringify(err)}`)
            })
          })
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