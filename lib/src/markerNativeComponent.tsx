import * as React from "react";
// @ts-ignore
import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float , DirectEventHandler} from "react-native/Libraries/Types/CodegenTypes";

export type LatLng = Readonly<{
    latitude: Float;
    longitude: Float;
}>

type Point = Readonly<{
    x: Float;
    y: Float;
}>

type ImageSourcePropType = Readonly<{
    uri: string;
    width?: Float;
    height?: Float;
    scale?: Float;
    method?: string;
    body?: string;
    bundle?: string;
}>
  
export type voidEvent = Readonly<{}>

export interface MarkerProps {
  /**
   * 坐标
   */ 
  position: LatLng;

  /**
   * 图标
   */
  icon?: ImageSourcePropType;
  
  /**
   * 透明度 [0, 1]
   *
   * @platform android
   */
  opacity?: Float;

  /**
   * 是否可拖拽
   */
  draggable?: boolean;

  /**
   * 是否平贴地图
   *
   * @platform android
   */
  flat?: boolean;

  /**
   * 层级
   */
  zIndex?: Float;

  /**
   * 覆盖物锚点比例
   *
   * @link http://a.amap.com/lbs/static/unzip/Android_Map_Doc/3D/com/amap/api/maps/model/Marker.html#setAnchor-float-float-
   * @platform android
   */
  anchor?: Point;

  /**
   * 覆盖物偏移位置
   *
   * @link http://a.amap.com/lbs/static/unzip/iOS_Map_Doc/AMap_iOS_API_Doc_3D/interface_m_a_annotation_view.html#a78f23c1e6a6d92faf12a00877ac278a7
   * @platform ios
   */
  centerOffset?: Point;

  /**
   * 点击事件
   */
  onPress?: (DirectEventHandler<voidEvent>);

  /**
   * 拖放开始事件
   */
  onDragStart?: (DirectEventHandler<voidEvent>);

  /**
   * 拖放进行事件，类似于 mousemove，在结束之前会不断调用
   */
  onDrag?: (DirectEventHandler<voidEvent>);

  /**
   * 拖放结束事件
   */
  onDragEnd?: (DirectEventHandler<LatLng>);
}

export default codegenNativeComponent<MarkerProps>("AMapMarker") as HostComponent<MarkerProps>; 