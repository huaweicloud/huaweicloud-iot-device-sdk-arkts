import { IotResult } from "../client/IotResult";
import { Command } from "../requests/Command";
import { CommandRsp } from "../requests/CommandRsp";
import { DeviceEvent } from "../requests/DeviceEvent";

/**
 * 服务接口类
 */
export interface IService {
  /**
   * 读属性回调
   *
   * @param fields 指定读取的字段名，不指定则读取全部可读字段
   * @return 属性值，json格式
   */
  onRead(fields?: string[]): object;

  /**
   * 写属性回调
   *
   * @param properties 属性期望值
   * @return 操作结果jsonObject
   */
  onWrite(properties: object): IotResult;

  /**
   * 命令回调
   *
   * @param command 命令
   * @return 执行结果
   */
  onCommand(command: Command): CommandRsp;

  /**
   * 事件回调
   *
   * @param deviceEvent 事件
   */
  onEvent(deviceEvent: DeviceEvent): void;

}
