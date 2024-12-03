import { IoTDevice, IoTMqttResponse, RawMessageListener,
  DeviceMessage, RawMessage, RawDeviceMessageListener, RawDeviceMessage,
  ConnectListener
} from '@huaweicloud/iot-device-sdk';
import { LogUtil } from './utils/LogUtil';

@Builder
export function MessageSampleBuilder(name: string, para: object) {
  MessageSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "MessageSample#";
const HELLO_WORLD_TOPIC: string = "hello/world";

@Component
struct MessageSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  private isSubscribeHelloWorldTopic = false;
  private isSubscribeOCTopic = false;
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器
  private helloWorldTopicListener: RawMessageListener | null = null;
  private ocTopicListener: RawMessageListener | null = null;

  @State message: string = "";
  @State logArr: string[] = [];

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_message_title'))
          .margin({ top: 10 })
          .width(300)
        TextArea({ placeholder: $r('app.string.input_message_placeholder'), text: "this is message" })
          .margin({ top: 10 })
          .width(300)
          .height(200)
          .onChange((value: string) => {
            this.message = value;
          })

        Button($r('app.string.report_system_topic_message'))
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }

            // 设置系统topic消息的监听处理
            let rawDeviceMessageListener: RawDeviceMessageListener = {
              onRawDeviceMessage: (rawDeviceMessage: RawDeviceMessage): void => {
                this.logArr.unshift(`${new Date()}: onRawDeviceMessage, rawDeviceMessage is ${JSON.stringify(rawDeviceMessage)}`)
                LogUtil.info(TAG, `reveived device message is ${JSON.stringify(rawDeviceMessage)}`);
              }
            }
            this.device.client.rawDeviceMessageListener = rawDeviceMessageListener;

            // 上报系统topic的消息
            const reportMessage: DeviceMessage = { content: this.message }
            this.device.client.reportDeviceMessage(reportMessage)
              .then((data: IoTMqttResponse) => {
                this.logArr.unshift(`${new Date()}: report message by system topic success, message is  ${JSON.stringify(reportMessage)}`)
                LogUtil.info(TAG, `report deviceMessage success ${JSON.stringify(data)}`);
              })
              .catch((error: IoTMqttResponse | string) => {
                this.logArr.unshift(`${new Date()}: report message by system topic failed, error is  ${JSON.stringify(error)}`)
                LogUtil.error(TAG, `report deviceMessage failed ${JSON.stringify(error)}`);
              })
          })

        Button($r('app.string.report_custom_topic_message'))
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            const topic = HELLO_WORLD_TOPIC;

            this.helloWorldTopicListener = {
              onMessageReceived: (rawMessage: RawMessage) => {
                this.logArr.unshift(`${new Date()}: onMessageReceived(custom), rawMessage is ${JSON.stringify(rawMessage)}`)
                LogUtil.log(TAG, `onMessageReceived message is ${JSON.stringify(rawMessage)}`);
              }
            }
            // 设置连接监听器，断线重连处理以及重新连接成功处理
            this.device.client.connectionListener = this.getConnectionListener();

            const rawMessage: RawMessage = {
              topic: topic,
              qos: 0,
              payload: this.message
            }
            if (this.isSubscribeHelloWorldTopic) {
              this.publishRawMessage(rawMessage);
              return;
            }
            this.device.client.subscribeTopic(topic, this.helloWorldTopicListener).then((data: IoTMqttResponse) => {
              this.logArr.unshift(`${new Date()}: subscribe topic(${topic}) success`)
              LogUtil.info(TAG, `subscribe topic success ${JSON.stringify(data)}`);
              this.isSubscribeHelloWorldTopic = true;
              this.publishRawMessage(rawMessage);
            }).catch((err: IoTMqttResponse | string) => {
              LogUtil.error(TAG, `subscribe topic(${topic}) failed ${JSON.stringify(err)}`);
              this.logArr.unshift(`${new Date()}: subscribe topic(${topic}) failed`)
            })
          })

        Button($r('app.string.report_custom_oc_topic_message'))
          .width(300)
          .margin({ top: 10 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            const topic = `$oc/devices/${this.device?.deviceId}/user/test`;
            this.ocTopicListener = {
              onMessageReceived: (rawMessage: RawMessage) => {
                this.logArr.unshift(`${new Date()}: onMessageReceived, rawMessage is ${JSON.stringify(rawMessage)}`)
                LogUtil.info(TAG, `onMessageReceived message is ${JSON.stringify(rawMessage)}`);
              }
            }

            // 设置连接监听器，断线重连处理以及重新连接成功处理
            this.device.client.connectionListener = this.getConnectionListener();

            const rawMessage: RawMessage = {
              topic: topic,
              qos: 0,
              payload: this.message
            }
            if (this.isSubscribeOCTopic) {
              this.publishRawMessage(rawMessage);
              return;
            }
            this.device.client.subscribeTopic(topic, this.ocTopicListener).then((data: IoTMqttResponse) => {
              this.logArr.unshift(`${new Date()}: subscribe topic(${topic}) success`)
              LogUtil.info(TAG, `subscribe topic success ${JSON.stringify(data)}`);
              this.isSubscribeOCTopic = true;
              this.publishRawMessage(rawMessage);
            }).catch((err: IoTMqttResponse | string) => {
              LogUtil.error(TAG, `subscribe topic(${topic}) failed ${JSON.stringify(err)}`);
              this.logArr.unshift(`${new Date()}: subscribe topic(${topic}) failed`)
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
      this.device = this.pageInfos.getParamByName("messageSample")[0] as IoTDevice;
    })
  }

  private publishRawMessage(rawMessage: RawMessage) {
    this.device?.client.publishRawMessage((rawMessage)).then((res: IoTMqttResponse) => {
      this.logArr.unshift(`${new Date()}: publish rawMessage(${rawMessage.topic}) success, message is ${JSON.stringify(rawMessage)}}`)
    }).catch((error: IoTMqttResponse | string) => {
      this.logArr.unshift(`${new Date()}: publish rawMessage(${rawMessage.topic})failed, error is ${JSON.stringify(error)}}`)
    });
  }

  private getConnectionListener() {
    let connectionListener: ConnectListener = {
      connectionLost: (): void => {
        // 断线后有默认处理，也可以增加自己的处理逻辑
        LogUtil.error(TAG, `connectionLost`);
        this.logArr.unshift(`${new Date()}: connectionLost`);
      },
      connectComplete: (): void => {
        // 连接成功后，自动重新订阅Topic
        if (!this.ocTopicListener && !this.helloWorldTopicListener) {
          this.logArr.unshift(`${new Date()}: no need to resubscribe`)
          return;
        }
        if (this.helloWorldTopicListener) {
          this.subscribe(HELLO_WORLD_TOPIC, this.helloWorldTopicListener)
        }
        if (this.ocTopicListener) {
          this.subscribe(`$oc/devices/${this.device?.deviceId}/user/test`, this.ocTopicListener)
        }

      }
    }
    return connectionListener;
  }

  private subscribe(topic: string, rawMessageListener: RawMessageListener) {
    this.device?.client.subscribeTopic(topic, rawMessageListener).then((data: IoTMqttResponse) => {
      this.logArr.unshift(`${new Date()}: resubscribe topic(${topic}) success`)
      LogUtil.info(TAG, `resubscribe topic success ${JSON.stringify(data)}`);
    }).catch((err: IoTMqttResponse | string) => {
      LogUtil.error(TAG, `resubscribe topic(${topic}) failed ${JSON.stringify(err)}`);
      this.logArr.unshift(`${new Date()}: resubscribe topic(${topic}) failed`)
    })
  }

}
