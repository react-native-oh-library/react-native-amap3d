
import AMapView, { Location, MapViewProps, voidEvent } from './map-viewNativeComponent'
import React, { Component } from 'react';
import type * as ReactNative from "react-native";
import { LatLng, CameraPosition, LatLngBounds, onCameraEvent, MapPoi } from './map-viewNativeComponent'

export default class MapView extends Component<MapViewProps> {
  constructor(props: MapViewProps) {
    super(props);
  }
  render() {
    return (
      <AMapView
        {...this.props}
        onPress={(event: ReactNative.NativeSyntheticEvent<LatLng>) => {
          console.info("AMapViewEventType map3d demo 10.11")
          if (event.nativeEvent.latitude) {
            this.props.onPress?.call(this, event);
          }
        }}
        onLongPress={(event: ReactNative.NativeSyntheticEvent<LatLng>) => {
          console.info("AMapViewEventType map3d demo long event 11.32")
          if (event.nativeEvent.latitude) {
            this.props.onLongPress?.call(this, event);
          }
        }}
        onCameraMove={(event: ReactNative.NativeSyntheticEvent<CameraPosition>) => {
          console.info("AMapViewEventType map3d demo Move start event")
          if (event.nativeEvent.target?.latitude) {
            this.props.onCameraMove?.call(this, event);
          }
        }}
        onCameraIdle={(event: ReactNative.NativeSyntheticEvent<CameraPosition>) => {
          console.info("AMapViewEventType map3d demo Move end event")
          if (event.nativeEvent.target?.latitude) {
            this.props.onCameraIdle?.call(this, event);
          }
        }}
        onPressPoi={(event: ReactNative.NativeSyntheticEvent<MapPoi>) => {
          console.info("AMapViewEventType map3d demo MapPoi")
          if (event.nativeEvent.position.latitude) {
            this.props.onPressPoi?.call(this, event);
          }
        }}
        onLocation={(event: ReactNative.NativeSyntheticEvent<Location>) => {
          console.info("AMapViewEventType map3d demo onLocation")
          this.props.onLocation?.call(this, event);
        }}
        onLoad={(event: ReactNative.NativeSyntheticEvent<voidEvent>) => {
          this.props.onLoad?.call(this, event);
        }}
      />
    );
  }
}