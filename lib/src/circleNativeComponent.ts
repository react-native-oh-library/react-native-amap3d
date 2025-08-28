import * as React from "react";
import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float,Int32 } from "react-native/Libraries/Types/CodegenTypes";

    type LatLng = Readonly<{
        latitude: Float;
        longitude: Float;
    }>

export interface CircleProps extends ViewProps {
  /**
   * 圆点坐标
   */
  center: LatLng;

  /**
   * 半径（米）
   */
  radius: Float;

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

export default codegenNativeComponent<CircleProps>("AMapCircle")as HostComponent<CircleProps>; 
