import { IoTDevice } from 'huaweicloud_iot_device_library';
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
        Button($r('app.string.disconnect'))
          .width(300)
          .margin({ top: 20 })
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
    .title($r('app.string.connect_success_title') + "")
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("mqttConnectSuccess")[0] as IoTDevice;
    })
  }
}