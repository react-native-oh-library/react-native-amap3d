

import AMapMarker ,{MarkerProps,LatLng,voidEvent} from './markerNativeComponent'
import React , {Component}  from 'react';
import type * as ReactNative from "react-native";

export default class Marker extends Component<MarkerProps> {
 
  constructor(props: MarkerProps) {
    super(props);
  }

  name = name;


  render() {
    return (
      <AMapMarker {...this.props} 
      onPress={(event: ReactNative.NativeSyntheticEvent<voidEvent>) => {
        console.info("AMapViewEventType map3d demo onpress marker")
        this.props.onPress?.call(this, event);
        
      }}
      onDragEnd={(event: ReactNative.NativeSyntheticEvent<LatLng>) => {
        console.info("AMapViewEventType map3d demo onDragEnd")
        this.props.onDragEnd?.call(this, event);
      }}
      />
    );
  }
}
const name = "AMapMarker";