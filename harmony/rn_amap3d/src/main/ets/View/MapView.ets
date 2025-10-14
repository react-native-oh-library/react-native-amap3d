import {
  AMap,
  BitmapDescriptor,
  BitmapDescriptorFactory,
  CameraPosition,
  CameraUpdateFactory,
  CircleOptions,
  LatLng,
  MapView,
  MapViewComponent,
  MapViewManager,
  Marker,
  MarkerOptions,
  OnCameraChangeListener,
  OnMarkerDragListener,
  OnLocationChangedListener,
  Poi,
  PolygonOptions,
  Polyline,
  PolylineOptions,
  MyLocationStyle,
  LocationSource
} from '@amap/amap_lbs_map3d';

import { Descriptor, RNComponentContext, RNOHContext, RNViewBase, ViewBaseProps } from '@rnoh/react-native-openharmony';
import { A_MAP_CIRCLE_VIEW_TYPE, AMapCircleProps, rgbaToHex } from './AMapCircle';
import { A_MAP_POLYGON_TYPE, AMapPolygonProps } from './AMapPolygon';
import { A_MAP_POLYLINE_TYPE, AMapPolylineProps } from './AMapPolyline';
import { A_MAP_MARKER_TYPE, AMapMarkerProps } from './AMapMarker';

import Logger from '../Logger';
import { ArrayList, HashMap, JSON } from '@kit.ArkTS';
import GlobalCache from '../GlobalCache';
import { application } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import geoLocationManager from '@ohos.geoLocationManager';
import {
  AMapLocationManagerImpl,
  AMapLocationOption, AMapLocationReGeocodeLanguage, AMapLocationType, IAMapLocationListener } from '@amap/amap_lbs_location';
import { DownloadIcon } from '../DownloadIcon';

export interface MapViewProps extends ViewBaseProps {
  initialCameraPosition?: CameraPosition;
  mapType: number;
  myLocationEnabled?: boolean;
  indoorViewEnabled?: boolean;
  buildingsEnabled?: boolean;
  labelsEnabled?: boolean;
  compassEnabled?: boolean;
  zoomControlsEnabled?: boolean;
  scaleControlsEnabled?: boolean;
  myLocationButtonEnabled?: boolean;
  trafficEnabled?: boolean;
  maxZoom?: number;
  minZoom?: number;
  zoomGesturesEnabled?: boolean;
  scrollGesturesEnabled?: boolean;
  rotateGesturesEnabled?: boolean;
  tiltGesturesEnabled?: boolean;
  distanceFilter?: number;
  headingFilter?: number;
}

const MAP_SHOW_FUNC = 'AMapView';

export const GOADE_MAP_VIEW_TYPE: string = "AMapView"

export type GDMapViewDescriptor = Descriptor<"AMapView", '', '', MapViewProps>;

export let globalContext: Context;

