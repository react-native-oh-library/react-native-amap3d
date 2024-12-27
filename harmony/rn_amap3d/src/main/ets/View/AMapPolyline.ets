import { LatLng, Polyline, } from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';
import GlobalCache from '../GlobalCache';
import { ArrayList } from '@kit.ArkTS';
import { rgbaToHex } from './AMapCircle';

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
  polyLines: Array<Polyline> | undefined = []
  @State amapDescriptor: AMapPolylineDescriptor = {} as AMapPolylineDescriptor
  static NAME: string = "AMapPolyline";
  private unregisterDescriptorChangesListener?: () => void = undefined

  aboutToAppear(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      async (newDescriptor) => {
        /*------ 当RN侧属性props有更改 -------*/
        let currentPageTag = GlobalCache.currentPagePolyline.get(this.tag)
        this.polyLines = GlobalCache.mapPolyLine.get(currentPageTag);
        this.amapDescriptor = (newDescriptor as AMapPolylineDescriptor)
        let mapPolylineProp = this.amapDescriptor.props as AMapPolylineProps;
        if (this.polyLines) {
          for (let i = 0; i < this.polyLines.length; ++i) {
            this.polyLines[i].setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1);
            this.polyLines[i].setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false);
            this.polyLines[i].setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false);
            this.polyLines[i].setWidth(mapPolylineProp.width ? mapPolylineProp.width : 5);
            let polylineOptionsList = new ArrayList<LatLng>()
            for (let index = 0; index < mapPolylineProp.points.length; index++) {
              polylineOptionsList.add(new LatLng(mapPolylineProp.points[index].latitude,
                mapPolylineProp.points[index].longitude))
            }
            this.polyLines[i].setPoints(polylineOptionsList);
            if (mapPolylineProp.color) {
              this.polyLines[i].setColor(rgbaToHex(mapPolylineProp.color ? mapPolylineProp.color :
                "rgba(0, 255, 0, 0.5)"));
            }
            if (mapPolylineProp.colors) {
              let test = new Int32Array(mapPolylineProp.colors.length)
              for (let i = 0; i < mapPolylineProp.colors.length; ++i) {
                let str = mapPolylineProp.colors[i].replace("#", "0xff")
                test[i] = parseInt(str.substring(2, str.length), 16)
              }
              this.polyLines[i].getOptions().setColorValues(test);
              this.polyLines[i].getOptions().setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false);
              this.polyLines[i].setOptions(this.polyLines[i].getOptions());
            }
          }
        }
      }
    )
  }

  build() {
  }
}