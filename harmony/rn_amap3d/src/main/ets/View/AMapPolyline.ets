import { LatLng, } from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';

export interface AMapPolylineProps extends ViewBaseProps {
  points: LatLng[];
  width?: number;
  color?: string;
  zIndex?: number;
  colors: string[];
  gradient?: boolean;
  geodesic?: boolean;
  dotted?: boolean;
}

export function convertColorsToNumbers(colorString: string): number {
  const hex = colorString.substring(1);
  return parseInt(hex, 16);
}

export const A_MAP_POLYLINE_TYPE: string = "AMapPolyline";

export type AMapPolylineDescriptor = Descriptor<"AMapPolyline", AMapPolylineProps>

@Component
export struct AMapPolyline {
  ctx !: RNOHContext
  tag: number = -1
  @State amapDescriptor: AMapPolylineDescriptor = {} as AMapPolylineDescriptor
  static NAME: string = "AMapPolyline";

  onPolyLineClickFunction():void {
    console.info("AMapViewEventType polyline   =====" + this.tag);
    this.ctx.rnInstance.emitComponentEvent(this.tag, A_MAP_POLYLINE_TYPE, {
      type: 'onPress'
    })
  }

  build() {
  }
}