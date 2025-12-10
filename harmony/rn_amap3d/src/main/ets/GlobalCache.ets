import {
    AMap, MapView, Marker, Polygon, Polyline, Circle
} from '@amap/amap_lbs_map3d';
import HashMap from '@ohos.util.HashMap';

export default class GlobalCache {
  public static index: number = 1
  public static isGO: boolean = false;
  // 记录已销毁的地图组件tag，用于防止异步操作访问已释放资源
  public static destroyedMapTags: Set<number> = new Set();
  // 记录已销毁的Marker组件tag
  public static destroyedMarkerTags: Set<number> = new Set();
  public static cacheMap: Map<Object | undefined, number> = new Map()
  public static cacheMapPageDestroy: Map<number, boolean> = new Map()
  public static mapMarker: Map<number, Array<Marker>> = new Map();//map的tag和 marker集合
  public static markerTagAndDescriptorTag: Map<number,Array<HashMap<number, string>>> = new Map();//map的tag和  marker的tag、marker的id
  public static currentPageMarker: HashMap<number, number> = new HashMap();

  public static mapPolyLine: Map<number, Array<Polyline>> = new Map();//存的是map的tag和polyLine集合
  public static polyLinesTagAndDescriptorTag: Map<number,Array<HashMap<number, string>>> = new Map();//map的tag和  polyLine的tag、marker的id
  public static currentPagePolyline: HashMap<number, number> = new HashMap();//存的是polyline的tag和map的tag

  public static mapViews: HashMap<number, MapView> = new HashMap();
  public static maps: HashMap<number, AMap> = new HashMap();

  public static polygonCacheMap: HashMap<number, Polygon> = new HashMap();
  public static circleCacheMap: HashMap<number, Circle> = new HashMap();
  // 新增: map的tag和circle集合的映射关系
  public static mapCircle: Map<number, Array<Circle>> = new Map();
  // 新增: circle的tag和map的tag的映射关系
  public static currentPageCircle: HashMap<number, number> = new HashMap();
}