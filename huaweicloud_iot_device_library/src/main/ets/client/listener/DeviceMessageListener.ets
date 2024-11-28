import { DeviceMessage } from "../../requests/DeviceMessage";

/**
 * 设备消息监听器，用于接收平台下发的设备消息
 */
export interface DeviceMessageListener {
  /**
   * 处理平台下发的设备消息
   *
   * @param deviceMessage 设备消息内容
   */
  onDeviceMessage: (deviceMessage: DeviceMessage) => void;
}