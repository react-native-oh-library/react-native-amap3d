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
  Poi,
  PolygonOptions,
  Polyline,
  PolylineOptions
} from '@amap/amap_lbs_map3d';

import { Descriptor, RNOHContext, RNViewBase, ViewBaseProps } from '@rnoh/react-native-openharmony';
import { A_MAP_CIRCLE_VIEW_TYPE, AMapCircleProps, rgbaToHex } from './AMapCircle';
import { A_MAP_POLYGON_TYPE, AMapPolygonProps } from './AMapPolygon';
import { A_MAP_POLYLINE_TYPE, AMapPolylineProps } from './AMapPolyline';
import { A_MAP_MARKER_TYPE, AMapMarkerProps } from './AMapMarker';

import Logger from '../Logger';
import { ArrayList } from '@kit.ArkTS';
import GlobalCache from '../GlobalCache';

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

export type GDMapViewDescriptor = Descriptor<"AMapView", MapViewProps>;

export let globalContext: Context;

@Component
export struct AMapView {
  static NAME: string = "AMapView";
  static num: number = 0;
  ctx!: RNOHContext
  tag: number = -1
  type: string = ""
  polyLineTag: Array<number> = []
  markerTag: Array<number> = []
  @State gDMapDescriptor: GDMapViewDescriptor = {} as GDMapViewDescriptor
  private unregisterDescriptorChangesListener?: () => void = undefined
  private cleanupCallback?: () => void = undefined;

