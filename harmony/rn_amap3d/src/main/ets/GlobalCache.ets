import {
    AMap, MapView, Marker, Polyline
} from '@amap/amap_lbs_map3d';
import HashMap from '@ohos.util.HashMap';

export default class GlobalCache {
  public static index: number = 1
  public static isGO: boolean = false;
  public static cacheMap: Map<Object | undefined, number> = new Map()
  public static cacheMapPageDestroy: Map<number, boolean> = new Map()
  public static mapMarker: Map<number, Array<Marker>> = new Map();
  public static mapPolyLine: Map<number, Array<Polyline>> = new Map();
  public static markers: Array<Marker> = new Array();
  public static polyLines: Array<Polyline> = new Array();
  public static mapViews: HashMap<number, MapView> = new HashMap();
  public static maps: HashMap<number, AMap> = new HashMap();
  public static currentPageMarker: HashMap<number, number> = new HashMap();
  public static currentPagePolyline: HashMap<number, number> = new HashMap();
}