#ifndef HARMONY_RN_AMAP3D_SRC_MAIN_CPP_PROPS_H
#define HARMONY_RN_AMAP3D_SRC_MAIN_CPP_PROPS_H

#include <jsi/jsi.h>
#include <react/renderer/components/view/ViewProps.h>
#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>

namespace facebook {
namespace react {

struct LatLng {
    double latitude;
    double longitude;
};

struct CameraPosition {
    LatLng target;
    double zoom;
    double bearing;
    double tilt;
};

struct ImageSourcePropType {
    std::string uri;
    double width;
    double height;
    double scale;
    std::string method;
    std::string body;
    std::string bundle;
};

static inline void fromRawValue(const PropsParserContext &context, const RawValue &value, LatLng &result) {
    auto map = (butter::map<std::string, RawValue>)value;
    auto tmp_latitude = map.find("latitude");
    if (tmp_latitude != map.end()) {
        fromRawValue(context, tmp_latitude->second, result.latitude);
    }
    auto tmp_longitude = map.find("longitude");
    if (tmp_longitude != map.end()) {
        fromRawValue(context, tmp_longitude->second, result.longitude);
    }
}

static inline std::string toString(const LatLng &value) { return "[Object LatLng]"; }

static inline void fromRawValue(const PropsParserContext &context, const RawValue &value, CameraPosition &result) {
    auto map = (butter::map<std::string, RawValue>)value;
    auto tmp_target = map.find("target");
    if (tmp_target != map.end()) {
        fromRawValue(context, tmp_target->second, result.target);
    }
    auto tmp_zoom = map.find("zoom");
    if (tmp_zoom != map.end()) {
        fromRawValue(context, tmp_zoom->second, result.zoom);
    }
    auto tmp_bearing = map.find("bearing");
    if (tmp_bearing != map.end()) {
        fromRawValue(context, tmp_bearing->second, result.bearing);
    }
    auto tmp_tilt = map.find("tilt");
    if (tmp_tilt != map.end()) {
        fromRawValue(context, tmp_tilt->second, result.tilt);
    }
}

static inline std::string toString(const CameraPosition &value) { return "[Object CameraPosition]"; }

static inline void fromRawValue(const PropsParserContext &context, const RawValue &value, ImageSourcePropType &result) {
    auto map = (butter::map<std::string, RawValue>)value;
    auto tmp_uri = map.find("uri");
    if (tmp_uri != map.end()) {
        fromRawValue(context, tmp_uri->second, result.uri);
    }
    auto tmp_width = map.find("width");
    if (tmp_width != map.end()) {
        fromRawValue(context, tmp_width->second, result.width);
    }
    auto tmp_height = map.find("height");
    if (tmp_height != map.end()) {
        fromRawValue(context, tmp_height->second, result.height);
    }
    auto tmp_scale = map.find("scale");
    if (tmp_scale != map.end()) {
        fromRawValue(context, tmp_scale->second, result.scale);
    }
    auto tmp_method = map.find("method");
    if (tmp_method != map.end()) {
        fromRawValue(context, tmp_method->second, result.method);
    }
    auto tmp_body = map.find("body");
    if (tmp_body != map.end()) {
        fromRawValue(context, tmp_body->second, result.body);
    }
    auto tmp_bundle = map.find("bundle");
    if (tmp_bundle != map.end()) {
        fromRawValue(context, tmp_bundle->second, result.bundle);
    }
}

static inline std::string toString(const ImageSourcePropType &value) { return "[Object ImageSourcePropType]"; }

class JSI_EXPORT MapViewProps final : public ViewProps {
public:
    MapViewProps() = default;
    MapViewProps(const PropsParserContext &context, const MapViewProps &sourceProps, const RawProps &rawProps);

#pragma mark - Props
    // 地图类型
    int mapType;
    // 初始状态
    CameraPosition initialCameraPosition;
    // 是否显示当前定位
    bool myLocationEnabled;
    // 是否显示室内地图
    bool indoorViewEnabled;
    // 是否显示3D建筑
    bool buildingsEnabled;
    // 是否显示标注
    bool labelsEnabled;
    // 是否显示指南针
    bool compassEnabled;
    // 是否显示放大缩小按钮
    bool zoomControlsEnabled;
    // 是否显示比例尺
    bool scaleControlsEnabled;
    // 是否显示路况
    bool trafficEnabled;
    // 最大缩放级别
    double maxZoom;
    // 最小缩放级别
    double minZoom;
    // 是否启用缩放手势，用于放大缩小
    bool zoomGesturesEnabled;
    // 是否启用滑动手势，用于平移
    bool scrollGesturesEnabled;
    // 是否启用旋转手势，用于调整方向
    bool rotateGesturesEnabled;
    // 是否启用倾斜手势，用于改变视角
    bool tiltGesturesEnabled;
    //设定定位的最小更新距离
    double distanceFilter;
    //设定最小更新角度，默认为 1 度
    double headingFilter;
};

class JSI_EXPORT CircleProps final : public ViewProps {
public:
    CircleProps() = default;
    CircleProps(const PropsParserContext &context, const CircleProps &sourceProps, const RawProps &rawProps);

#pragma mark - CircleProps
    // 圆点坐标
    LatLng circle;
    // 半径
    double radius;
    // 边线宽度
    double strokeWidth;
    // 边线颜色
    int strokeColor;
    // 填充颜色
    int fillColor;
    // 层级
    int levelIndex;
};

class JSI_EXPORT HeatMapProps final : public ViewProps {
public:
    HeatMapProps() = default;
    HeatMapProps(const PropsParserContext &context, const HeatMapProps &sourceProps, const RawProps &rawProps);
#pragma mark - HeatMapProps
    // 节点坐标
    std::vector<LatLng> data;
    // 半径（米）
    double radius;
    // 透明度
    double opacity;
};

class JSI_EXPORT MultipointProps final : public ViewProps {
public:
    MultipointProps() = default;
    MultipointProps(const PropsParserContext &context, const MultipointProps &sourceProps, const RawProps &rawProps);

#pragma mark - Multipoint
    // 坐标点集合
    std::vector<LatLng> items;
    // icon
    ImageSourcePropType icon;
};

class JSI_EXPORT MarkerProps final : public ViewProps {
public:
    MarkerProps() = default;
    MarkerProps(const PropsParserContext &context, const MarkerProps &sourceProps, const RawProps &rawProps);

#pragma mark - MarkerProps
    // 坐标
    LatLng position;
    // 是否可拖拽
    bool draggable;
    // 是否平贴地图
    bool flat;
    // 层级
    int levelIndex;
    // 覆盖物锚点比例
    Point anchor;
    //覆盖物偏移位置
    Point centerOffset;
    // icon
    ImageSourcePropType icon;
};

class JSI_EXPORT PolylineProps final : public ViewProps {
public:
    PolylineProps() = default;
    PolylineProps(const PropsParserContext &context, const PolylineProps &sourceProps, const RawProps &rawProps);

#pragma mark - PolylineProps
    // 节点坐标
    std::vector<LatLng> points;
    // 线段宽度
    double width;
    // 线段颜色
    int color;
    // 多段颜色
    std::vector<int> colors;
    // 层级
    double levelIndex;
    // 是否绘制大地线
    bool geodesic;
    // 是否绘制虚线
    bool dotted;
    // 是否颜色渐变
    bool gradient;
};

class JSI_EXPORT PolygonProps final : public ViewProps {
public:
    PolygonProps() = default;
    PolygonProps(const PropsParserContext &context, const PolygonProps &sourceProps, const RawProps &rawProps);

#pragma mark - PolygonProps
    // 节点坐标
    std::vector<LatLng> points;
    // 边线宽度
    double strokeWidth;
    // 边线颜色
    int strokeColor;
    // 填充颜色
    int fillColor;
    // 层级
    double levelIndex;
};
} // namespace react
} // namespace facebook
#endif