  aboutToAppear(): void {
    this.cleanupCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args: ESObject[]) => {
        if (command === 'moveCamera') {
          this.aMap?.animateCamera(CameraUpdateFactory.newCameraPosition(args[0]), null, args[1]);
        }
      });
    globalContext = getContext().getApplicationContext();
    this.gDMapDescriptor = this.ctx.descriptorRegistry.getDescriptor<GDMapViewDescriptor>(this.tag);
    GlobalCache.markers = [];
    this.getProp(this.gDMapDescriptor);
    this.show();
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        /*------ 当RN侧属性props有更改 -------*/
        this.gDMapDescriptor = (newDescriptor as GDMapViewDescriptor)
        this.getProp(this.gDMapDescriptor);
        this.getOverlay(this.gDMapDescriptor);
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
    GlobalCache.mapPolyLine.delete(this.tag);
  }

  //地图
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
    GlobalCache.mapViews.set(this.tag, mapview);
    this.mapView = GlobalCache.mapViews.get(this.tag);
    this.mapView.onCreate();
    this.mapView.getMapAsync((map:AMap) => {
      GlobalCache.maps.set(this.tag, map);
      this.aMap = GlobalCache.maps.get(this.tag);
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

      this.aMap?.setOnPolylineClickListener((polyLine: Polyline): void => {
        let len: number | undefined = GlobalCache.mapPolyLine.get(this.tag)?.length;
        let polyline: Array<Polyline> | undefined = GlobalCache.mapPolyLine.get(this.tag);
        if (len && polyline) {
          for (let index = 0; index < len; ++index) {
            if (polyLine.getOptions() == polyline[index].getOptions()) {
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
              if (marker.getOptions().getPosition() == markers[index].getPosition()) {
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
        })
      )
    })
  }

  show(): void {
    MapViewManager.getInstance().registerMapViewCreatedCallback(this.mapViewCreateCallback);
  }

  /**
   * 获取rn侧传递多来的prop
   */
  private getProp(descriptor: GDMapViewDescriptor) {
    this.mapType = descriptor.props.mapType;
    //初始位置
    if (descriptor.props.initialCameraPosition != null) {
      this.initialCameraPosition = descriptor.props.initialCameraPosition;
    }
    //是否显示当前定位
    if (descriptor.props.myLocationEnabled != null) {
      this.myLocationEnabled = descriptor.props.myLocationEnabled;
    }
    //是否显示室内地图
    if (descriptor.props.indoorViewEnabled != null) {
      this.indoorViewEnabled = descriptor.props.indoorViewEnabled;
    }
    //是否显示3D建筑
    if (descriptor.props.buildingsEnabled != null) {
      this.buildingsEnabled = descriptor.props.buildingsEnabled;
    }
    //是否显示标注
    if (descriptor.props.labelsEnabled != null) {
      this.labelsEnabled = descriptor.props.labelsEnabled;
    }
    //是否显示指南针
    if (descriptor.props.compassEnabled != null) {
      this.compassEnabled = descriptor.props.compassEnabled;
    }
    //是否显示放大缩小按钮
    if (descriptor.props.zoomControlsEnabled != null) {
      this.zoomControlsEnabled = descriptor.props.zoomControlsEnabled;
    }

    if (descriptor.props.myLocationButtonEnabled != null) {
      this.myLocationButtonEnabled = descriptor.props.myLocationButtonEnabled;
    }
    //是否显示比例尺
    if (descriptor.props.scaleControlsEnabled != null) {
      this.scaleControlsEnabled = descriptor.props.scaleControlsEnabled;
    }
    //是否显示路况
    if (descriptor.props.trafficEnabled != null) {
      this.trafficEnabled = descriptor.props.trafficEnabled;
    }
    //最大缩放级别
    if (descriptor.props.maxZoom != null) {
      this.maxZoom = descriptor.props.maxZoom;
    }
    //最小缩放级别
    if (descriptor.props.minZoom != null) {
      this.minZoom = descriptor.props.minZoom;
    }
    //是否启用缩放手势，用于放大缩小
    if (descriptor.props.zoomGesturesEnabled != null) {
      this.zoomGesturesEnabled = descriptor.props.zoomGesturesEnabled;
    }
    //是否启用滑动手势，用于平移
    if (descriptor.props.scrollGesturesEnabled != null) {
      this.scrollGesturesEnabled = descriptor.props.scrollGesturesEnabled;
    }
    //是否启用旋转手势，用于调整方向
    if (descriptor.props.rotateGesturesEnabled != null) {
      this.rotateGesturesEnabled = descriptor.props.rotateGesturesEnabled;
    }
    //是否启用倾斜手势，用于改变视角
    if (descriptor.props.tiltGesturesEnabled != null) {
      this.tiltGesturesEnabled = descriptor.props.tiltGesturesEnabled;
    }
    //设定定位的最小更新距离  @platform ios
    if (descriptor.props.distanceFilter != null) {
      this.distanceFilter = descriptor.props.distanceFilter;
    }
    //设定最小更新角度，默认为 1 度    @platform ios
    if (descriptor.props.headingFilter != null) {
      this.headingFilter = descriptor.props.headingFilter;
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
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapCircleProps;
          let circle = this.aMap?.addCircle(circleOptions);
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
          let polygonOptions = new PolygonOptions()
          let polygon = this.aMap?.addPolygon(polygonOptions);
          let mapPolygonProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapPolygonProps;
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
          let mapPolylineProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapPolylineProps;
          let polyLines = (GlobalCache.mapPolyLine.get(this.tag) ?? []);
          for (let i = 0; i < (GlobalCache.mapPolyLine.get(this.tag) ?? []).length; ++i) {
            let polylineOptionsList = new ArrayList<LatLng>()
            for (let index = 0; index < mapPolylineProp.points.length; index++) {
              polylineOptionsList.add(new LatLng(mapPolylineProp.points[index].latitude,
                mapPolylineProp.points[index].longitude))
            }
            if (polylineOptionsList == polyLines[i].getPoints()) {
              flagLine = true;
              polyLines[i].setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1);
              polyLines[i].setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false);
              polyLines[i].setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false);
              polyLines[i].setWidth(mapPolylineProp.width ? mapPolylineProp.width : 5);
              if (mapPolylineProp.color) {
                polyLines[i].setColor(rgbaToHex(mapPolylineProp.color ? mapPolylineProp.color :
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
          if (!flagLine) {
            let polylineOptions = new PolylineOptions();
            this.polyLineTag.push(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag);
            GlobalCache.currentPagePolyline.set(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i])
              .tag,
              this.tag)
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
                  let polyline = this.aMap?.addPolyline(polylineOptions
                    .setColorValues(test)
                    .setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false)
                    .setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1)
                    .setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false)
                    .setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false)
                    .setWidth(mapPolylineProp.width ? mapPolylineProp.width : 5)
                    .setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false));
                  if (polyline) {
                    polyline.setPoints(polylineOptionsList);
                    GlobalCache.polyLines.push(polyline);
                  }
                } else if (mapPolylineProp.color) {
                  let polyline = this.aMap?.addPolyline(polylineOptions
                    .setColor(rgbaToHex(mapPolylineProp.color ? mapPolylineProp.color :
                      "rgba(0, 255, 0, 0.5)"))
                    .setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false)
                    .setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1)
                    .setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false)
                    .setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false)
                    .setWidth(mapPolylineProp.width ? mapPolylineProp.width : 5)
                    .setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false));
                  if (polyline) {
                    polyline.setPoints(polylineOptionsList);
                    GlobalCache.polyLines.push(polyline);
                  }
                }
                GlobalCache.mapPolyLine.set(this.tag, GlobalCache.polyLines);
              } catch (error) {
                Logger.error('mapPolylineProp---------Error adding polyline:', error);
              }
            }
          }
          break;
        case A_MAP_MARKER_TYPE:
          let mapMarkerProps =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapMarkerProps;
          let marker = (GlobalCache.mapMarker.get(this.tag) ?? []);
          for (let i = 0; i < (GlobalCache.mapMarker.get(this.tag) ?? []).length; ++i) {
            if ((mapMarkerProps.position.latitude == marker[i].getPosition().latitude) &&
              (mapMarkerProps.position.longitude == marker[i].getPosition().longitude)) {
              flag = true;
              marker[i].setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
                mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
              marker[i].setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
              marker[i].setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
              marker[i].setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
              marker[i].getOptions().setInfoWindowOffset(mapMarkerProps.centerOffset?.x,mapMarkerProps.centerOffset?.y);
              marker[i].setMarkerOptions(marker[i].getOptions());
              if (mapMarkerProps.icon) {
                try {
                  let resoure: string = mapMarkerProps.icon["uri"];
                  let bitmapDes: BitmapDescriptor | undefined =
                    await BitmapDescriptorFactory.fromRawfilePath(globalContext, resoure);
                  marker[i].setIcon(bitmapDes);
                } catch (error) {
                  let bitmapDesNull: BitmapDescriptor | undefined =
                    await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                  if (bitmapDesNull) {
                    marker[i].setIcon(bitmapDesNull);
                  }
                }
              }
              break;
            }
          }
          if (!flag) {
            let markerOptions = new MarkerOptions();
            GlobalCache.currentPageMarker.set(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag,
              this.tag)
            this.markerTag.push(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag);
            if (this.aMap) {
              try {
                let marker = this.aMap.addMarker(markerOptions);
                if (marker) {
                  GlobalCache.markers.push(marker);
                  marker.setPosition(new LatLng(mapMarkerProps.position.latitude,
                    mapMarkerProps.position.longitude));
                  marker.setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
                    mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
                  if (mapMarkerProps.icon) {
                    try {
                      let resoure: string = mapMarkerProps.icon["uri"];
                      let bitmapDes: BitmapDescriptor | undefined =
                        await BitmapDescriptorFactory.fromRawfilePath(globalContext, resoure);
                      marker.setIcon(bitmapDes);
                    } catch (error) {
                      let bitmapDesNull: BitmapDescriptor | undefined =
                        await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                      if (bitmapDesNull) {
                        marker.setIcon(bitmapDesNull);
                      }
                    }
                  }
                  marker.setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
                  marker.setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
                  marker.setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
                  marker.getOptions().setInfoWindowOffset(mapMarkerProps.centerOffset?.x,mapMarkerProps.centerOffset?.y);
                  marker.setMarkerOptions(marker.getOptions());
                  GlobalCache.mapMarker.set(this.tag, GlobalCache.markers);
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

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      MapViewComponent({ mapViewName: new String(this.tag).valueOf() }).width('100%').height('100%')
    }
  }
}