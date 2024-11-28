import { ClientConf, IoTMqttQos } from "./ClinetConf";
import { CommandListener } from "./listener/CommandListener";
import { DeviceMessageListener } from "./listener/DeviceMessageListener";
import { PropertyListener } from "./listener/PropertyListener";
import { RawDeviceMessageListener } from "./listener/RawDeviceMessageListener";
import { ShadowListener } from "./listener/ShadowListener";
import { HashMap } from "@kit.ArkTS";
import { CustomOptions } from "./CustomOptions";
import { AbstractDevice } from "../service/AbstractDevice";
import { RawMessageListener } from "./listener/RawMessageListener";
import { MessageReceivedHandler } from "./handler/MessageReceivedHandler";
import { MqttAsync, MqttClient, MqttConnectOptions, MqttMessage, MqttSubscribeOptions,} from "@ohos/mqtt";
import { ConnectListener } from "./listener/ConnectionListener";
import { MessageHandler } from "./handler/MessageHandler";
import { CommandHandler } from "./handler/CommandHandler";
import { PropertySetHandler } from "./handler/PropertySetHandler";
import { PropertyGetHandler } from "./handler/PropertyGetHandler";
import { ShadowResponseHandler } from "./handler/ShadowResponseHandler";
import { EventDownHandler } from "./handler/EventDownHandler";
import { ShadowHandler } from "./handler/ShadowHandler";
import { IotUtil } from "../utils/IotUtil";
import { RawMessage } from "../requests/RawMessage";
import { DeviceEvent } from "../requests/DeviceEvent";
import { IoTMqttResponse } from "./IoTMqttResponse";
import CryptoJS from "@ohos/crypto-js";
import { IoTMqttPublishOptions } from "./IoTMqttPublishOptions";
import { ServiceProperty } from "../requests/ServiceProperty";
import { DeviceMessage } from "../requests/DeviceMessage";
import { DeviceEvents } from "../requests/DeviceEvents";
import { CommandRsp } from "../requests/CommandRsp";
import { DeviceProperties } from "../requests/DeviceProperties";
import { IotResult } from "./IotResult";

export class DeviceClient {

  private static readonly SDK_VERSION = "ARKTS_v0.0.1";

  private static readonly MESSAGE_DOWN_TOPIC = "/messages/down";

  private static readonly COMMAND_DOWN_TOPIC = "/sys/commands/request_id";

  private static readonly PROPERTY_SET_TOPIC = "/sys/properties/set/request_id";

  private static readonly PROPERTY_GET_TOPIC = "/sys/properties/get/request_id";

  private static readonly SHADOW_RESPONSE_TOPIC = "/desired/properties/get/response";

  private static readonly SHADOW_GET_RESPONSE_TOPIC = "/sys/shadow/get/response/request_id";

  private static readonly EVENT_DOWN_TOPIC = "/sys/events/down";

  private _propertyListener: PropertyListener | null = null;

  /**
   * 设置属性监听器，用于接收平台下发的属性读写。
   * 此监听器只能接收平台到直连设备的请求，子设备的请求由AbstractGateway处理
   *
   * @param propertyListener 属性监听器
   */
  public set propertyListener(value: PropertyListener | null) {
    this._propertyListener = value;
  }

  public get propertyListener(): PropertyListener | null {
    return this._propertyListener;
  }

  private _commandListener: CommandListener | null = null;

  /**
   * 设置命令监听器，用于接收平台下发的命令。
   * 此监听器只能接收平台到直连设备的请求，子设备的请求由AbstractGateway处理
   *
   * @param commandListener 命令监听器
   */
  public set commandListener(value: CommandListener | null) {
    this._commandListener = value;
  }

  public get commandListener(): CommandListener | null {
    return this._commandListener;
  }

  private _shadowListener: ShadowListener | null = null;

  /**
   * 设置设备影子监听器，用于接收设备侧请求平台下发的设备影子数据。
   * 此监听器只能接收平台到直连设备的请求，子设备的请求由AbstractGateway处理
   * @param shadowListener 设备影子监听器
   */
  public set shadowListener(value: ShadowListener | null) {
    this._shadowListener = value;
  }

  public get shadowListener(): ShadowListener | null {
    return this._shadowListener;
  }

  private _deviceMessageListener: DeviceMessageListener | null = null;

  /**
   * 设置消息监听器，用于接收平台下发的消息
   * 此监听器只能接收平台到直连设备的请求，子设备的请求由AbstractGateway处理
   * @param deviceMessageListener 消息监听器
   * @deprecated 该方法不能处理云端下发的任意格式的消息，请使用setRawDeviceMessageListener代替
   */
  public set deviceMessageListener(value: DeviceMessageListener | null) {
    this._deviceMessageListener = value;
  }

