import { BitmapDescriptor, BitmapDescriptorFactory, LatLng, Marker, Point } from '@amap/amap_lbs_map3d';
import { Descriptor, RNComponentContext, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';
import { globalContext } from './MapView';
import GlobalCache from '../GlobalCache';
import { HashMap } from '@kit.ArkTS';

export interface AMapMarkerProps extends ViewBaseProps {
  position: LatLng;
  icon?: BitmapDescriptor;
  opacity?: number;
  draggable?: boolean;
  flat?: boolean;
  zIndex?: number;
  anchor?: Point;
  centerOffset?: Point;
  tag?:string;
}

export const A_MAP_MARKER_TYPE: string = "AMapMarker";

export type AMapMarkerDescriptor = Descriptor<"AMapMarker", '', '', AMapMarkerProps>;

@Component
export struct AMapMarker {
  ctx !: RNComponentContext
  tag: number = -1
  markers: Array<Marker> = []
  markerTagAndDescriptorTagArray: Array<HashMap<number, string>> = []
  @State amapDescriptor: AMapMarkerDescriptor = {} as AMapMarkerDescriptor
  private unregisterDescriptorChangesListener?: () => void = undefined
  static NAME: string = "AMapMarker";

  aboutToAppear(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      async (newDescriptor) => {
        /*------ 当RN侧属性props有更改 -------*/
        let currentMapTag = GlobalCache.currentPageMarker.get(this.tag)
        this.markers = GlobalCache.mapMarker.get(currentMapTag) ?? [];
        this.markerTagAndDescriptorTagArray = GlobalCache.markerTagAndDescriptorTag.get(currentMapTag) ?? [];
        this.amapDescriptor = (newDescriptor as AMapMarkerDescriptor)
        let mapMarkerProps = this.amapDescriptor.rawProps as AMapMarkerProps;
        if (this.markers) {

          for (let j = 0; j < this.markerTagAndDescriptorTagArray.length; ++j) {
            this.markerTagAndDescriptorTagArray[j].forEach(async (markerID: string, markerTag: number, map: HashMap<number, string>) => {
              if (markerTag == this.tag) {
                for (let i = 0; i < this.markers.length; ++i) {
                  if (this.markers[i].getId() == markerID) {
                    this.markers[i].setPosition(new LatLng(mapMarkerProps.position.latitude, mapMarkerProps.position.longitude));
                    this.markers[i].setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
                      mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
                    this.markers[i].setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
                    //this.markers[i].setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
                    this.markers[i].setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
                    this.markers[i].getOptions().setInfoWindowOffset(mapMarkerProps.centerOffset?.x,mapMarkerProps.centerOffset?.y);
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
                  }
                }
              }
            })
          }
        }
      }
    )
  }

  build() {
    ContentSlot(this.ctx.getContentForTag(this.tag))
  }
}