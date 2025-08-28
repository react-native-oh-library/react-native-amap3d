import * as React from "react";
// @ts-ignore
import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float ,Int32, DirectEventHandler} from "react-native/Libraries/Types/CodegenTypes";

type LatLng = Readonly<{
    latitude: Float;
    longitude: Float;
}>

type ImageSourcePropType = Readonly<{
    uri: string;
    width?: Float;
    height?: Float;
    scale?: Float;
    method?: string;
    body?: string;
    //cache?: string;
    bundle?: string;
    //headers?: object;
}>

type onPressEvent = Readonly<{
    index: Int32;
}>


export interface MultiPointProps extends ViewProps{
  /**
   * 坐标点集合
   */
  items?: LatLng[];

  /**
   * 图标
   */
  icon?: ImageSourcePropType;

  /**
   * 点击事件
   */
  onPress?: (DirectEventHandler<onPressEvent>);
}


export default codegenNativeComponent<MultiPointProps>("AMapMultiPoint") as HostComponent<MultiPointProps>; 
