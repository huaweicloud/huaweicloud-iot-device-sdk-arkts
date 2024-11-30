import { IoTDevice } from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

const TAG: string = "Login"

@Entry
@Component
struct Index {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  @State serverUri: string = "";
  @State deviceId: string = "";
  @State deviceSecret: string = "";

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
        Button($r('app.string.iotda_connect'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            LogUtil.debug(TAG, "click mqtt connect button");
            if (this.device?.client && await this.device.client.isConnected()) {
              LogUtil.info(TAG, "mqtt is connected");
              this.pageInfos.pushPathByName("mqttConnectSuccess", this.device);
              return;
            }
            // 证书文件放在resource/resfile下，连接华为云时请使用对应的证书。
            this.device = new IoTDevice(this.serverUri, this.deviceId, this.deviceSecret, 'GlobalSign-rootca.pem');

            this.device.init().then(async (data: boolean) => {
              LogUtil.info(TAG, `mqtt connect result is ${data}`);
              if (await this.device?.client.isConnected()) {
                this.pageInfos.pushPathByName("mqttConnectSuccess", this.device);
              }
            }).catch((err: string) => {
              LogUtil.error(TAG, `mqtt connect failed ${JSON.stringify(err)}`);
            })
          })
      }
    }
    .title($r('app.string.iotda_title'))
  }
}