import * as React from "react";
import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float } from "react-native/Libraries/Types/CodegenTypes";

type LatLng = Readonly<{
    latitude: Float;
    longitude: Float;
}>

export interface HeatMapProps extends ViewProps {
  /**
   * 节点坐标
   */
  data: LatLng[];

  /**
   * 半径（米）
   */
  radius?: Float;

  /**
   * 透明度
   */
  opacity?: Float;
}


export default codegenNativeComponent<HeatMapProps>("AMapHeatMap") as HostComponent<HeatMapProps>; 

