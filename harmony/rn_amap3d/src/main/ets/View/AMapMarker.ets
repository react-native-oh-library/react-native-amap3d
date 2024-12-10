import { BitmapDescriptor, BitmapDescriptorFactory, LatLng, Marker, Point } from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';
import { globalContext, markers } from './MapView';

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

export type AMapMarkerDescriptor = Descriptor<"AMapMarker", AMapMarkerProps>;

@Entry
@Component
export struct AMapMarker {
  ctx !: RNOHContext
  tag: number = -1
  markers: Array<Marker> = []
  @State amapDescriptor: AMapMarkerDescriptor = {} as AMapMarkerDescriptor
  private unregisterDescriptorChangesListener?: () => void = undefined
  static NAME: string = "AMapMarker";

  aboutToAppear(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      async (newDescriptor) => {
        /*------ 当RN侧属性props有更改 -------*/
        console.log(`RNOH in GaoDeMap descriptor change marker`);
        this.markers = markers;
        this.amapDescriptor = (newDescriptor as AMapMarkerDescriptor)
        let mapMarkerProps = this.amapDescriptor.props as AMapMarkerProps;
        for (let i = 0; i < this.markers.length; ++i) {
          if ((mapMarkerProps.position.latitude == this.markers[i].getPosition().latitude)
            && (mapMarkerProps.position.longitude == this.markers[i].getPosition().longitude)) {
            this.markers[i].setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
              mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
            this.markers[i].setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
            this.markers[i].setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
            this.markers[i].setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
            if (mapMarkerProps.icon) {
              try {
                let resoure: string = mapMarkerProps.icon["uri"];
                let bitmapDes: BitmapDescriptor | undefined =
                  await BitmapDescriptorFactory.fromRawfilePath(globalContext, resoure);
                this.markers[i].setIcon(bitmapDes);
              } catch (error) {
                let bitmapDesNull: BitmapDescriptor | undefined =
                  await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                if (bitmapDesNull) {
                  this.markers[i].setIcon(bitmapDesNull);
                }
              }
            }
            break;
          }
        }
      }
    )
  }

  build() {
  }
}