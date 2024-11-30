import { IoTDevice, CommandRsp, AbstractService, IotResult} from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

@Builder
export function ProfileSampleBuilder(name: string, para: object) {
  ProfileSample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "ProfileSample";
@Component
struct ProfileSample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_profile_title'))
          .margin({ top: 20 })
          .width(300)

        Button($r('app.string.set_profile'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            const smokeDetector = new SmokeDetector();
            this.device.addService("smokeDetector", smokeDetector);
            // 启动自动上报
            smokeDetector.enableAutoReport(10000);
          })
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