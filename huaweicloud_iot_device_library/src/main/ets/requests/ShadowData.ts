import { PropertiesData } from "./PropertiesData";

export interface ShadowData {
  service_id: string;

  desired: PropertiesData;

  reported: PropertiesData;

  version: number;
}