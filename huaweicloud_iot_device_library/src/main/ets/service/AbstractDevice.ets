import { ClientConf } from "../client/ClinetConf";
import { DeviceClient } from "../client/DeviceClient";
import { IotResult } from "../client/IotResult";
import { Command } from "../requests/Command";
import { DeviceEvents } from "../requests/DeviceEvents";
import { DeviceMessage } from "../requests/DeviceMessage";
import { PropsGet } from "../requests/PropsGet";
import { PropsSet } from "../requests/PropsSet";
import { Shadow } from "../requests/Shadow";

export class AbstractDevice {
  private _client: DeviceClient;

  public set client(value: DeviceClient) {
    this._client = value;
  }

  public get client(): DeviceClient {
    return this._client;
  }

  private _deviceId: string;

  public set deviceId(value: string) {
    this._deviceId = value;
  }

  public get deviceId(): string {
    return this._deviceId;
  }

  constructor(serverUri: string, deviceId: string, deviceSecret: string, caFilePath?: string) {
    this._deviceId = deviceId;
    const clientConf: ClientConf = {
      deviceId: deviceId,
      secret: deviceSecret,
      serverUri: serverUri,
      caFilePath: caFilePath
    }
    this._client = new DeviceClient(clientConf, this);
  }

  init() {
    return this.client.connect();
  }


  /**
    * 命令回调函数，由SDK自动调用
    *
    * @param requestId 请求id
    * @param command   命令
    */
  public onCommand(requestId: string, command: Command): void {
    // 默认返回成功，后续扩展
    this.client?.respondCommand(requestId, {result_code: 0})
  }

  /**
   * 属性设置回调，，由SDK自动调用
   *
   * @param requestId 请求id
   * @param propsSet  属性设置请求
   */
  public onPropertiesSet(requestId: string, propsSet: PropsSet): void{
    // 默认返回成功，后续扩展
    this.client.respondPropsSet(requestId, IotResult.SUCCESS);
  }

  /**
   * 属性查询回调，由SDK自动调用
   *
   * @param requestId 请求id
   * @param propsGet  属性查询请求
   */
  public onPropertiesGet(requestId: string, propsGet: PropsGet): void {
    // 默认返回空数组，后续实现
    let serviceProperties = [];
    this.client.respondPropsGet(requestId, serviceProperties);

  }

  /**
   * 事件回调，由SDK自动调用
   *
   * @param deviceEvents 设备事件
   */
  public onEvent(deviceEvents: DeviceEvents): void {

  }


  /**
   * 消息回调，由SDK自动调用
   *
   * @param message 消息
   */
  public onDeviceMessage(message: DeviceMessage): void {

  }

  /**
   * 影子回调函数，由SDK自动调用
   *
   * @param requestId 请求id
   * @param shadow   影子
   */
  public onShadow(requestId: string, shadow: Shadow): void {

  }


}