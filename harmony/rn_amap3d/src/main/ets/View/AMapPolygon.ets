import { LatLng, } from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';

export interface AMapPolygonProps extends ViewBaseProps {
  points: LatLng[];
  strokeWidth?: number;
  strokeColor?: string;
  fillColor?: string;
  zIndex?: number;
}

export const A_MAP_POLYGON_TYPE: string = "AMapPolygon";
export type AMapPolygonDescriptor = Descriptor<"AMapPolygon", AMapPolygonProps>
@Entry
@Component
export struct AMapPolygon {
  ctx !: RNOHContext
  tag: number = -1
  @State amapDescriptor: AMapPolygonDescriptor = {} as AMapPolygonDescriptor
  static NAME: string = "AMapPolygon";

  build() {
  }
}