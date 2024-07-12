import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

export interface Spec extends TurboModule {
  initSDK(sdk : string): void;
  getVersion(): Promise<string>;
}

export default TurboModuleRegistry.get<Spec>("AMapSdk");