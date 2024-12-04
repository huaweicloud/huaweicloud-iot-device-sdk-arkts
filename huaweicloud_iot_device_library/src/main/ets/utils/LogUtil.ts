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

const TAG = "IoTDA_SDK#"

export class LogUtil {
  public static debug(msg: string): void {
    console.debug(`${TAG} ${msg}`);
  }

  public static log(msg: string): void {
    console.log(`${TAG} ${msg}`);
  }

  public static info(msg: string): void {
    console.info(`${TAG} ${msg}`);
  }

  public static warn(msg: string): void {
    console.warn(`${TAG} ${msg}`);
  }

  public static error(msg: string): void {
    console.error(`${TAG} ${msg}`);
  }
}
