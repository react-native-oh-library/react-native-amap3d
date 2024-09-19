import * as React from "react";
import {
    HostComponent,
    ViewProps,
} from "react-native";

import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"
import { Float, Int32, DirectEventHandler } from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeCommands from "react-native/Libraries/Utilities/codegenNativeCommands";


export type LatLng = Readonly<{
    latitude: Float;
    longitude: Float;
}>

/**
 * 地图标注点
 */
export type MapPoi = Readonly<{
    /**
     * 标注点 ID
     */
    id: string;

    /**
     * 标注点名称
     */
    name: string;

    /**
     * 标注点坐标
     */
    position: {
        latitude: Float;
        longitude: Float;
    }
}>


export type CameraPosition = Readonly<{
    /**
     * 中心坐标
     */
    target?: {
        latitude: Float;
        longitude: Float;
    }

    /**
     * 缩放级别
     */
    zoom?: Float;

    /**
     * 朝向、旋转角度
     */
    bearing?: Float;

    /**
     * 倾斜角度
     */
    tilt?: Float;
}>

export type voidEvent = Readonly<{}>

export type Location = Readonly<{
    accuracy: Float;
    altitude: Float;
    heading: Float;
    speed: Float;
    latitude: Float;
    longitude: Float;
}>

export interface MapViewProps extends ViewProps {
    /**
     * 地图类型
     */
    mapType?: Int32;

    /**
     * 初始状态
     */
    initialCameraPosition?: CameraPosition;

    /**
     * 是否显示当前定位
     */
    myLocationEnabled?: boolean;

    /**
     * 是否显示室内地图
     */
    indoorViewEnabled?: boolean;

    /**
     * 是否显示3D建筑
     */
    buildingsEnabled?: boolean;

    /**
     * 是否显示标注
     */
    labelsEnabled?: boolean;

    /**
     * 是否显示指南针
     */
    compassEnabled?: boolean;
    /**
     * 是否显示放大缩小按钮
     *
     * @platform android
     */
    zoomControlsEnabled?: boolean;

    /**
     * 是否显示比例尺
     */
    scaleControlsEnabled?: boolean;

    /**
     * 是否显示定位按钮
     *
     * @platform android
     */
    myLocationButtonEnabled?: boolean;

    /**
     * 是否显示路况
     */
    trafficEnabled?: boolean;

    /**
     * 最大缩放级别
     */
    maxZoom?: Float;

    /**
     * 最小缩放级别
     */
    minZoom?: Float;

    /**
     * 是否启用缩放手势，用于放大缩小
     */
    zoomGesturesEnabled?: boolean;

    /**
     * 是否启用滑动手势，用于平移
     */
    scrollGesturesEnabled?: boolean;

    /**
     * 是否启用旋转手势，用于调整方向
     */
    rotateGesturesEnabled?: boolean;

    /**
     * 是否启用倾斜手势，用于改变视角
     */
    tiltGesturesEnabled?: boolean;

    /**
     * 设定定位的最小更新距离
     *
     * @platform ios
     */
    distanceFilter?: Float;

    /**
     * 设定最小更新角度，默认为 1 度
     *
     * @platform ios
     */
    headingFilter?: Float;

    /**
     * 点击事件
     */
    onPress?: (DirectEventHandler<LatLng>);

    /**
     * 标注点击事件
     */
    onPressPoi?: (DirectEventHandler<MapPoi>);

    /**
     * 长按事件
     */
    onLongPress?: (DirectEventHandler<LatLng>);

    /**
     * 地图状态改变事件，随地图状态变化不停地触发
     */
    onCameraMove?: (DirectEventHandler<CameraPosition>);

    /**
     * 地图状态改变事件，在停止变化后触发
     */
    onCameraIdle?: (DirectEventHandler<CameraPosition>);

    /**
     * 地图初始化完成事件
     */
    onLoad?: (DirectEventHandler<voidEvent>);

    /**
     * 地图定位更新事件
     */
    onLocation?: (DirectEventHandler<Location>);
}

export default codegenNativeComponent<MapViewProps>("AMapView") as HostComponent<MapViewProps>;
type MapViewControlType = HostComponent<MapViewProps>;
export interface NativeCommands {
  moveCamera: (
    viewRef: React.ElementRef<MapViewControlType>,
    cameraPosition: Partial<CameraPosition>,
    duration:number
  ) => void
}
export const moveCameraCommands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ["moveCamera"],
});