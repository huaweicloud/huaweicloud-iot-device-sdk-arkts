import { IoTDevice, CustomOptions, CustomBackoffHandler } from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

@Builder
export function ReConnectSampleBuilder(name: string, para: object) {
  ReConnectSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "ReConnectSample";

@Component
struct ReConnectSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  private retryTimes: number = 0;

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_reconnect_title'))
          .margin({ top: 20 })
          .width(300)

        Button($r('app.string.set_reconnect_option'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }

            // 不使用使用默认断线重连
            const customOptions: CustomOptions = new CustomOptions();
            customOptions.reConnect = false;
            let customBackoffHandler: CustomBackoffHandler = {
              backoffHandler: (async () => {
                if (this.device === null) {
                  throw new Error("device is empty")
                }
                let ret = false;
                let time = 5000;
                while (!ret) {
                  // 退避重连
                  if (this.retryTimes > 10) {
                    time = 30000;
                  }
                  try {
                    this.sleep(time);
                  } catch (e) {
                    LogUtil.error(TAG, `sleep failed, the reason is ${e.getMessage()}`);
                  }
                  this.retryTimes++;
                  ret = await this.device.client.connect();
                }
                this.retryTimes = 0;
                return true;
              })
            }
            customOptions.customBackoffHandler = customBackoffHandler;
            this.device.client.customOptions = customOptions;
          })
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
