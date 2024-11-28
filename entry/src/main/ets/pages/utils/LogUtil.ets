const TAG = "IoTDA#"

export class LogUtil {
  public static debug(tag: string, msg: string): void {
    console.debug(`${TAG}${tag} ${msg}`);
  }

  public static log(tag: string, msg: string): void {
    console.log(`${TAG}${tag} ${msg}`);
  }

  public static info(tag: string, msg: string): void {
    console.info(`${TAG}${tag} ${msg}`);
  }

  public static warn(tag: string, msg: string): void {
    console.warn(`${TAG}${tag} ${msg}`);
  }

  public static error(tag: string, msg: string): void {
    console.error(`${TAG}${tag} ${msg}`);
  }
}