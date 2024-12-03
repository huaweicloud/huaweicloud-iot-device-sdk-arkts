// Copyright 2024 Huawei Cloud IoT Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

export type IoTMqttQos = 0 | 1;

/**
 * 客户端配置
 */
export interface ClientConf {
  /**
   * 设备id，在平台注册设备获得，生成规则：productId_nodeId
   */
  deviceId: string;

  /**
   * 设备密码，使用密码认证时填写
   */
  secret: string;

  /**
   * 设备接入平台地址，比如tcp://localhost:1883 或者 ssl://localhost:8883
   */
  serverUri: string;

  /**
   * 协议类型，当前仅支持mqtt
   */
  protocol?: string;

  /**
   * 离线消息缓存队列大小，默认5000，仅MQTT协议支持
   */
  offlineBufferSize?: number;

  /**
   * 客户端qos，0或1，默认1，仅MQTT协议支持
   */
  qos?: IoTMqttQos;

  /**
   * 0代表直连方式，3代表网桥方式(跟平台保持一致)。默认是0
   */
  mode?: number;

  /**
   * iot平台的ca证书路径，用于设备侧校验平台（resfile文件夹下）
   */
  caFilePath?: string;
}