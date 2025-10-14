import { LatLng, } from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';
import GlobalCache from '../GlobalCache';
import { ArrayList } from '@kit.ArkTS';
import { rgbaToHex } from './AMapCircle';

export interface AMapPolygonProps extends ViewBaseProps {
  points: LatLng[];
  strokeWidth?: number;
  strokeColor?: string;
  fillColor?: string;
  zIndex?: number;
}

export const A_MAP_POLYGON_TYPE: string = "AMapPolygon";

export type AMapPolygonDescriptor = Descriptor<"AMapPolygon", '', '', AMapPolygonProps>

@Component
export struct AMapPolygon {
  ctx !: RNOHContext
  tag: number = -1
  @State amapDescriptor: AMapPolygonDescriptor = {} as AMapPolygonDescriptor
  static NAME: string = "AMapPolygon";
  private unregisterDescriptorChangesListener?: () => void = undefined

  aboutToAppear(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      async (newDescriptor) => {
        /*------ 当RN侧属性props有更改 -------*/
        let currentPolygon = GlobalCache.polygonCacheMap.get(this.tag)
        this.amapDescriptor = (newDescriptor as AMapPolygonDescriptor)
        let mapPolygonProp = this.amapDescriptor.rawProps as AMapPolygonProps;
        if (currentPolygon) {
          let polygonOptionsList = new ArrayList<LatLng>()
          for (let index = 0; index < mapPolygonProp.points.length; index++) {
            polygonOptionsList.add(new LatLng(mapPolygonProp.points[index].latitude,
              mapPolygonProp.points[index].longitude))
          }
          currentPolygon.setPoints(polygonOptionsList);
          currentPolygon.setFillColor(rgbaToHex(mapPolygonProp.fillColor ? mapPolygonProp.fillColor :
            "rgba(255, 0, 0, 0.5)"));
          currentPolygon.setStrokeWidth(mapPolygonProp.strokeWidth ? mapPolygonProp.strokeWidth : 5);
          currentPolygon.setStrokeColor(rgbaToHex(mapPolygonProp.strokeColor ? mapPolygonProp.strokeColor :
            "rgba(255, 0, 0, 0.5)"));
          currentPolygon.setZIndex(mapPolygonProp.zIndex ? mapPolygonProp.zIndex : 2);
        }
      }
    )
  }

  build() {
  }
}