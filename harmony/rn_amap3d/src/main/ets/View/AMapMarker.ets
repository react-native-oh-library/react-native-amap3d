import { BitmapDescriptor, LatLng, Point} from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';


export interface AMapMarkerProps extends ViewBaseProps {
  position: LatLng;
  icon?: BitmapDescriptor;
  opacity?: number;
  draggable?: boolean;
  flat?: boolean;
  zIndex?: number;
  anchor?: Point;
  centerOffset?: Point;
}
export const A_MAP_MARKER_TYPE: string = "AMapMarker";
export type AMapMarkerDescriptor = Descriptor<"AMapMarker", AMapMarkerProps>
@Entry
@Component
export struct AMapMarker {
  ctx !: RNOHContext
  tag: number = -1
  @State amapDescriptor: AMapMarkerDescriptor = {} as AMapMarkerDescriptor
  static NAME: string = "AMapMarker";

  build() {
  }
}