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

import { RawMessage } from "../../requests/RawMessage";
import { Shadow } from "../../requests/Shadow";
import { IoTUtil } from "../../utils/IoTUtil";
import { LogUtil } from "../../utils/LogUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";


export class ShadowHandler implements MessageReceivedHandler {
  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {
    const requestId = IoTUtil.getRequestId(message.topic);
    try {
      const shadow: Shadow = JSON.parse(message.payload);
      const shadowListener = this.deviceClient.shadowListener;
      if (shadowListener !== null && (shadow.object_device_id == null || shadow.object_device_id
        === this.deviceClient.device.deviceId)) {
        shadowListener.onShadow(requestId, shadow.shadow);
        return;
      }

      this.deviceClient.device.onShadow(requestId, shadow);
    } catch (e) {
      LogUtil.error("invalid shadow");
      return;
    }

  }
}