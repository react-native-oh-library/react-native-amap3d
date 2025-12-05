import { LatLng, Polyline, } from '@amap/amap_lbs_map3d';
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';
import GlobalCache from '../GlobalCache';
import { ArrayList, HashMap } from '@kit.ArkTS';
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

export type AMapPolylineDescriptor = Descriptor<"AMapPolyline", '', '', AMapPolylineProps>

@Component
export struct AMapPolyline {
  ctx !: RNOHContext
  tag: number = -1
  polyLines: Array<Polyline> = [];
  polyLineTagAndDescriptorTagArray: Array<HashMap<number, string>> = []
  @State amapDescriptor: AMapPolylineDescriptor = {} as AMapPolylineDescriptor
  static NAME: string = "AMapPolyline";
  private unregisterDescriptorChangesListener?: () => void = undefined
  // 组件是否已销毁标志
  private isDestroyed: boolean = false;

  /**
   * 检查组件是否仍然有效（未被销毁）
   */
  private isValid(): boolean {
    let currentMapTag = GlobalCache.currentPagePolyline.get(this.tag);
    return !this.isDestroyed &&
           (currentMapTag === undefined || !GlobalCache.destroyedMapTags.has(currentMapTag));
  }

  aboutToAppear(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      async (newDescriptor) => {
        // 检查组件是否已销毁
        if (!this.isValid()) {
          return;
        }
        /*------ 当RN侧属性props有更改 -------*/
        let currentMapTag = GlobalCache.currentPagePolyline.get(this.tag)
        this.polyLines = GlobalCache.mapPolyLine.get(currentMapTag) ?? [];
        this.polyLineTagAndDescriptorTagArray = GlobalCache.polyLinesTagAndDescriptorTag.get(currentMapTag) ?? [];
        this.amapDescriptor = (newDescriptor as AMapPolylineDescriptor)
        let mapPolylineProp = this.amapDescriptor.rawProps as AMapPolylineProps;
        if (this.polyLines && this.polyLines.length > 0) {
          for (let j = 0; j < this.polyLineTagAndDescriptorTagArray.length; ++j) {
            this.polyLineTagAndDescriptorTagArray[j].forEach(async (polyLineID: string, polyLineTag: number,
              map: HashMap<number, string>) => {
                // 异步操作前检查组件是否已销毁
              if (!this.isValid()) {
                return;
              }
              if (polyLineTag == this.tag) {
                for (let i = 0; i < this.polyLines.length; ++i) {
                  if (this.polyLines[i].getId() == polyLineID) {
                    // 每次操作前都检查有效性
                    if (!this.isValid()) return;
                    this.polyLines[i].setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1);
                    this.polyLines[i].setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false);
                    this.polyLines[i].setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false);
                    this.polyLines[i].setWidth(mapPolylineProp.width ? vp2px(mapPolylineProp.width) : vp2px(5));
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
            })
          }
        }
      }
    )
  }

aboutToDisappear(): void {
    // 标记组件为已销毁
    this.isDestroyed = true;
    // 取消订阅
    this.unregisterDescriptorChangesListener?.();
  }

  build() {
  }
}