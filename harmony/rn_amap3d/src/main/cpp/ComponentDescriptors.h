#ifndef HARMONY_MAPVIEW_SRC_MAIN_CPP_COMPONENTDESCRIPTORS_H
#define HARMONY_MAPVIEW_SRC_MAIN_CPP_COMPONENTDESCRIPTORS_H


#include "ShadowNodes.h"
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook {
namespace react {
using MapViewComponentDescriptor = ConcreteComponentDescriptor<MapViewShadowNode>;
using HeatMapComponentDescriptor = ConcreteComponentDescriptor<HeatMapShadowNode>;
using CircleComponentDescriptor = ConcreteComponentDescriptor<CircleShadowNode>;
using PolylineComponentDescriptor = ConcreteComponentDescriptor<PolylineShadowNode>;
using PolygonComponentDescriptor = ConcreteComponentDescriptor<PolygonShadowNode>;
using MultipointComponentDescriptor = ConcreteComponentDescriptor<MultipointShadowNode>;
using MarkerComponentDescriptor = ConcreteComponentDescriptor<MarkerShadowNode>;
} // namespace react
} // namespace facebook
#endif