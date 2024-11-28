import { IoTDevice, IoTMqttResponse, CommandListener, CommandRsp } from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

@Builder
export function CommandSampleBuilder(name: string, para: object) {
  CommandSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "CommandSample";
@Component
struct CommandSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;

  @State commandArr: string[] = [];

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_command_title'))
          .margin({ top: 20 })
          .width(300)

        Button($r('app.string.set_command_listener'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              // this.pageInfos.clear();
              return;
            }

            let commandListener: CommandListener = {
              onCommand: (requestId: string, serviceId: string, commandName: string, paras: object): void => {
                const command = `requestId is ${requestId}, serviceId is ${serviceId}, commandName is ${commandName}, paras is ${JSON.stringify(paras)}`;
                LogUtil.info(TAG, `received command is ${command}`);
                // 用户可以在该处进行命令处理

                const commandRsp: CommandRsp = {
                  result_code: 0
                }
                this.device?.client.respondCommand(requestId, commandRsp).then((data: IoTMqttResponse) => {
                  LogUtil.info(TAG, `respond command success ${JSON.stringify(data)}` );
                }).catch((err: IoTMqttResponse) => {
                  LogUtil.error(TAG, `respond command failed ${JSON.stringify(err)}`);
                })
              }
            }
            if (this.device !== null) {
              this.device.client.commandListener = commandListener;
            }
          })
      }
      .height('100%')
      .width('100%')
    }
    .title($r('app.string.command_sample') + "")
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("commandSample")[0] as IoTDevice;
    })
  }

}