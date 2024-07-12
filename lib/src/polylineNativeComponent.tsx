import * as React from "react";
import { ColorValue } from "react-native";

import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float , Int32,DirectEventHandler} from "react-native/Libraries/Types/CodegenTypes";

type LatLng = Readonly<{
    latitude: Float;
    longitude: Float;
}>

export type voidEvent = Readonly<{}>

export interface PolylineProps extends ViewProps{
  /**
   * 节点坐标
   */
  points: LatLng[];

  /**
   * 线段宽度
   */
  width?: Float;

  /**
   * 线段颜色
   */
  color?: string;

  /**
   * 层级
   */
  zIndex?: Int32;

  /**
   * 多段颜色
   */
  colors?: string[];

  /**
   * 是否使用颜色渐变
   */
  gradient?: boolean;

  /**
   * 是否绘制大地线
   */
  geodesic?: boolean;

  /**
   * 是否绘制虚线
   */
  dotted?: boolean;

  /**
   * 点击事件
   */
  onPress?: (DirectEventHandler<voidEvent>) ;
}


export default codegenNativeComponent<PolylineProps>("AMapPolyline") as HostComponent<PolylineProps>; 