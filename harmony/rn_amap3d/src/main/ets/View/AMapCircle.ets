import { LatLng} from '@amap/amap_lbs_map3d'
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';

export function rgbaToHex(rgbaString: string): number {
  const match = rgbaString.match(/(\d+(\.\d+)?)/g);
  if (match && match.length >= 4) {
    const alpha = Math.round(parseFloat(match[3]) * 255); // 将 alpha 值转换为 0-255 范围内的整数
    const red = parseInt(match[0]);
    const green = parseInt(match[1]);
    const blue = parseInt(match[2]);
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  } else {
    throw new Error('Invalid RGBA string format');
  }
}

export interface AMapCircleProps extends ViewBaseProps {
  center: LatLng;
  radius?: number;
  strokeWidth?: number;
  strokeColor?: string;
  fillColor?: string;
  zIndex?: number;
}

export const A_MAP_CIRCLE_VIEW_TYPE: string = "AMapCircle";

export type AMapCircleDescriptor = Descriptor<"AMapCircle", AMapCircleProps>
@Entry
@Component
export struct AMapCircle {
  static NAME:string = "AMapCircle";
  ctx!: RNOHContext
  tag: number = -1
  // @State gDMapDescriptor: GDMapViewDescriptor = {} as GDMapViewDescriptor
  build() {
  }
}