  public get deviceMessageListener(): DeviceMessageListener | null {
    return this._deviceMessageListener;
  }

  private _rawDeviceMessageListener: RawDeviceMessageListener | null = null;

  /**
   * 设置消息监听器，用于接收平台下发的消息
   * 此监听器只能接收平台到直连设备的请求，子设备的请求由AbstractGateway处理
   *
   * @param rawDeviceMessageListener 消息监听器
   */
  public set rawDeviceMessageListener(value: RawDeviceMessageListener | null) {
    this._rawDeviceMessageListener = value;
  }

  public get rawDeviceMessageListener(): RawDeviceMessageListener | null {
    return this._rawDeviceMessageListener;
  }

  private _connectionListener: ConnectListener | null = null;

  /**
   * 设置链路监听器，用户接收链路断开事件
   *
   * @param connectLostListener
   */
  public set connectionListener(value: ConnectListener | null) {
    this._connectionListener = value;
  }

  public get connectionListener(): ConnectListener | null {
    return this._connectionListener;
  }

  private _rawMessageListenerMap: Map<String, RawMessageListener>;

  public set rawMessageListenerMap(value: Map<String, RawMessageListener>) {
    this._rawMessageListenerMap = value;
  }

  public get rawMessageListenerMap(): Map<String, RawMessageListener> {
    return this._rawMessageListenerMap;
  }

  private _functionMap: HashMap<string, MessageReceivedHandler> = new HashMap();

  /**
   * 设置各类topic处理的handler
   *
   * @param functionMap 各类topic处理的handler
   */
  public set functionMap(value: HashMap<string, MessageReceivedHandler>) {
    this._functionMap = value;
  }

  /**
   * 获取各类topic处理的handler
   *
   * @return 各类topic处理的handler
   */
  public get functionMap(): HashMap<string, MessageReceivedHandler> {
    return this._functionMap;
  }

  private _customOptions: CustomOptions = new CustomOptions();

  public set customOptions(value: CustomOptions) {
    this._customOptions = value;
  }

  public get customOptions(): CustomOptions {
    return this._customOptions;
  }

  private _mqttClient: MqttClient | null = null;

  public set mqttClient(value: MqttClient | null) {
    this._mqttClient = value;
  }

  public get mqttClient(): MqttClient | null {
    return this._mqttClient;
  }

  private _clientConf: ClientConf;

  public set clientConf(value: ClientConf) {
    this._clientConf = value;
  }

  public get clientConf(): ClientConf {
    return this._clientConf;
  }

  private _device: AbstractDevice;

  public set device(value: AbstractDevice) {
    this._device = value;
  }

  public get device(): AbstractDevice {
    return this._device;
  }

  constructor(clientConf: ClientConf, device: AbstractDevice) {
    this.checkClientConf(clientConf);
    this._clientConf = clientConf;
    this._device = device;

    this._rawMessageListenerMap = new Map();
    // 系统Topic处理方法
    this.functionMap.set(DeviceClient.MESSAGE_DOWN_TOPIC, new MessageHandler(this));
    this.functionMap.set(DeviceClient.COMMAND_DOWN_TOPIC, new CommandHandler(this));
    this.functionMap.set(DeviceClient.PROPERTY_SET_TOPIC, new PropertySetHandler(this));
    this.functionMap.set(DeviceClient.PROPERTY_GET_TOPIC, new PropertyGetHandler(this));
    this.functionMap.set(DeviceClient.SHADOW_RESPONSE_TOPIC, new ShadowResponseHandler(this));
    this.functionMap.set(DeviceClient.EVENT_DOWN_TOPIC, new EventDownHandler(this));
    this.functionMap.set(DeviceClient.SHADOW_GET_RESPONSE_TOPIC, new ShadowHandler(this));
  }

  async connect(): Promise<boolean>{
    return new Promise(async (resolve, reject) => {
      const timestamp = IotUtil.getTimestamp();
      this.createMqtt(this.clientConf.serverUri, this.generateClientId(timestamp))
      if (this.mqttClient === null) {
        reject("mqttClient is null");
        return;
      }
      try {
        const options: MqttConnectOptions = {
          keepAliveInterval: 60,
          userName: this.device.deviceId,
          password: this.generatePassword(timestamp),
          connectTimeout: 30,
          MQTTVersion: 0,
          sslOptions: {
            enableServerCertAuth: true,
            trustStore: `${getContext().resourceDir}/${this.clientConf.caFilePath ?? 'GlobalSign-rootca.pem'}`
          }
        }
        if (this.clientConf.serverUri.startsWith("tcp://")) {
          options.sslOptions = {
            enableServerCertAuth: false,
          }
        }
        let result = await this.mqttClient.connect(options);
        console.log("connect result is ", JSON.stringify(result));
        if (await this.mqttClient.isConnected()) {
          // 监听接收消息
          this.messageArrived();
          // 监听断链
          this.connectLost();
          // 上报设备信息
          this.reportDeviceInfo(null, null);
          resolve(true);
          return;
        }
      } catch (err) {
        console.log("mqtt connect failed ", JSON.stringify(err))
        reject(err);
        return;
      }
    })
  }

