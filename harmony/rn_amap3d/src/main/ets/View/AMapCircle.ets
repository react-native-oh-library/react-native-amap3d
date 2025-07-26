import { LatLng} from '@amap/amap_lbs_map3d'
import { Descriptor, RNOHContext, ViewBaseProps } from '@rnoh/react-native-openharmony';

export function rgbaToHex(rgbaString: string): number {
  // 处理十六进制字符串（如 #RGB、#RRGGBB、#AARRGGBB）
  let value: number;
  if (rgbaString.startsWith('#')) {
    const hex = rgbaString.slice(1); // 去掉 #
    // 根据长度解析十六进制
    switch (hex.length) {
      case 3: // #RGB → 转换为 #RRGGBB（Alpha=FF）
        value = parseInt(hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2], 16);
        return 0xFF000000 | value;
      case 6: // #RRGGBB → 转换为 #AARRGGBB（Alpha=FF）
        value = parseInt(hex, 16);
        return 0xFF000000 | value;
      case 8: // #AARRGGBB → 直接转换为数值
        return parseInt(hex, 16);
      default:
        throw new Error('Invalid hex color format (expected #RGB, #RRGGBB, or #AARRGGBB)');
    }
  }

  // 处理 RGB 格式（无 Alpha）
  if (rgbaString.startsWith('rgb(')) {
    const match = rgbaString.match(/(\d+(\.\d+)?)/g);
    if (!match) throw new Error('Invalid RGB string format');
    const red = parseInt(match[0]);
    const green = parseInt(match[1]);
    const blue = parseInt(match[2]);
    value = 0xFF000000 | (red << 16) | (green << 8) | blue;
    return value;
  }

  // 处理 RGBA 格式
  if (rgbaString.startsWith('rgba(')) {
    const match = rgbaString.match(/(\d+(\.\d+)?)/g);
    if (!match) throw new Error('Invalid RGBA string format');
    const r = match[0];
    const g = match[1];
    const b = match[2];
    const a = match[3];
    const red = Math.min(255, Math.max(0, parseInt(r)));
    const green = Math.min(255, Math.max(0, parseInt(g)));
    const blue = Math.min(255, Math.max(0, parseInt(b)));
    const alpha = Math.round(Math.min(1, Math.max(0, parseFloat(a))) * 255);
    value = (alpha << 24) | (red << 16) | (green << 8) | blue;
    return value;
  }
  return 0xFF000000;
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
@Component
export struct AMapCircle {
  static NAME:string = "AMapCircle";
  ctx!: RNOHContext
  tag: number = -1
  build() {
  }
}

