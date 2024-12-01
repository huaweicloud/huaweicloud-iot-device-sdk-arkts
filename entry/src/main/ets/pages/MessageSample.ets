import { IoTDevice, IoTMqttResponse, RawMessageListener,
  DeviceMessage, RawMessage, RawDeviceMessageListener, RawDeviceMessage
} from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

@Builder
export function MessageSampleBuilder(name: string, para: object) {
  MessageSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "MessageSample";

@Component
struct MessageSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  private isSubscribeHelloWorldTopic = false;
  private isSubscribeOCTopic = false;
  @State message: string = "";

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_message_title'))
          .margin({ top: 20 })
          .width(300)
        TextArea({ placeholder: $r('app.string.input_message_placeholder'), text: "this is message" })
          .margin({ top: 20 })
          .width(300)
          .height(200)
          .onChange((value: string) => {
            this.message = value;
          })

        Button($r('app.string.report_system_topic_message'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }

            // 设置系统topic消息的监听处理
            let rawDeviceMessageListener: RawDeviceMessageListener = {
              onRawDeviceMessage: (rawDeviceMessage: RawDeviceMessage): void => {
                LogUtil.info(TAG, `reveived device message is ${JSON.stringify(rawDeviceMessage)}`);
              }
            }
            this.device.client.rawDeviceMessageListener = rawDeviceMessageListener;

            // 上报系统topic的消息
            const reportMessage: DeviceMessage = { content: this.message }
            this.device.client.reportDeviceMessage(reportMessage)
              .then((data: IoTMqttResponse) => {
                LogUtil.info(TAG, `report deviceMessage success ${JSON.stringify(data)}`);
              })
              .catch((error: IoTMqttResponse | string) => {
                LogUtil.error(TAG, `report deviceMessage failed ${JSON.stringify(error)}`);
              })
          })

        Button($r('app.string.report_custom_topic_message'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              // this.pageInfos.clear();
              return;
            }
            const topic = "hello/world";
            let rawMessageListener: RawMessageListener = {
              onMessageReceived: (rawMessage: RawMessage) => {
                LogUtil.log(TAG, `onMessageReceived message is ${JSON.stringify(rawMessage)}`);
              }
            }
            const rawMessage: RawMessage = {
              topic: topic,
              qos: 0,
              payload: this.message
            }
            if (this.isSubscribeHelloWorldTopic) {
              await this.device?.client.publishRawMessage((rawMessage));
              return;
            }
            this.device.client.subscribeTopic(topic, rawMessageListener).then((data: IoTMqttResponse) => {
              LogUtil.info(TAG, `subscribe topic success ${JSON.stringify(data)}`);
              this.isSubscribeHelloWorldTopic = true;
              this.device?.client.publishRawMessage((rawMessage));
            }).catch((err: IoTMqttResponse) => {
              LogUtil.error(TAG, `subscribe topic failed ${JSON.stringify(err)}`);
            })
          })

        Button($r('app.string.report_custom_oc_topic_message'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              // this.pageInfos.clear();
              return;
            }
            const topic = `$oc/devices/${this.device?.deviceId}/user/test`;
            let rawMessageListener: RawMessageListener = {
              onMessageReceived: (rawMessage: RawMessage) => {
                LogUtil.info(TAG, `onMessageReceived message is ${JSON.stringify(rawMessage)}`);
              }
            }
            const rawMessage: RawMessage = {
              topic: topic,
              qos: 0,
              payload: this.message
            }
            if (this.isSubscribeOCTopic) {
              await this.device?.client.publishRawMessage((rawMessage));
              return;
            }
            this.device.client.subscribeTopic(topic, rawMessageListener).then((data: IoTMqttResponse) => {
              LogUtil.info(TAG, `subscribe topic success ${JSON.stringify(data)}`);
              this.isSubscribeOCTopic = true;
              this.device?.client.publishRawMessage((rawMessage));
            }).catch((err: IoTMqttResponse) => {
              LogUtil.error(TAG, `subscribe topic failed ${JSON.stringify(err)}`);
            })
          })
      }
      .height('100%')
      .width('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("messageSample")[0] as IoTDevice;
    })
  }

}