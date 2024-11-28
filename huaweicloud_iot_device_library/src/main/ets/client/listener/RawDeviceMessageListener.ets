import { RawDeviceMessage } from "../../requests/RawDeviceMessage";

/**
 * 设备消息监听器，用于接收平台下发的设备消息
 */
export interface RawDeviceMessageListener {

  /**
   * 处理平台下发的设备消息
   *
   * @param rawDeviceMessage 原始设备消息内容，
   */
  onRawDeviceMessage: (rawDeviceMessage: RawDeviceMessage) => void;
}
