import { AbstractDevice } from './service/AbstractDevice'

export class IoTDevice extends AbstractDevice {
  constructor(serverUri: string, deviceId: string, deviceSecret:string, caFilePath?: string) {
    super(serverUri, deviceId, deviceSecret, caFilePath);
  }
}