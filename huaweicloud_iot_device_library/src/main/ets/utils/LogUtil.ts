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