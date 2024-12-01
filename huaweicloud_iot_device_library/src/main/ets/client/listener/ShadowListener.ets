import { ShadowData } from "../../requests/ShadowData";

/**
 * 设备影子监听器，用于设备向平台获取设备影子数据
 */
export interface ShadowListener {
  /**
   *
   * @param requestId       请求id
   * @param shadowDataList  服务影子数据
   */
  onShadow: (requestId: string, shadowDataList?: ShadowData[]) => void;
}
