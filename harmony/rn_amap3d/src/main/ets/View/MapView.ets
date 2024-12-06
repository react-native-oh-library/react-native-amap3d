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

let globalContext: Context;

@Component
export struct AMapView {
  static NAME: string = "AMapView";
  ctx!: RNOHContext
  tag: number = -1
  type: string = ""
  polyLineTag: Array<number> = []
  markerTag: Array<number> = []
  @State gDMapDescriptor: GDMapViewDescriptor = {} as GDMapViewDescriptor
  private unregisterDescriptorChangesListener?: () => void = undefined
  private cleanupCallback?: () => void = undefined;
  //覆盖物
  circleOption: Array<CircleOptions> = []
  polylineOption: Array<PolylineOptions> = []
  polygonOption: Array<PolygonOptions> = []
  markerOption: Array<MarkerOptions> = []

  aboutToAppear(): void {
    globalContext = getContext().getApplicationContext();
    this.gDMapDescriptor = this.ctx.descriptorRegistry.getDescriptor<GDMapViewDescriptor>(this.tag);
    this.getProp(this.gDMapDescriptor);
    this.getOverlay(this.gDMapDescriptor);
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
       (newDescriptor) => {
        /*------ 当RN侧属性props有更改 -------*/
        console.log(`RNOH in GaoDeMap descriptor change`);
        this.gDMapDescriptor = (newDescriptor as GDMapViewDescriptor)
        this.getProp(this.gDMapDescriptor);
        this.getOverlay(this.gDMapDescriptor);
      }
    )
    this.show();
    this.cleanupCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args: ESObject[]) => {
        if (command === 'moveCamera') {
          this.aMap?.animateCamera(CameraUpdateFactory.newCameraPosition(args[0]), null, args[1]);
        }
      });
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
    this.mapView = mapview;
    this.mapView.onCreate();
    this.mapView.getMapAsync((map) => {
      this.aMap = map;
      Logger.info('map3d', 'EntryAbility', 'get map ' + this.aMap?.getCameraPosition()?.zoom);
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
      {
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
      }

      this.onLoadFunction();

      for (let index = 0; index < this.circleOption.length; ++index) {
        if (this.circleOption[index] && this.circleOption[index].getRadius()) {
          this.aMap?.addCircle(this.circleOption[index])
        }
      }

      for (let index = 0; index < this.polygonOption.length; ++index) {
        if (this.polygonOption[index] && this.polygonOption[index].getPoints().length > 0) {
          this.aMap?.addPolygon(this.polygonOption[index]);
        }
      }

      for (let index = 0; index < this.polylineOption.length; ++index) {
        if (this.polylineOption[index] && this.polylineOption[index].getPoints().length > 0) {
          this.aMap?.addPolyline(this.polylineOption[index]);
        }
      }

      for (let index = 0; index < this.markerOption.length; ++index) {
        this.aMap?.addMarker(this.markerOption[index]);
      }

      this.aMap?.setOnPolylineClickListener((polyLine: Polyline): void => {
        for (let index = 0; index < this.polylineOption.length; ++index) {
          if (polyLine.getOptions() == this.polylineOption[index]) {
            this.onPolyLineClickFunction(index)
          }
        }
      });

      this.aMap?.setOnMarkerClickListener((marker: Marker): boolean => {
        for (let index = 0; index < this.markerOption.length; ++index) {
          if (marker.getOptions().getPosition() == this.markerOption[index].getPosition()) {
            this.onMarkerClickFunction(index);
          }
        }
        return true;
      });

      this.aMap?.setOnMarkerDragListener(new OnMarkerDragListener(
        (DragStart: Marker) => {
          for (let index = 0; index < this.markerOption.length; ++index) {
            if (DragStart.getOptions() == this.markerOption[index]) {
              this.onMarkerDragStartFunction(index)
            }
          }
        },
        (Drag: Marker) => {
          for (let index = 0; index < this.markerOption.length; ++index) {
            if (Drag.getOptions() == this.markerOption[index]) {
              this.onMarkerDragFunction(index)
            }
          }
        },
        (DragEnd: Marker) => {
          for (let index = 0; index < this.markerOption.length; ++index) {
            if (DragEnd.getOptions() == this.markerOption[index]) {
              this.onMarkerDragEndFunction(DragEnd.getPosition(), index)
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
    for (let i = 0; i < descriptor.childrenTags.length; i++) {
      tagName =
        this.ctx.rnInstance.getComponentNameFromDescriptorType(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i])?.type);
      switch (tagName) {
        case A_MAP_CIRCLE_VIEW_TYPE:
          let circleOptions = new CircleOptions();
          let circleProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapCircleProps;
          circleOptions.setRadius(circleProp.radius ? circleProp.radius : 5000);
          circleOptions.setCenter(new LatLng(circleProp.center.latitude, circleProp.center.longitude));
          circleOptions.setFillColor(rgbaToHex(circleProp.fillColor ? circleProp.fillColor : "rgba(255, 0, 0, 0.5)"));
          circleOptions.setStrokeColor(rgbaToHex(circleProp.strokeColor ? circleProp.strokeColor :
            "rgba(0, 0, 255, 0.5)"));
          circleOptions.setStrokeWidth(circleProp.strokeWidth ? circleProp.strokeWidth : 5);
          this.circleOption.push(circleOptions);
          break;
        case A_MAP_POLYGON_TYPE:
          let polygonOptions = new PolygonOptions()
          let mapPolygonProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapPolygonProps;
          for (let index = 0; index < mapPolygonProp.points.length; index++) {
            polygonOptions.add(new LatLng(mapPolygonProp.points[index].latitude,
              mapPolygonProp.points[index].longitude))
          }
          polygonOptions.setFillColor(rgbaToHex(mapPolygonProp.fillColor ? mapPolygonProp.fillColor :
            "rgba(255, 0, 0, 0.5)"));
          polygonOptions.setStrokeWidth(mapPolygonProp.strokeWidth ? mapPolygonProp.strokeWidth : 5);
          polygonOptions.setStrokeColor(rgbaToHex(mapPolygonProp.strokeColor ? mapPolygonProp.strokeColor :
            "rgba(255, 0, 0, 0.5)"));
          polygonOptions.setZIndex(mapPolygonProp.zIndex ? mapPolygonProp.zIndex : 2);
          this.polygonOption.push(polygonOptions);
          break;
        case A_MAP_POLYLINE_TYPE:
          // add polyline
          let polylineOptions = new PolylineOptions();
          this.polyLineTag.push(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag);
          let mapPolylineProp =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapPolylineProps;
          polylineOptions.setZIndex(mapPolylineProp.zIndex ? mapPolylineProp.zIndex : 1);
          polylineOptions.setDottedLine(mapPolylineProp.dotted ? mapPolylineProp.dotted : false);
          polylineOptions.setGeodesic(mapPolylineProp.geodesic ? mapPolylineProp.geodesic : false);
          polylineOptions.setWidth(mapPolylineProp.width ? mapPolylineProp.width : 5);
          let polygonOptionsList = new ArrayList<LatLng>()
          for (let index = 0; index < mapPolylineProp.points.length; index++) {
            polygonOptionsList.add(new LatLng(mapPolylineProp.points[index].latitude,
              mapPolylineProp.points[index].longitude))
          }
          polylineOptions.setPoints(polygonOptionsList);
          if (mapPolylineProp.color) {
            polylineOptions.setColor(rgbaToHex(mapPolylineProp.color ? mapPolylineProp.color :
              "rgba(0, 255, 0, 0.5)"));
          }
          if (mapPolylineProp.colors) {
            let test = new Int32Array(mapPolylineProp.colors.length)
            for (let i = 0; i < mapPolylineProp.colors.length; ++i) {
              let str = mapPolylineProp.colors[i].replace("#", "0xff")
              test[i] = parseInt(str.substring(2, str.length), 16)
            }
            polylineOptions.setColorValues(test);
            polylineOptions.setGradient(mapPolylineProp.gradient ? mapPolylineProp.gradient : false);
          }
          this.polylineOption.push(polylineOptions)
          break;
        case A_MAP_MARKER_TYPE:
          let mapMarkerProps =
            this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).props as AMapMarkerProps;
          for (let i = 0; i < this.markerOption.length; ++i) { //遍历数组里是否有之前的经纬度 没有在新增
            if ((mapMarkerProps.position.latitude == this.markerOption[i].getPosition().latitude)
              && (mapMarkerProps.position.longitude == this.markerOption[i].getPosition().longitude)) {
              flag = true;
              this.markerOption[i].setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
                mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
              this.markerOption[i].setInfoWindowOffset(mapMarkerProps.centerOffset ? mapMarkerProps.centerOffset.x : 0,
                mapMarkerProps.centerOffset ? mapMarkerProps.centerOffset.y : 0);
              if (mapMarkerProps.icon) {
                let resoure: string = mapMarkerProps.icon["uri"];
                try {
                  let bitmapDes: BitmapDescriptor | undefined =
                    await BitmapDescriptorFactory.fromRawfilePath(globalContext, resoure);
                  this.markerOption[i].setIcon(bitmapDes);
                } catch (error) {
                  let bitmapDesNull: BitmapDescriptor | undefined =
                    await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                  if (bitmapDesNull) {
                    this.markerOption[i].setIcon(bitmapDesNull);
                  }
                }
              }
              this.markerOption[i].setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
              this.markerOption[i].setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
              this.markerOption[i].setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
              break;
            }
          }
          if (!flag) {
            let markerOptions = new MarkerOptions();
            this.markerTag.push(this.ctx.descriptorRegistry.getDescriptor(descriptor.childrenTags[i]).tag);
            markerOptions.setPosition(new LatLng(mapMarkerProps.position.latitude,
              mapMarkerProps.position.longitude));
            markerOptions.setAnchor(mapMarkerProps.anchor ? mapMarkerProps.anchor.x : 1,
              mapMarkerProps.anchor ? mapMarkerProps.anchor.y : 0.5);
            markerOptions.setInfoWindowOffset(mapMarkerProps.centerOffset ? mapMarkerProps.centerOffset.x : 0,
              mapMarkerProps.centerOffset ? mapMarkerProps.centerOffset.y : 0);
            markerOptions.setTitle('Marker');
            markerOptions.setSnippet('MapView Test')
            if (mapMarkerProps.icon) {
              let resoure: string = mapMarkerProps.icon["uri"];
              try {
                let bitmapDes: BitmapDescriptor | undefined =
                  await BitmapDescriptorFactory.fromRawfilePath(globalContext, resoure);
                markerOptions.setIcon(bitmapDes);
              } catch (error) {
                let bitmapDesNull: BitmapDescriptor | undefined =
                  await BitmapDescriptorFactory.fromRawfilePath(globalContext, "common/marker_default.png");
                if (bitmapDesNull) {
                  markerOptions.setIcon(bitmapDesNull);
                }
              }
            }
            markerOptions.setDraggable(mapMarkerProps.draggable ? mapMarkerProps.draggable : false);
            markerOptions.setZIndex(mapMarkerProps.zIndex ? mapMarkerProps.zIndex : 1);
            markerOptions.setFlat(mapMarkerProps.flat ? mapMarkerProps.flat : false);
            this.aMap?.addMarker(markerOptions);
            this.markerOption.push(markerOptions)
          }
          break;
      }
      flag = false;
    }
  }

  aboutToDisappear(): void {
    if (this.mapViewCreateCallback) {
      MapViewManager.getInstance().unregisterMapViewCreatedCallback(this.mapViewCreateCallback);
    }
    if (this.mapView) {
      this.mapView.onDestroy();
      this.mapView = undefined;
      this.aMap = undefined;
    }
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      MapViewComponent().width('100%').height('100%')
    }
  }
}