
# huaweicloud-iot-device-sdk-askts

huaweicloud-iot-device-sdk-arkts提供设备接入华为云IoT物联网平台的ArkTS版本的SDK，提供设备和平台之间通讯能力，并且针对各种场景提供了丰富的demo代码。IoT设备开发者使用SDK可以大大简化开发复杂度，快速的接入平台。

# 0.版本更新说明

| 版本号   | 变更类型 | 说明                                                         |
|-------| -------- | ------------------------------------------------------------ |
| 0.0.1 | 新增功能 | 提供对接华为云物联网平台能力，方便用户实现接入、设备管理、命令下发等业务场景 |

# 1.前言
huaweicloud-iot-device-sdk-arkts提供设备接入华为云IoT物联网平台的ArkTS版本的SDK，提供设备和平台之间通讯能力，并且针对各种场景提供了丰富的demo代码。IoT设备开发者使用SDK可以大大简化开发复杂度，快速的接入平台。

# 2.SDK简介

## 2.1 准备工作
- 已安装[DevEco Studio](https://developer.huawei.com/consumer/cn/download/) 5.0.0及以上版本。
  DevEco Studio更多资料请参考[工具简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-tools-overview-V5)。
- 已安装[配套](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-development-environment-1-V5)的Node.js版本。

## 2.2 下载安装
```shell
ohpm install @huaweicloud/iot-device-sdk
```

## 2.3 权限配置
使用SDK需要网络连接的权限，需要在module.json5的requestPermissions中增加"ohos.permission.INTERNET"的权限，如下所示
```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ]
  }
}
```

## 2.4 功能支持
SDK面向运算、存储能力较强的嵌入式终端设备，开发者通过调用SDK接口，便可实现设备与物联网平台的上下行通讯。SDK当前支持的功能有：

| 功能                         | 描述说明                                                                                                                                              |
| ---------------------------- |:--------------------------------------------------------------------------------------------------------------------------------------------------|
| [设备初始化](#3.0)           | 作为客户端使用MQTT协议接入到华为云平台。当前仅支持密钥认证。                                                                                                                  |
| [自定义选项](#3.1)           | 自定义选项提供配置自定义断线重连、连接状态监听器功能。                                                                                           |
| [断线重连](#3.2)             | 设备连接失败或网络不稳定等原因导致被动断开连接时，会进行一个重连操作。                                                                                                               |
| [消息上报、下发](#3.3)       | 消息上报用于设备将自定义数据上报给平台，平台将设备上报的消息转发给应用服务器或华为云其他云服务上进行存储和处理，消息下发用于平台向设备下发消息，设备对收到的消息进行处理。                                                             |
| [属性上报、设置、查询](#3.4) | 属性上报用于设备按产品模型中定义的格式将属性数据上报给平台。属性设置用于平台设置设备属性。设备收到属性设置请求后，需要将执行结果返回给平台。属性查询用于平台查询设备的属性，设备收到属性查询请求后，需要将设备的属性数据返回给平台                                 |
| [命令下发](#3.5)             | 用于平台向设备下发设备控制命令。平台下发命令后，需要设备及时将命令的执行结果返回给平台。                                                                                                      |
| [获取设备影子](#3.6)         | 用于设备向平台获取设备影子数据。                                                                                                                                  |
| [面向物模型编程](#3.13)      | 面向物模型编程指的是，基于SDK提供的物模型抽象能力，设备代码只需要按照物模型定义设备服务，SDK就能自动的和平台通讯，完成属性的同步和命令的调用。<br/>相比直接调用客户端接口和平台进行通讯，面向物模型编程简化了设备侧代码的复杂度，让设备代码只需要关注业务，而不用关注和平台的通讯过程。 |


# 3.SDK功能

- 为方便用户体验，以下介绍SDK功能及Demo演示时，均使用烟感的产品模型，烟感会上报烟雾值，温度，湿度，烟雾报警，还支持响铃报警命令。
- 您可以在[华为云设备接入](https://console.huaweicloud.com/iotdm)创建产品，将[烟感模型](https://iot-developer.obs.cn-north-4.myhuaweicloud.com:443/smokeDetector.zip)导入，并创建设备，体验以下功能。
- Demo均可以使用模拟器运行，可参考[使用模拟器运行应用/元服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-run-emulator-V5)。

<h2 id="3.0">设备初始化</h2>

创建设备并初始化


- 设备密钥认证：
```arkts
// 用户请替换为自己的接入地址, 设备ID，设备密钥及证书路径。（证书文件放在resource/resfile下，连接华为云时请使用对应的证书）。
const device = new IoTDevice("ssl://xxx.st1.iotda-device.cn-north-4.myhuaweicloud.com:8883", "deviceId", "mysecret", "caFilePath");
// 使用异步方式初始化
this.device.init().then((data: boolean) => {
  // 连接成功处理
}).catch((err: string) => {
  // 连接失败处理
})
// 或使用同步方式初始化
// await this.device.init();
```

<h2  id  =  "3.1">3.1 自定义选项</h2>
设备初始化前，可以通过CustomOptions类配置自定义断线重连、离线最大缓存消息数量、正在传输但还未收到确认的消息数量等功能。

```arkts
device.customOptions: CustomOptions = customOptions;
// reConnect 是否使用内置的断线重连功能， 默认为true
// customBackoffHandler 用户自定义断线重连功能，设置后，将覆盖内置的断线重连功能
// backoff 内置断线重连功能退避系数，默认为1000，单位毫秒
// minBackoff 内置断线重连功能最小重连时间，默认为1000，单位毫秒
// maxBackoff 内置断线重连功能最大重连时间，默认为0 * 1000，单位毫秒
// maxInflight 正在传输但还未收到确认的消息数量，默认为65535
// offlineBufferSize 离线消息缓存队列大小，默认5000
// connectListener 连接监听器，监听设备的连接状态
```


<h2  id  =  "3.2">3.2  断线重连</h2>
在SDK中内置了一个断线重连，若需要自定义断线重连，可以重写SDK：src/main/ets/client/handler/CustomBackoffHandler.ets中backoffHandler方法。自定义断线重连可见demo：src/main/ets/pages/ReConnectSample.ets（Demo展示了连接成功后设置断线重连的方式，您也可以在连接之前设置）。

默认断线重连为每隔一段时间进行一次重连。主要参数如下，可以通过修改最大、最小重连间隔时间实现重连控制。

```arkts
  static readonly DEFAULT_BACKOFF = 1000;

  static readonly MIN_BACKOFF = 1000;

  static readonly MAX_BACKOFF = 30 * 1000;

```

值得注意的是，建议在断线重连后，在建链成功回调中进行设备订阅，以免重连后订阅丢失。
可以参考src/main/ets/pages/MessageSample.ets中设置connectionListener的方法。

```arkts
  ......
  // 设置连接监听器，断线重连处理以及重新连接成功处理
  this.device.client.connectionListener = this.getConnectionListener();
  ......

  private getConnectionListener() {
    let connectionListener: ConnectListener = {
      connectionLost: (): void => {
        // 断线后有默认处理，也可以增加自己的处理逻辑
        LogUtil.error(TAG, `connectionLost`);
      },
      connectComplete: (): void => {
        // 连接成功后，自动重新订阅Topic
        if (!this.ocTopicListener && !this.helloWorldTopicListener) {
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
      LogUtil.info(TAG, `resubscribe topic success ${JSON.stringify(data)}`);
    }).catch((err: IoTMqttResponse | string) => {
      LogUtil.error(TAG, `resubscribe topic(${topic}) failed ${JSON.stringify(err)}`);
    })
  }
```


<h2  id  =  "3.3">3.3  消息上报、下发</h2>
示例代码可见：MessageSample.ets。

- 上报设备消息（系统topic）

  ```arkts
  const reportMessage: DeviceMessage = { content: this.message }
  this.device.client.reportDeviceMessage(reportMessage)
    .then((data: IoTMqttResponse) => {
      LogUtil.info(TAG, `report deviceMessage success ${JSON.stringify(data)}`);
    })
    .catch((error: IoTMqttResponse | string) => {
      LogUtil.error(TAG, `report deviceMessage failed ${JSON.stringify(error)}`);
    })
  ```

- 上报自定topic消息（可用设备topic策略控制权限）

  ```arkts
  const topic = "hello/world";
  const rawMessage: RawMessage = {
    topic: topic,
    qos: 0,
    payload: this.message
  }
  this.device.client.publishRawMessage((rawMessage))
    .then((data: IoTMqttResponse) => {
      LogUtil.info(TAG, `report rawMessage success ${JSON.stringify(data)}`);
    })
    .catch((error: IoTMqttResponse | string) => {
      LogUtil.error(TAG, `report rawMessage failed ${JSON.stringify(error)}`);
    })
  ```



- 上报自定义topic消息（注意需要先在平台配置自定义topic）

  ```arkts
  const topic = `$oc/devices/${this.device?.deviceId}/user/test`;
  const rawMessage: RawMessage = {
    topic: topic,
    qos: 0,
    payload: this.message
  }
  this.device.client.publishRawMessage((rawMessage))
    .then((data: IoTMqttResponse) => {
      LogUtil.info(TAG, `report rawMessage success ${JSON.stringify(data)}`);
    })
    .catch((error: IoTMqttResponse | string) => {
      LogUtil.error(TAG, `report rawMessage failed ${JSON.stringify(error)}`);
    })
  ```

- 设备收到平台下发的消息（系统topic）

  ```arkts
  // 接收平台下行消息
  // 设置系统topic消息的监听处理
  let rawDeviceMessageListener: RawDeviceMessageListener = {
    onRawDeviceMessage: (rawDeviceMessage: RawDeviceMessage): void => {
      LogUtil.info(TAG, `reveived device message is ${JSON.stringify(rawDeviceMessage)}`);
    }
  }
  this.device.client.rawDeviceMessageListener = rawDeviceMessageListener;
  ```

- 订阅自定义topic, 系统topic由SDK自动订阅，此接口只能用于订阅自定义topic

  ```arkts
  // 配置了断线重连功能时，需要在自定义选项CustomOptions中配置connectListener，并在connectComplete方法中订阅自定义topic
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
  this.device.client.subscribeTopic(topic, rawMessageListener).then((data: IoTMqttResponse) => {
    LogUtil.info(TAG, `subscribe topic success ${JSON.stringify(data)}`);
  }).catch((err: IoTMqttResponse) => {
    LogUtil.error(TAG, `subscribe topic failed ${JSON.stringify(err)}`);
  })
  ```



<h2  id  =  "3.4">3.4 属性上报、设置、查询</h2>
示例代码可见：PropertySample.ets。

- 设备属性上报

  ```arkts
  // 按照物模型设置属性
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
  this.device.client.reportProperties(properties)
    .then((data: IoTMqttResponse) => {
      LogUtil.info(TAG, `report properties success ${JSON.stringify(data)}`);
    })
    .catch((error: IoTMqttResponse | string) => {
      LogUtil.error(TAG, `report properties failed ${JSON.stringify(error)}`);
    })
  ```

- 平台设置设备属性和查询设备属性

  ```arkts
  // 接收平台下发的属性读写
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
      this.device.client.respondPropsSet(requestId, IotResult.SUCCESS);
    },

    /**
     * 处理读属性。多数场景下，用户可以直接从平台读设备影子，此接口不用实现。
     * 但如果需要支持从设备实时读属性，则需要实现此接口。
     */
    onPropertiesGet: (requestId: string, serviceId: string): void => {
      LogUtil.info(TAG, `onPropertiesGet, the serviceId is ${serviceId}` );
       const serviceProperties: ServiceProperty[] = [
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
      this.device.client.respondPropsGet(requestId, serviceProperties);
    }
  }
  ```

<h2  id  =  "3.5">3.5  命令下发</h2>
示例代码可见SDK：CommandSample.ets。

```arkts
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
      }).catch((err: IoTMqttResponse | string) => {
        LogUtil.error(TAG, `respond command failed ${JSON.stringify(err)}`);
      })
    }
  }
  this.device.client.commandListener = commandListener;
```

<h2  id  =  "3.6">3.6  获取设备影子</h2>
示例代码可见SDK：ShadowSample.ets。

```arkts
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
```


<h2  id  =  "3.13">3.13  面向物模型编程</h2>
面向物模型编程指的是，基于SDK提供的物模型抽象能力，设备代码只需要按照物模型定义设备服务，SDK就能自动的和平台通讯，完成属性的同步和命令的调用。
相比直接调用客户端接口和平台进行通讯，面向物模型编程简化了设备侧代码的复杂度，让设备代码只需要关注业务，而不用关注和平台的通讯过程。


首先定义一个烟感服务类，继承自AbstractService。
```arkts
   class SmokeDetector extends AbstractService  {
   }

```
定义服务属性，私有变量以下划线开头，注解中name和产品模型中属性名保持一致。writeable用来标识属性是否可写
```arkts
    @Reflect.metadata("Property", { name: "alarm", writeable: true })
    private _smokeAlarm: number = 1;

    @Reflect.metadata("Property", { name: "smokeConcentration", writeable: false })
    private _concentration: number = 0;

    @Reflect.metadata("Property", { name: "humidity", writeable: false })
    private _humidity: number = 0;

    @Reflect.metadata("Property", { name: "temperature", writeable: false })
    private _temperature: number = 10;
```

定义属性的读写接口：
getter接口为读接口，在属性上报和平台主动查属性时被sdk调用
setter接口为写接口，在平台修改属性时被sdk调用，如果属性是只读的，则setter接口保留空实现。
setter和getter接口使用DevEco Studio右键的Generate的Getter and Setter自动生成，然后修改方法实现
```arkts	
  public set smokeAlarm(value: number) {
    this._smokeAlarm = value;
    if (value == 0) {
      LogUtil.info(TAG, "alarm is cleared by app");
    }
  }

  public get smokeAlarm(): number {
    return this._smokeAlarm;
  }

  public set concentration(value: number) {
    // 只读字段不需要实现set接口
  }

  public get concentration(): number {
    return Math.floor(Math.random() * 100);
  }

  public set humidity(value: number) {
    // 只读字段不需要实现set接口
  }

  public get humidity(): number {
    return Math.floor(Math.random() * 100);
  }
  
  public set temperature(value: number) {
    // 只读字段不需要实现set接口
  }

  public get temperature(): number {
    return Math.floor(Math.random() * 100);
  }  

```

定义服务的命令：
注解中name对应物模型的command_name
method对应接收命令的处理方法，命令的入参和返回值类型固定不能修改。

```arkts	

 @Reflect.metadata("DeviceCommand", {
    name: "ringAlarm",
    method: (paras: object): CommandRsp => {
      let duration: number = paras['duration'];
      LogUtil.log(TAG, `duration is ${duration}`);
			return IotResult.SUCCESS;
		}
  })
  private _alarm: Function = () => {};
```

上面完成了服务的定义
接下来创建设备，注册烟感服务，然后初始化设备：
```arkts
   //创建设备服务
   const smokeDetector = new SmokeDetector();
   this.device.addService("smokeDetector", smokeDetector);


```

启动服务属性自动周期上报
```arkts
   smokeDetector.enableAutoReport(10000);
```

## 4. License

SDK的开源License类型为 [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause)。详情参见LICENSE.txt

## 5. 如何贡献代码

1、创建github账号
2、fork huaweicloud-iot-device-sdk-arkts源代码
3、同步huaweicloud-iot-device-sdk-arkts主仓库代码到fork的仓库
4、在本地修改代码并push到fork的仓库
5、在fork的仓库提交pull request到主仓库
