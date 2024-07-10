#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>
#include "Props.h"

namespace facebook {
namespace react {

MapViewProps::MapViewProps(const PropsParserContext &context, const MapViewProps &sourceProps, const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      initialCameraPosition(convertRawProp(context, rawProps, "initialCameraPosition",
                                           sourceProps.initialCameraPosition, {{0, 0}, 0, 0, 0})),
      myLocationEnabled(convertRawProp(context, rawProps, "myLocationEnabled", sourceProps.myLocationEnabled, false)),
      indoorViewEnabled(convertRawProp(context, rawProps, "indoorViewEnabled", sourceProps.indoorViewEnabled, false)),
      buildingsEnabled(convertRawProp(context, rawProps, "buildingsEnabled", sourceProps.buildingsEnabled, false)),
      compassEnabled(convertRawProp(context, rawProps, "compassEnabled", sourceProps.compassEnabled, false)),
      zoomControlsEnabled(
          convertRawProp(context, rawProps, "zoomControlsEnabled", sourceProps.zoomControlsEnabled, false)),
      scaleControlsEnabled(
          convertRawProp(context, rawProps, "scaleControlsEnabled", sourceProps.scaleControlsEnabled, false)),
      trafficEnabled(convertRawProp(context, rawProps, "trafficEnabled", sourceProps.trafficEnabled, false)),
      maxZoom(convertRawProp(context, rawProps, "maxZoom", sourceProps.maxZoom, 0.f)),
      minZoom(convertRawProp(context, rawProps, "minZoom", sourceProps.minZoom, 0.f)),
      mapType(convertRawProp(context, rawProps, "mapType", sourceProps.mapType, 0)),
      zoomGesturesEnabled(
          convertRawProp(context, rawProps, "zoomGesturesEnabled", sourceProps.zoomGesturesEnabled, false)),
      scrollGesturesEnabled(
          convertRawProp(context, rawProps, "scrollGesturesEnabled", sourceProps.scrollGesturesEnabled, false)),
      rotateGesturesEnabled(
          convertRawProp(context, rawProps, "rotateGesturesEnabled", sourceProps.rotateGesturesEnabled, false)),
      tiltGesturesEnabled(
          convertRawProp(context, rawProps, "tiltGesturesEnabled", sourceProps.tiltGesturesEnabled, false)) {}

CircleProps::CircleProps(const PropsParserContext &context, const CircleProps &sourceProps, const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      circle(convertRawProp(context, rawProps, "data", sourceProps.circle, {0, 0})),
      radius(convertRawProp(context, rawProps, "radius", sourceProps.radius, 2.f)),
      strokeWidth(convertRawProp(context, rawProps, "strokeWidth", sourceProps.strokeWidth, 1.f)),
      strokeColor(convertRawProp(context, rawProps, "strokeColor", sourceProps.strokeColor, 0x000000)),
      fillColor(convertRawProp(context, rawProps, "fillColor", sourceProps.fillColor, 0x000000)),
      levelIndex(convertRawProp(context, rawProps, "levelIndex", sourceProps.levelIndex, 0)) {}

HeatMapProps::HeatMapProps(const PropsParserContext &context, const HeatMapProps &sourceProps, const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      radius(convertRawProp(context, rawProps, "radius", sourceProps.radius, 2.f)),
      opacity(convertRawProp(context, rawProps, "opacity", sourceProps.opacity, 0.f)),
      data(convertRawProp(context, rawProps, "data", sourceProps.data, {{0, 0}, {0, 0}, {0, 0}})) {}

MultipointProps::MultipointProps(const PropsParserContext &context, const MultipointProps &sourceProps,
                                 const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      items(convertRawProp(context, rawProps, "items", sourceProps.items, {{0, 0}, {0, 0}, {0, 0}})),
      icon(convertRawProp(context, rawProps, "radius", sourceProps.icon, {"/0", 0, 0, 0, "/0", "/0", "/0"})) {}

MarkerProps::MarkerProps(const PropsParserContext &context, const MarkerProps &sourceProps, const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      draggable(convertRawProp(context, rawProps, "draggable", sourceProps.draggable, false)),
      flat(convertRawProp(context, rawProps, "flat", sourceProps.flat, false)),
      anchor(convertRawProp(context, rawProps, "anchor", sourceProps.anchor, {0,0})),
      centerOffset(convertRawProp(context, rawProps, "centerOffset", sourceProps.centerOffset, {0,0})),
      levelIndex(convertRawProp(context, rawProps, "levelIndex", sourceProps.levelIndex, 0)),
      icon(convertRawProp(context, rawProps, "icon", sourceProps.icon,{"/0", 0, 0, 0, "/0", "/0", "/0"})) {}

PolylineProps::PolylineProps(const PropsParserContext &context, const PolylineProps &sourceProps,
                             const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      width(convertRawProp(context, rawProps, "width", sourceProps.width, 1.f)),
      color(convertRawProp(context, rawProps, "color", sourceProps.color, 0x000000)),
      colors(convertRawProp(context, rawProps, "colors", sourceProps.colors, {0xFF5566,0x112233,0x114477})),
      levelIndex(convertRawProp(context, rawProps, "levelIndex", sourceProps.levelIndex, 0.f)),
      geodesic(convertRawProp(context, rawProps, "geodesic", sourceProps.geodesic, false)),
      dotted(convertRawProp(context, rawProps, "dotted", sourceProps.dotted, false)),
      gradient(convertRawProp(context, rawProps, "gradient", sourceProps.gradient, false)),
      points(convertRawProp(context, rawProps, "points", sourceProps.points, {{0, 0}, {0, 0}, {0, 0}})) {}

PolygonProps::PolygonProps(const PropsParserContext &context, const PolygonProps &sourceProps, const RawProps &rawProps)
    : ViewProps(context, sourceProps, rawProps),
      points(convertRawProp(context, rawProps, "points", sourceProps.points, {{0, 0}, {0, 0}, {0, 0}})),
      strokeWidth(convertRawProp(context, rawProps, "strokeWidth", sourceProps.strokeWidth, 1.f)),
      strokeColor(convertRawProp(context, rawProps, "strokeColor", sourceProps.strokeColor, 0x000000)),
      fillColor(convertRawProp(context, rawProps, "fillColor", sourceProps.fillColor, 0x000000)),
      levelIndex(convertRawProp(context, rawProps, "levelIndex", sourceProps.levelIndex, 0.f)) {}

} // namespace react
} // namespace facebook