  disconnect(): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    return this.mqttClient.disconnect();
  }

  destroy(): Promise<boolean> {
    if (!this.mqttClient) {
      return new Promise<boolean>((resolve, reject) => reject("mqtt client is null"));
    }
    return this.mqttClient.destroy();
  }

  isConnected(): Promise<boolean> {
    if (!this.mqttClient) {
      return new Promise<boolean>((resolve, reject) => resolve(false));
    }
    return this.mqttClient.isConnected();
  }

  publish(publishOption: IoTMqttPublishOptions): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    return this.mqttClient.publish(publishOption);
  }

  /**
   * 上报设备属性
   * @param properties 设备属性列表
   * @param qos        qos
   * @returns
   */
  reportProperties(properties: ServiceProperty[], qos: IoTMqttQos = 0) : Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const publishOption: IoTMqttPublishOptions = {
      topic: `$oc/devices/${this.clientConf.deviceId}/sys/properties/report`,
      qos: qos,
      payload: JSON.stringify({services: properties})
    }
    return this.publish(publishOption);
  }

  /**
   * 上报设备消息
   * @param deviceMessage 设备消息
   * @param qos           qos
   * @returns
   */
  reportDeviceMessage(deviceMessage: DeviceMessage, qos: IoTMqttQos = 0) : Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const publishOption: IoTMqttPublishOptions = {
      topic: `$oc/devices/${this.clientConf.deviceId}/sys/messages/up`,
      qos: qos,
      payload: JSON.stringify(deviceMessage)
    }
    return this.publish(publishOption);
  }

  /**
   * 上报事件
   * @param event
   * @param qos
   * @returns
   */
  reportEvent(event: DeviceEvent, qos: IoTMqttQos = 0) : Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const deviceEvents: DeviceEvents = {
      object_device_id: this.clientConf.deviceId,
      services: [event]
    }
    const publishOption: IoTMqttPublishOptions = {
      topic: `$oc/devices/${this.clientConf.deviceId}/sys/events/up`,
      qos: qos,
      payload: JSON.stringify(deviceEvents)
    }
    return this.publish(publishOption);
  }

  /**
   * 发布原始消息，原始消息和设备消息（DeviceMessage）的区别是：
   * 1、可以自定义topic，该topic需要在平台侧配置
   * 2、不限制payload的格式
   *
   * @param rawMessage 原始消息
   * @param qos
   */
  publishRawMessage(rawMessage: RawMessage, qos: IoTMqttQos = 0): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const publishOption: IoTMqttPublishOptions = {
      topic: rawMessage.topic,
      qos: qos,
      payload: rawMessage.payload
    }
    return this.publish(publishOption);
  }

  /**
   * 上报命令响应
   *
   * @param requestId  请求id，响应的请求id必须和请求的一致
   * @param commandRsp 命令响应
   * @param qos
   */
  respondCommand(requestId: string, commandRsp: CommandRsp, qos: IoTMqttQos = 0): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const topic = `$oc/devices/${this.clientConf.deviceId}/sys/commands/response/request_id=${requestId}`;
    const publishOption: IoTMqttPublishOptions = {
      topic: topic,
      qos: qos,
      payload: JSON.stringify(commandRsp)
    }
    return this.publish(publishOption);
  }

  /**
   * 上报读属性响应
   *
   * @param requestId 请求id，响应的请求id必须和请求的一致
   * @param services  服务属性
   * @param qos
   */
  respondPropsGet(requestId: string, services: ServiceProperty[], qos: IoTMqttQos = 0): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }

    const deviceProperties: DeviceProperties = {
      services: services
    }
    const topic = `$oc/devices/${this.clientConf.deviceId}/sys/properties/get/response/request_id=${requestId}}`;
    const publishOption: IoTMqttPublishOptions = {
      topic: topic,
      qos: qos,
      payload: JSON.stringify(deviceProperties)
    }
    return this.publish(publishOption);
  }

  /**
   * 上报写属性响应
   *
   * @param requestId 请求id，响应的请求id必须和请求的一致
   * @param iotResult 写属性结果
   * @param qos
   */
  respondPropsSet(requestId: string, iotResult: IotResult, qos: IoTMqttQos = 0): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const topic = `$oc/devices/${this.clientConf.deviceId}/sys/properties/set/response/request_id=${requestId}`;
    const publishOption: IoTMqttPublishOptions = {
      topic: topic,
      qos: qos,
      payload: JSON.stringify(iotResult)
    }
    return this.publish(publishOption);
  }

  /**
   * 订阅自定义topic。系统topic由SDK自动订阅，此接口只能用于订阅自定义topic
   *
   * @param topic              自定义topic
   * @param rawMessageListener 接收自定义消息的监听器
   * @param qos                qos
   */
  subscribeTopic(topic: string, rawMessageListener: RawMessageListener, qos: IoTMqttQos = 1): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    this.rawMessageListenerMap.set(topic, rawMessageListener);
    return this.subscribe(topic, qos);
  }


  private checkClientConf(clientConf: ClientConf) {
    if (clientConf == null) {
      throw new Error("clientConf is null");
    }
    if (clientConf.deviceId == null) {
      throw new Error("clientConf.deviceId is null");
    }
    if (clientConf.secret == null) {
      throw new Error("secret and keystore is null");
    }
    if (clientConf.serverUri == null) {
      throw new Error("clientConf.getServerUri() is null");
    }
    if (!clientConf.serverUri.startsWith("tcp://") && (!clientConf.serverUri.startsWith("ssl://"))) {
      throw new Error("invalid serverUri");
    }
  }

  /**
   * 接收消息处理
   */
  private messageArrived() {
    this.mqttClient?.messageArrived((err: Error, message: MqttMessage) => {
      const rawMessage: RawMessage = {
        topic: message.topic,
        qos: message.qos,
        payload: message.payload
      }
      const topic = rawMessage.topic;
      const listener =this.rawMessageListenerMap.get(topic);
      if (listener) {
        // 订阅了自定义topic
        listener.onMessageReceived(rawMessage);
        return;
      }
      this.functionMap.forEach((value: MessageReceivedHandler, key: string) => {
        if (topic.indexOf(key) > -1) {
          value.messageHandler(rawMessage);
        }
      })
    })
  }

  private reportDeviceInfo(swVersion: string | null, fwVersion: string | null, qos: IoTMqttQos = 1) {
    const deviceEvent: DeviceEvent = {
      service_id: "$sdk_info",
      event_type: "sdk_info_report",
      event_time: (new Date()).toISOString(),
      paras: {
        device_sdk_version: DeviceClient.SDK_VERSION,
        sw_version: swVersion,
        fw_version: fwVersion
      }
    }
    this.reportEvent(deviceEvent, qos);
  }

  private subscribe(topic: string, qos: IoTMqttQos = 1): Promise<IoTMqttResponse> {
    if (!this.mqttClient) {
      return new Promise<IoTMqttResponse>((resolve, reject) => reject("mqtt client is null"));
    }
    const subscribeOption: MqttSubscribeOptions = {
      topic: topic,
      qos: qos
    }
    return this.mqttClient.subscribe(subscribeOption);
  }

  private connectLost() {
    this.mqttClient?.connectLost(async (err: Error, data: IoTMqttResponse) => {
      console.log("connection lost");
      if (this.connectionListener !== null) {
        this.connectionListener.connectionLost();
      }
      // 自定义断线重连
      if (this.customOptions.customBackoffHandler !== null) {
        this.customOptions.customBackoffHandler.backoffHandler();
        return;
      }

      // 不自动重连
      if (!this.customOptions.reConnect) {
        return;
      }

      await this.reconnect();
    })
  }

  private async reconnect(retryTimes: number = 0) {
    const waitTImeUntilNextRetry = this.getWaitTImeUntilNextRetry(retryTimes);
    await this.sleep(waitTImeUntilNextRetry);
    if (await this.mqttClient?.reconnect()) {
      console.log("reconnect success");
      return;
    }
    retryTimes++;
    await this.reconnect(retryTimes);
  }

  private getWaitTImeUntilNextRetry(retryTimes: number) {
    const lowBound = this.customOptions.backoff * 0.8;
    const highBound = this.customOptions.backoff * 1;
    const randomBackOff = Math.floor(Math.random() * (highBound - lowBound));
    const powParameter = retryTimes & 0x0F;
    const backOffWithJitter = (Math.pow(2.0, powParameter) * (randomBackOff + lowBound));
    return Math.min(this.customOptions.minBackoff + backOffWithJitter, this.customOptions.maxBackoff);
  }

  private async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private generateClientId(timestamp: string): string {
    return `${this.device.deviceId}_0_0_${timestamp}`;
  }

  private generatePassword(timestamp: string): string {
    const password: string= CryptoJS.HmacSHA256(
      this.clientConf.secret,
      timestamp
    ).toString();
    return password;
  }

  private createMqtt(url: string, clientId: string) : void {
    this.mqttClient = MqttAsync.createMqtt({
      url: url,
      clientId: clientId,
      persistenceType: 1
    })
  }

}