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

export class IoTUtil {
  static readonly DEFAULT_BACKOFF = 1000;

  static readonly MIN_BACKOFF = 1000;

  static readonly MAX_BACKOFF = 30 * 1000;

  public static isExistData(value: Object | undefined): boolean {
    return value !== null && value !== undefined;
  }

  public static getRequestId(topic: string): string {
    if (!topic || topic.indexOf("request_id=") < 0) {
      return "";
    }
    return topic.split("request_id=")[1];
  }

  public static getTimestamp(): string {
    return (new Date()).toISOString().replace(/[-:T]/g, "").substring(0, 10);
  }

  public static getEventTimestamp(): string {
    return `${(new Date()).toISOString().replace(/[-:]/g, "").substring(0, 15)}Z`;
  }

  public static mapToJson(map: Map<string, Object>) {
    let jsonObject: Record<string, Object> = {};
    map.forEach((value, key) => {
      if (key !== undefined && value !== undefined) {
        jsonObject[key] = value;
      }
    })
    return jsonObject;
  }
}