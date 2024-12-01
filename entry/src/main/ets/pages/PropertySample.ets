import {
  IoTDevice,
  IoTMqttResponse,
  IotResult,
  PropertyListener,
  ServiceProperty
} from 'huaweicloud_iot_device_library';
import { LogUtil } from './utils/LogUtil';

@Builder
export function PropertySampleBuilder(name: string, para: object) {
  PropertySample()
}

const COLUMN_SPACE: number = 12;
const TAG: string = "PropertySample";

@Component
struct PropertySample {
  pageInfos: NavPathStack = new NavPathStack();
  private device: IoTDevice | null = null;
  @State properties: string = "";

  build() {
    NavDestination() {
      Column({ space: COLUMN_SPACE }) {
        Text($r('app.string.try_property_title'))
          .margin({ top: 20 })
          .width(300)
        TextArea({
          placeholder: $r('app.string.input_property_placeholder'),
          text: JSON.stringify(this.getDefaultProperties())
        })
          .margin({ top: 20 })
          .width(300)
          .height(200)
          .onChange((value: string) => {
            this.properties = value;
          })

        Button($r('app.string.report_property'))
          .width(300)
          .margin({ top: 20 })
          .onClick(async () => {
            if (!this.device?.client || !await this.device?.client.isConnected()) {
              LogUtil.info(TAG, "mqtt not connect")
              return;
            }
            this.setPropertyListener();
            const properties: ServiceProperty[] = JSON.parse(this.properties);
            this.device.client.reportProperties(properties)
              .then((data: IoTMqttResponse) => {
                LogUtil.info(TAG, `report properties success ${JSON.stringify(data)}`);
              })
              .catch((error: IoTMqttResponse | string) => {
                LogUtil.error(TAG, `report properties failed ${JSON.stringify(error)}`);
              })
          })
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.device = this.pageInfos.getParamByName("propertySample")[0] as IoTDevice;
    })
  }

  private getDefaultProperties() {
    const properties: ServiceProperty[] = [
      {
        "service_id": "smokeDetector",
        "properties": {
          "alarm": 1,
          "temperature": Math.random() * 100,
          "humidity": Math.random() * 100,
          "smokeConcentration": Math.random() * 100,
        }
      }
    ]
    return properties;
  }

  private setPropertyListener() {
    if (this.device === null) {
      return;
    }
    let propertyListener: PropertyListener = {
      onPropertiesSet: (requestId: string, services: ServiceProperty[]): void => {
        // 遍历services
        services.forEach(serviceProperty => {
          LogUtil.info("onPropertiesSet, serviceId is ", serviceProperty.service_id);
          // 遍历属性
          Object.keys(serviceProperty.properties).forEach(name => {
            LogUtil.log(TAG, `property name is ${name}`);
            LogUtil.log(TAG, `set property value is ${serviceProperty.properties["name"]}`);
          })
        })

        // 修改本地的属性
        this.device?.client.respondPropsSet(requestId, IotResult.SUCCESS);
      },
      onPropertiesGet: (requestId: string, serviceId?: string): void => {
        LogUtil.info(TAG, `onPropertiesGet, the serviceId is ${serviceId}`);
        const serviceProperties = this.getDefaultProperties();
        this.device?.client.respondPropsGet(requestId, serviceProperties);
      }
    }
    // 设置属性监听器
    this.device.client.propertyListener = propertyListener;

  }
}