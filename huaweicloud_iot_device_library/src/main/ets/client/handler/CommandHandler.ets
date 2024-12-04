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

import { Command } from "../../requests/Command";
import { RawMessage } from "../../requests/RawMessage";
import { IoTUtil } from "../../utils/IoTUtil";
import { LogUtil } from "../../utils/LogUtil";
import { DeviceClient } from "../DeviceClient";
import { MessageReceivedHandler } from "./MessageReceivedHandler";

export class CommandHandler implements MessageReceivedHandler {
  private deviceClient: DeviceClient;

  constructor(deviceClient: DeviceClient) {
    this.deviceClient = deviceClient;
  }

  messageHandler(message: RawMessage): void {
    const requestId = IoTUtil.getRequestId(message.topic);
    try {
      const command: Command = JSON.parse(message.payload);
      const commandListener = this.deviceClient.commandListener;
      if (commandListener !== null
        && (command.object_device_id == null || command.object_device_id === this.deviceClient.device.deviceId)) {
        commandListener.onCommand(requestId, command.service_id, command.command_name, command.paras);
        return;
      }
      this.deviceClient.device.onCommand(requestId, command);
    } catch (e) {
      LogUtil.error("invalid command");
      return;
    }
  }
}
