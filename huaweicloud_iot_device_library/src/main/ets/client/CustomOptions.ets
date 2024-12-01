import { IoTUtil } from "../utils/IoTUtil";
import { CustomBackoffHandler } from "./handler/CustomBackoffHandler";

/**
 * 自定义连接选项
 */
export class CustomOptions {
  /**
   * 是否使用自动重连功能
   */
  private _reConnect: boolean = true;

  public set reConnect(value: boolean) {
    this._reConnect = value;
  }

  public get reConnect(): boolean {
    return this._reConnect;
  }

  /**
   * 退避系数， 默认为1000，单位毫秒
   */
  private _backoff: number = IoTUtil.DEFAULT_BACKOFF;

  public set backoff(value: number) {
    this._backoff = value;
  }

  public get backoff(): number {
    return this._backoff;
  }

  /**
   * 最小重连时间，默认为1000，单位毫秒
   */
  private _minBackoff: number = IoTUtil.MIN_BACKOFF;

  public set minBackoff(value: number) {
    this._minBackoff = value;
  }

  public get minBackoff(): number {
    return this._minBackoff;
  }

  /**
   * 最大重连时间，默认为30 * 1000，单位毫秒
   */
  private _maxBackoff: number = IoTUtil.MAX_BACKOFF;

  public set maxBackoff(value: number) {
    this._maxBackoff = value;
  }

  public get maxBackoff(): number {
    return this._maxBackoff;
  }

  private _customBackoffHandler: CustomBackoffHandler | null = null;

  public set customBackoffHandler(value: CustomBackoffHandler | null) {
    this._customBackoffHandler = value;
  }

  public get customBackoffHandler(): CustomBackoffHandler | null {
    return this._customBackoffHandler;
  }

  /**
   * 正在传输但还未收到确认的消息数量，默认为65535
   */
  private _maxInflight: number = 65534;

  public set maxInflight(value: number) {
    this._maxInflight = value;
  }

  public get maxInflight(): number {
    return this._maxInflight;
  }

  /**
   * 离线消息缓存队列大小，默认5000
   */
  private _offlineBufferSize: number = 5000;

  public set offlineBufferSize(value: number) {
    this._offlineBufferSize = value;
  }

  public get offlineBufferSize(): number {
    return this._offlineBufferSize;
  }
}
