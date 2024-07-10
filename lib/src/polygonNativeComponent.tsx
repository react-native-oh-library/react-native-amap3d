import * as React from "react";
import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float ,Int32} from "react-native/Libraries/Types/CodegenTypes";

type LatLng = Readonly<{
    latitude: Float;
    longitude: Float;
}>

export interface PolygonProps extends ViewProps {
  /**
   * 节点坐标
   */
  points: LatLng[];

  /**
   * 边线宽度
   */
  strokeWidth?: Float;

  /**
   * 边线颜色
   */
  strokeColor?: string;

  /**
   * 填充颜色
   */
  fillColor?: string;

  /**
   * 层级
   */
  zIndex?: Int32;
}

export default codegenNativeComponent<PolygonProps>("AMapPolygon")as HostComponent<PolygonProps>; 
