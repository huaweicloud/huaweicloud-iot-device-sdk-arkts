export class IotUtil {

  static readonly DEFAULT_BACKOFF = 1000;

  static readonly MIN_BACKOFF = 1000;

  static readonly MAX_BACKOFF = 30 * 1000;

  public static getRequestId(topic: string) {
    if (!topic || topic.indexOf("request_id=") < 0) {
      return "";
    }
    return topic.split("request_id=")[1];
  }

  public static getTimestamp(): string {
    return (new Date()).toISOString().replace(/[-:T]/g, "").substring(0, 10);
  }
}