@Component
export struct AMapView {
  static NAME: string = "AMapView";
  static num: number = 0;
  ctx!: RNComponentContext
  tag: number = -1
  type: string = ""
  polyLineTag: Array<number> = []
  markerTag: Array<number> = []
  @State gDMapDescriptor: GDMapViewDescriptor = {} as GDMapViewDescriptor
  private intervalId: number = 0;
  private unregisterDescriptorChangesListener?: () => void = undefined
  private cleanupCallback?: () => void = undefined;
  private markers : Array<Marker> = new Array();
  private polylines : Array<Polyline> = new Array();
  private markerTagAndDescriptorTagArray : Array<HashMap<number, string>> = new Array();
  private polylineTagAndDescriptorTagArray : Array<HashMap<number, string>> = new Array();
  private mapListener?: OnLocationChangedListener;
  aboutToAppear(): void {
    this.cleanupCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args: ESObject[]) => {
        if (command === 'moveCamera') {
          this.aMap?.animateCamera(CameraUpdateFactory.newCameraPosition(args[0]), null, args[1]);
        }
      });
    globalContext = application.getApplicationContext();
    this.gDMapDescriptor = this.ctx.descriptorRegistry.getDescriptor<GDMapViewDescriptor>(this.tag);
    // GlobalCache.markerProp = new HashMap();
    this.getProp(this.gDMapDescriptor);
    this.show();
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        if (this.aMap) {
          GlobalCache.mapPolyLine.clear();
          /*------ 当RN侧属性props有更改 -------*/
          this.gDMapDescriptor = (newDescriptor as GDMapViewDescriptor)
          let oldMyLocationEnabled = this.myLocationEnabled;
          this.getProp(this.gDMapDescriptor);
          if (oldMyLocationEnabled !== this.myLocationEnabled) {
            this.aMap.setMyLocationEnabled(this.myLocationEnabled);
            if (this.myLocationEnabled) {
              this.startLocationUpdates();
            } else {
              this.stopLocationUpdates();
            }
          }

          this.getOverlay(this.gDMapDescriptor);
        }

      }
    )
  }

  aboutToDisappear(): void {
    if (this.mapViewCreateCallback) {
      MapViewManager.getInstance().unregisterMapViewCreatedCallback(this.mapViewCreateCallback);
    }
    this.unregisterDescriptorChangesListener?.()
    this.cleanupCallback?.()
    GlobalCache.maps.get(this.tag)?.clear()
    GlobalCache.mapViews.get(this.tag)?.onDestroy();
    GlobalCache.mapMarker.delete(this.tag);
    GlobalCache.markerTagAndDescriptorTag.delete(this.tag);
    GlobalCache.mapPolyLine.delete(this.tag);
    GlobalCache.polyLinesTagAndDescriptorTag.delete(this.tag);
    GlobalCache.polygonCacheMap.clear();
    GlobalCache.circleCacheMap.clear();
  }

  locationManager?:AMapLocationManagerImpl
  private locationStyle: MyLocationStyle = new MyLocationStyle();
  private mapView?: MapView;
  private aMap?: AMap;
  mapType: number = 1;
  initialCameraPosition?: CameraPosition;
  myLocationEnabled: boolean = false;
  indoorViewEnabled: boolean = false;
  compassEnabled: boolean = false;
  buildingsEnabled: boolean = false;
  labelsEnabled: boolean = false;
  zoomControlsEnabled: boolean = false;
  scaleControlsEnabled: boolean = false;
  myLocationButtonEnabled: boolean = false;
  distanceFilter: number = 1;
  headingFilter: number = 1;
  trafficEnabled: boolean = false;
  maxZoom: number = 19;
  minZoom: number = 3
  zoomGesturesEnabled: boolean = true; //控制缩放
  scrollGesturesEnabled: boolean = true; //控制平移
  rotateGesturesEnabled: boolean = true; //控制手势旋转
  tiltGesturesEnabled: boolean = true; //控制倾斜

  //覆盖物
  getMapView(): MapView | undefined {
    return this.mapView;
  }

  getAMap(): AMap | undefined {
    return this.aMap;
  }

  onClickFunction(point: LatLng) {
    this.ctx.rnInstance.emitComponentEvent(this.gDMapDescriptor.tag, MAP_SHOW_FUNC, {
      type: 'onPress',
      LatLng: point
    })
  }

  onLongClickFunction(point: LatLng) {
    this.ctx.rnInstance.emitComponentEvent(this.gDMapDescriptor.tag, MAP_SHOW_FUNC, {
      type: 'onLongPress',
      LatLng: point
    })
  }

  onPressPoiFunction(poi: Poi) {
    this.ctx.rnInstance.emitComponentEvent(this.gDMapDescriptor.tag, MAP_SHOW_FUNC, {
      type: 'onPressPoi',
      Poi: poi
    })
  }

  onCameraMoveFunction(cameraMoveEvent: CameraPosition) {
    this.ctx.rnInstance.emitComponentEvent(this.gDMapDescriptor.tag, MAP_SHOW_FUNC, {
      type: 'onCameraMove',
      CameraPosition: cameraMoveEvent
    })
  }

  onCameraIdleFunction(cameraIdleEvent: CameraPosition) {
    this.ctx.rnInstance.emitComponentEvent(this.gDMapDescriptor.tag, MAP_SHOW_FUNC, {
      type: 'onCameraIdle',
      CameraPosition: cameraIdleEvent
    })
  }

  onLoadFunction(): void {
    Logger.info('map3d', 'EntryAbility', 'get map onLoadFunction');
    this.ctx.rnInstance.emitComponentEvent(this.gDMapDescriptor.tag, MAP_SHOW_FUNC, {
      type: 'onLoad'
    })
  }

  onPolyLineClickFunction(num: number): void {
    this.ctx.rnInstance.emitComponentEvent(this.polyLineTag[num], A_MAP_POLYLINE_TYPE, {
      type: 'onPress'
    })
  }

  onMarkerClickFunction(num: number): void {
    this.ctx.rnInstance.emitComponentEvent(this.markerTag[num], A_MAP_MARKER_TYPE, {
      type: 'onPress'
    })
  }

  onMarkerDragStartFunction(num: number): void {
    this.ctx.rnInstance.emitComponentEvent(this.markerTag[num], A_MAP_MARKER_TYPE, {
      type: 'onDragStart'
    })
  }

  onMarkerDragFunction(num: number): void {
    this.ctx.rnInstance.emitComponentEvent(this.markerTag[num], A_MAP_MARKER_TYPE, {
      type: 'onDrag'
    })
  }

  onMarkerDragEndFunction(point: LatLng, num: number): void {
    this.ctx.rnInstance.emitComponentEvent(this.markerTag[num], A_MAP_MARKER_TYPE, {
      type: 'onDragEnd',
      LatLng: point
    })
  }

  private mapViewCreateCallback = (mapview?: MapView, mapViewName?: string) => {
    if (!mapview) {
      return;
    }
    if (mapview.getMapViewName() != this.tag.toString()) {
      return;
    }
    mapview.onCreate();
    GlobalCache.mapViews.set(this.tag, mapview);
    this.mapView = GlobalCache.mapViews.get(this.tag);
    this.mapView.getMapAsync(async (map: AMap) => {
      GlobalCache.maps.set(this.tag, map);
      this.aMap = GlobalCache.maps.get(this.tag);
      this.aMap.setLocationSource(this);
      this.getOverlay(this.gDMapDescriptor);
      if (this.initialCameraPosition != null) {
        this.aMap?.moveCamera(CameraUpdateFactory.newCameraPosition(this.initialCameraPosition));
      }

      this.aMap?.setOnMapClickListener((point: LatLng) => {
        this.onClickFunction(point)
      });
      this.aMap?.setOnCameraChangeListener(new OnCameraChangeListener(
        (position: CameraPosition) => {
          this.onCameraMoveFunction(position);
        },
        (position: CameraPosition) => {
          this.onCameraIdleFunction(position);
        }));
      this.aMap?.addOnPOIClickListener((poi: Poi) => {
        this.onPressPoiFunction(poi);
      })
      this.aMap?.setOnMapLongClickListener((point: LatLng) => {
        this.onLongClickFunction(point)
      });

      let approvalNumber = this.aMap?.getMapContentApprovalNumber();
      let satelliteImageApprovalNumber = this.aMap?.getSatelliteImageApprovalNumber();
      Logger.info('map3d', 'EntryAbility',
        `getMapContentApprovalNumber ${approvalNumber} satelliteImageApprovalNumber ${satelliteImageApprovalNumber}`);

      //地图属性
      this.aMap.setMapType(this.mapType);
      this.aMap.setTrafficEnabled(this.trafficEnabled);
      //设置地图最大缩放级别 缩放级别范围为[3, 20],超出范围将按最大级别计算 。
      // 注：只有在有室内地图显示的情况下最大级别为20，否则最大级别为19。
      this.aMap.setMinZoomLevel(this.minZoom);
      this.aMap.setMaxZoomLevel(this.maxZoom);
      this.aMap.setLocationSource(this);
      this.aMap.setMyLocationEnabled(this.myLocationEnabled);
      //设置最小缩放级别 缩放级别范围为[3, 20],超出范围将按最小级别计算
      this.aMap.showBuildings(this.buildingsEnabled);
      this.aMap.showMapText(this.labelsEnabled);
      let uiSettings = this.aMap?.getUiSettings();
      uiSettings?.setZoomGesturesEnabled(this.zoomGesturesEnabled);
      uiSettings?.setScrollGesturesEnabled(this.scrollGesturesEnabled);
      uiSettings?.setRotateGesturesEnabled(this.rotateGesturesEnabled);
      uiSettings?.setTiltGesturesEnabled(this.tiltGesturesEnabled);
      uiSettings?.setScaleControlsEnabled(this.scaleControlsEnabled);
      uiSettings?.setCompassEnabled(this.compassEnabled);
      uiSettings?.setMyLocationButtonEnabled(this.myLocationButtonEnabled);
      uiSettings?.setZoomControlsEnabled(this.zoomControlsEnabled);
      this.onLoadFunction();
      if (this.myLocationEnabled) {
        setTimeout(() => {
          if (this.aMap) {
            const targetType = MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER;
            this.locationStyle.myLocationType(targetType);
            this.aMap.setMyLocationStyle(this.locationStyle);
          }
        },50);
      }
      this.aMap?.setOnPolylineClickListener((polyLine: Polyline): void => {
        let len: number | undefined = GlobalCache.mapPolyLine.get(this.tag)?.length;
        let polyLinesArray: Array<Polyline> | undefined = GlobalCache.mapPolyLine.get(this.tag);
        if (len && polyLinesArray) {
          for (let index = 0; index < len; ++index) {
            if (polyLine.getId() == polyLinesArray[index].getId()) {
              this.onPolyLineClickFunction(index)
            }
          }
        }
      });

      this.aMap?.setOnMarkerClickListener((marker: Marker): boolean => {
        if (GlobalCache.mapMarker.get(this.tag)) {
          let len: number | undefined = GlobalCache.mapMarker.get(this.tag)?.length;
          let markers: Array<Marker> | undefined = GlobalCache.mapMarker.get(this.tag);
          if (len && markers) {
            for (let index = 0; index < len; ++index) {
              if (marker.getId() == markers[index].getId()) {
                this.onMarkerClickFunction(index);
              }
            }
          }
        }
        return true;
      });

      this.aMap?.setOnMarkerDragListener(new OnMarkerDragListener(
        (DragStart: Marker) => {
          let len: number | undefined = GlobalCache.mapMarker.get(this.tag)?.length;
          let markers: Array<Marker> | undefined = GlobalCache.mapMarker.get(this.tag);
          if (len && markers) {
            for (let index = 0; index < len; ++index) {
              if (len && markers) {
                if (DragStart == markers[index]) {
                  this.onMarkerDragStartFunction(index);
                }
              }
            }
          }
        },
        (Drag: Marker) => {
          let len: number | undefined = GlobalCache.mapMarker.get(this.tag)?.length;
          let markers: Array<Marker> | undefined = GlobalCache.mapMarker.get(this.tag);
          if (len && markers) {
            for (let index = 0; index < len; ++index) {
              if (len && markers) {
                if (Drag == markers[index]) {
                  this.onMarkerDragFunction(index);
                }
              }
            }
          }
        },
        (DragEnd: Marker) => {
          let len: number | undefined = GlobalCache.mapMarker.get(this.tag)?.length;
          let markers: Array<Marker> | undefined = GlobalCache.mapMarker.get(this.tag);
          if (len && markers) {
            for (let index = 0; index < len; ++index) {
              if (len && markers) {
                if (DragEnd == markers[index]) {
                  this.onMarkerDragEndFunction(DragEnd.getPosition(), index)
                }
              }
            }
          }
        }))
    })
  }

  show(): void {
    MapViewManager.getInstance().registerMapViewCreatedCallback(this.mapViewCreateCallback);
  }

  /**
   * 获取rn侧传递多来的prop
   */
  private getProp(descriptor: GDMapViewDescriptor) {
    this.mapType = descriptor.rawProps.mapType;
    //初始位置
    if (descriptor.rawProps.initialCameraPosition != null) {
      this.initialCameraPosition = descriptor.rawProps.initialCameraPosition;
    }
    //是否显示当前定位
    if (descriptor.rawProps.myLocationEnabled != null) {
      this.myLocationEnabled = descriptor.rawProps.myLocationEnabled;
    }
    //是否显示室内地图
    if (descriptor.rawProps.indoorViewEnabled != null) {
      this.indoorViewEnabled = descriptor.rawProps.indoorViewEnabled;
    }
    //是否显示3D建筑
    if (descriptor.rawProps.buildingsEnabled != null) {
      this.buildingsEnabled = descriptor.rawProps.buildingsEnabled;
    }
    //是否显示标注
    if (descriptor.rawProps.labelsEnabled != null) {
      this.labelsEnabled = descriptor.rawProps.labelsEnabled;
    }
    //是否显示指南针
    if (descriptor.rawProps.compassEnabled != null) {
      this.compassEnabled = descriptor.rawProps.compassEnabled;
    }
    //是否显示放大缩小按钮
    if (descriptor.rawProps.zoomControlsEnabled != null) {
      this.zoomControlsEnabled = descriptor.rawProps.zoomControlsEnabled;
    }

    if (descriptor.rawProps.myLocationButtonEnabled != null) {
      this.myLocationButtonEnabled = descriptor.rawProps.myLocationButtonEnabled;
    }
    //是否显示比例尺
    if (descriptor.rawProps.scaleControlsEnabled != null) {
      this.scaleControlsEnabled = descriptor.rawProps.scaleControlsEnabled;
    }
    //是否显示路况
    if (descriptor.rawProps.trafficEnabled != null) {
      this.trafficEnabled = descriptor.rawProps.trafficEnabled;
    }
    //最大缩放级别
    if (descriptor.rawProps.maxZoom != null) {
      this.maxZoom = descriptor.rawProps.maxZoom;
    }
    //最小缩放级别
    if (descriptor.rawProps.minZoom != null) {
      this.minZoom = descriptor.rawProps.minZoom;
    }
    //是否启用缩放手势，用于放大缩小
    if (descriptor.rawProps.zoomGesturesEnabled != null) {
      this.zoomGesturesEnabled = descriptor.rawProps.zoomGesturesEnabled;
    }
    //是否启用滑动手势，用于平移
    if (descriptor.rawProps.scrollGesturesEnabled != null) {
      this.scrollGesturesEnabled = descriptor.rawProps.scrollGesturesEnabled;
    }
    //是否启用旋转手势，用于调整方向
    if (descriptor.rawProps.rotateGesturesEnabled != null) {
      this.rotateGesturesEnabled = descriptor.rawProps.rotateGesturesEnabled;
    }
    //是否启用倾斜手势，用于改变视角
    if (descriptor.rawProps.tiltGesturesEnabled != null) {
      this.tiltGesturesEnabled = descriptor.rawProps.tiltGesturesEnabled;
    }
    //设定定位的最小更新距离  @platform ios
    if (descriptor.rawProps.distanceFilter != null) {
      this.distanceFilter = descriptor.rawProps.distanceFilter;
    }
    //设定最小更新角度，默认为 1 度    @platform ios
    if (descriptor.rawProps.headingFilter != null) {
      this.headingFilter = descriptor.rawProps.headingFilter;
    }
  }

  private async getOverlay(descriptor: GDMapViewDescriptor) {
    let tagName = "";
    let flag = false;
    let flagLine = false;
    for (let i = 0; i < descriptor.childrenTags.length; i++) {
      tagName =
        this.ctx.rnInstance.getComponentNameFromDescriptorType(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i])?.type);
      switch (tagName) {
        case A_MAP_CIRCLE_VIEW_TYPE:
          let circleOptions = new CircleOptions();
          let circleProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).rawProps as AMapCircleProps;
          let childCircleTag: number = this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag;
          let circle = this.aMap?.addCircle(circleOptions);
          //Put the overlay ring in the cache and hot-update the properties to modify
          GlobalCache.circleCacheMap.set(childCircleTag, circle);
          if (circle) {
            circle.setRadius(circleProp.radius ? circleProp.radius : 5000);
            circle.setCenter(new LatLng(circleProp.center.latitude, circleProp.center.longitude));
            circle.setFillColor(rgbaToHex(circleProp.fillColor ? circleProp.fillColor : "rgba(255, 0, 0, 0.5)"));
            circle.setStrokeColor(rgbaToHex(circleProp.strokeColor ? circleProp.strokeColor :
              "rgba(0, 0, 255, 0.5)"));
            circle.setStrokeWidth(circleProp.strokeWidth ? circleProp.strokeWidth : 5);
          }
          break;
        case A_MAP_POLYGON_TYPE:
          let polygonOptions = new PolygonOptions();
          let polygon = this.aMap?.addPolygon(polygonOptions);
          let childPolygonTag: number = this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag;
          GlobalCache.polygonCacheMap.set(childPolygonTag, polygon);
          let mapPolygonProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).rawProps as AMapPolygonProps;
          if (polygon) {
            let polygonOptionsList = new ArrayList<LatLng>()
            for (let index = 0; index < mapPolygonProp.points.length; index++) {
              polygonOptionsList.add(new LatLng(mapPolygonProp.points[index].latitude,
                mapPolygonProp.points[index].longitude))
            }
            polygon.setPoints(polygonOptionsList);
            polygon.setFillColor(rgbaToHex(mapPolygonProp.fillColor ? mapPolygonProp.fillColor :
              "rgba(255, 0, 0, 0.5)"));
            polygon.setStrokeWidth(mapPolygonProp.strokeWidth ? mapPolygonProp.strokeWidth : 5);
            polygon.setStrokeColor(rgbaToHex(mapPolygonProp.strokeColor ? mapPolygonProp.strokeColor :
              "rgba(255, 0, 0, 0.5)"));
            polygon.setZIndex(mapPolygonProp.zIndex ? mapPolygonProp.zIndex : 2);
          }
          break;
        case A_MAP_POLYLINE_TYPE:
          flagLine = false;
          let mapPolylineProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).rawProps as AMapPolylineProps;
          let childPolyLineTag: number = this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag;
          let GlobalCachePolyLines : Array<Polyline> = GlobalCache.mapPolyLine.get(this.tag) ?? [];
          let polyLinesTagAndDescriptorTagArray: Array<HashMap<number, string>> = GlobalCache.polyLinesTagAndDescriptorTag.get(this.tag) ?? [];
          for (let index = 0; index < polyLinesTagAndDescriptorTagArray.length; index++) {
            polyLinesTagAndDescriptorTagArray[index].forEach(async (value: string, key: number,
              map: HashMap<number, string>) => {
              if (childPolyLineTag == key) {
                for (let polylineIndex = 0; polylineIndex < GlobalCachePolyLines.length; polylineIndex++) {
                  if (GlobalCachePolyLines[polylineIndex].getId() == value) {
                    flagLine = true;
                    GlobalCachePolyLines[polylineIndex].setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1);
                    GlobalCachePolyLines[polylineIndex].setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false);
                    GlobalCachePolyLines[polylineIndex].setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false);
                    GlobalCachePolyLines[polylineIndex].setWidth(mapPolylineProp.width ?
                    this.getUIContext().vp2px(mapPolylineProp.width) :   this.getUIContext().vp2px(5));
                    if (mapPolylineProp.color) {
                      GlobalCachePolyLines[polylineIndex].setColor(rgbaToHex(mapPolylineProp.color ? mapPolylineProp.color :
                        "rgba(0, 255, 0, 0.5)"));
                    }
                    if (mapPolylineProp.colors) {
                      let test = new Int32Array(mapPolylineProp.colors.length)
                      for (let i = 0; i < mapPolylineProp.colors.length; ++i) {
                        let str = mapPolylineProp.colors[i].replace("#", "0xff")
                        test[i] = parseInt(str.substring(2, str.length), 16)
                      }
                    }
                    break;
                  }
                }
              }
            })
          }
          if (!flagLine) {//处理GlobalCache中不存在的情况
            let polylineOptions = new PolylineOptions();
            this.polyLineTag.push(childPolyLineTag);
            GlobalCache.currentPagePolyline.set(childPolyLineTag, this.tag)
            if (this.aMap) {
              try {
                let polylineOptionsList = new ArrayList<LatLng>()
                for (let index = 0; index < mapPolylineProp.points.length; index++) {
                  polylineOptionsList.add(new LatLng(mapPolylineProp.points[index].latitude,
                    mapPolylineProp.points[index].longitude))
                }
                if (mapPolylineProp.colors) {
                  let test = new Int32Array(mapPolylineProp.colors.length)
                  for (let i = 0; i < mapPolylineProp.colors.length; ++i) {
                    let str = mapPolylineProp.colors[i].replace("#", "0xff")
                    test[i] = parseInt(str.substring(2, str.length), 16)
                  }
                  polylineOptions.setColorValues(test);
                } else if (mapPolylineProp.color) {
                  polylineOptions.setColor(rgbaToHex(mapPolylineProp.color ? mapPolylineProp.color : "rgba(0, 255, 0, 0.5)"))
                }
                let polyline = this.aMap?.addPolyline(
                  polylineOptions
                    .setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false)
                    .setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1)
                    .setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false)
                    .setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false)
                    .setWidth(mapPolylineProp.width ?
                    this.getUIContext().vp2px(mapPolylineProp.width) : this.getUIContext().vp2px(5))
                    .setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false));
                if(polyline){
                  polyline.setPoints(polylineOptionsList);
                  let polyLineTagAndDescriptorTagMap : HashMap<number, string> = new HashMap<number, string>();
                  polyLineTagAndDescriptorTagMap.set(childPolyLineTag, polyline.getId())
                  this.polylineTagAndDescriptorTagArray.push(polyLineTagAndDescriptorTagMap);
                  this.polylines.push(polyline);
                }
                GlobalCache.polyLinesTagAndDescriptorTag.set(this.tag, this.polylineTagAndDescriptorTagArray);
                GlobalCache.mapPolyLine.set(this.tag, this.polylines);
              } catch (error) {
                Logger.error('mapPolylineProp---------Error adding polyline:', error);
              }
            }
          }
          break;
        case A_MAP_MARKER_TYPE:
          let markerDescriptor: Descriptor = this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i])
          let markerChild: number[] = markerDescriptor.childrenTags;
          let mapMarkerProps = markerDescriptor.rawProps as AMapMarkerProps;
          this.markers = (GlobalCache.mapMarker.get(this.tag) ?? []);
          let markerTagAndDescriptorTagArray = GlobalCache.markerTagAndDescriptorTag.get(this.tag) ?? [];

          for (let index = 0; index < markerTagAndDescriptorTagArray.length; index++) {
            markerTagAndDescriptorTagArray[index].forEach(async (value: string, key: number, map: HashMap<number, string>) => {
              if (markerDescriptor.tag == key) {
                for (let markerIndex = 0; markerIndex < this.markers.length; markerIndex++) {
                  if (this.markers[markerIndex].getId() == value) {
                    flag = true;
                    this.markers[markerIndex].setPosition(new LatLng(mapMarkerProps.position.latitude, mapMarkerProps.position.longitude));
                    this.markers[markerIndex].setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
                      mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
                    this.markers[markerIndex].setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
                    //this.markers[markerIndex].setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
                    this.markers[markerIndex].setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
                    this.markers[markerIndex].getOptions().setInfoWindowOffset(mapMarkerProps.centerOffset?.x,mapMarkerProps.centerOffset?.y);
                    this.markers[markerIndex].setMarkerOptions(this.markers[markerIndex].getOptions());
                    //Handel Custom Marker
                    if(markerChild.length > 0) {
                      let bitmapView : BitmapDescriptor | undefined = await BitmapDescriptorFactory.fromView(() => {
                        this.customMarkerBuilder(markerDescriptor.tag);
                      })
                      this.markers[markerIndex].setIcon(bitmapView);
                    } else {
                      if (mapMarkerProps.icon) {
                        try {
                          await DownloadIcon.updataMakerIcon(this.getUIContext(), this.markers[markerIndex], mapMarkerProps.icon);
                        } catch (error) {
                          let bitmapDesNull: BitmapDescriptor | undefined =
                            await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                          if (bitmapDesNull) {
                            this.markers[markerIndex].setIcon(bitmapDesNull);
                          }
                        }
                      }
                    }
                    break;
                  }
                }
              }
            })
          }

          if (!flag) {
            let markerOptions = new MarkerOptions();
            GlobalCache.currentPageMarker.set(markerDescriptor.tag, this.tag)
            this.markerTag.push(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag);
            if (this.aMap) {
              try {
                if (markerOptions) {
                  markerOptions.setPosition(new LatLng(mapMarkerProps.position.latitude, mapMarkerProps.position.longitude));
                  markerOptions.setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
                    mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
                  //handle custom marker
                  if (markerChild.length > 0) {
                    let bitmapView: BitmapDescriptor | undefined = await BitmapDescriptorFactory.fromView(() => {
                      this.customMarkerBuilder(markerDescriptor.tag);
                    })
                    markerOptions.setIcon(bitmapView);
                  } else {
                    if (mapMarkerProps.icon) {
                      try {
                        await DownloadIcon.updataMakerIcon(this.getUIContext(), markerOptions, mapMarkerProps.icon);
                      } catch (error) {
                        let bitmapDesNull: BitmapDescriptor | undefined =
                          await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                        if (bitmapDesNull) {
                          markerOptions.setIcon(bitmapDesNull);
                        }
                      }
                    }
                  }
                  markerOptions.setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
                  markerOptions.setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
                  markerOptions.setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
                  markerOptions.setInfoWindowOffset(mapMarkerProps.centerOffset?.x,mapMarkerProps.centerOffset?.y);
                  let marker: Marker| undefined = this.aMap.addMarker(markerOptions);
                  if(marker){
                    let markerTagAndDescriptorTagMap : HashMap<number, string> = new HashMap<number, string>();
                    markerTagAndDescriptorTagMap.set(markerDescriptor.tag, marker.getId())
                    this.markerTagAndDescriptorTagArray.push(markerTagAndDescriptorTagMap);
                    this.markers.push(marker);
                  }
                  GlobalCache.markerTagAndDescriptorTag.set(this.tag, this.markerTagAndDescriptorTagArray);
                  GlobalCache.mapMarker.set(this.tag, this.markers);
                }
              } catch (error) {
                Logger.error('mapMarkerProps---------Error adding marker:', error);
              }
            }
          }
          break;
      }
      flag = false;
      flagLine = false;
    }
  }
  private  startLocationUpdates() {
    if (this.myLocationEnabled) {
      let options: AMapLocationOption = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        timeInterval: 2000,
        distanceInterval: 0,
        maxAccuracy: 20,
        allowsBackgroundLocationUpdates: false,
        locatingWithReGeocode: true,
        reGeocodeLanguage: AMapLocationReGeocodeLanguage.Chinese,
        isOffset: true
      };
      let locationListener: IAMapLocationListener = {
        onLocationChanged: (location) => {
          this.mapListener?.onLocationChanged(location)
        },
        onLocationError: (error) => {
          console.error('失败: ' + JSON.stringify(error));
        }
      };
      this.locationManager = new AMapLocationManagerImpl(globalContext);
      this.locationManager?.setLocationListener(AMapLocationType.Updating, locationListener);
      this.locationManager?.setLocationOption(AMapLocationType.Updating, options);
      this.locationManager?.startUpdatingLocation();

    }
  }

  private stopLocationUpdates() {
    this.locationManager?.stopUpdatingLocation();
  }
  @Builder
  customMarkerBuilder(markerTag: number) {
    ContentSlot(this.ctx.getContentForTag(markerTag))
  }

  activate(listener: OnLocationChangedListener): void {
    this.mapListener = listener;
    this.locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER);
    this.aMap?.setMyLocationStyle(this.locationStyle);
    if (this.myLocationEnabled) {
      this.startLocationUpdates();
    }
  }

  deactivate() {
    if (this.intervalId > 0) {
      clearInterval(this.intervalId);
      this.intervalId = 0;
    }
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      MapViewComponent({ mapViewName: new String(this.tag).valueOf() }).width('100%').height('100%')

    }
  }
}