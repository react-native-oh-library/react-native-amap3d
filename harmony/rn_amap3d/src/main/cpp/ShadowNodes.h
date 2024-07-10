#ifndef HARMONY_MAPVIEW_SRC_MAIN_CPP_SHADOWNODES_H
#define HARMONY_MAPVIEW_SRC_MAIN_CPP_SHADOWNODES_H

#include "Props.h"
#include "AMapEventEmitters.h"
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <jsi/jsi.h>

namespace facebook {
namespace react {

JSI_EXPORT extern const char MapViewComponentName[];
JSI_EXPORT extern const char HeatMapComponentName[];
JSI_EXPORT extern const char CircleComponentName[];
JSI_EXPORT extern const char PolylineComponentName[];
JSI_EXPORT extern const char PolygonComponentName[];
JSI_EXPORT extern const char MultipointComponentName[];
JSI_EXPORT extern const char MarkerComponentName[];

/*
 * `ShadowNode` for <RNCViewPager> component.
 */
using MapViewShadowNode = ConcreteViewShadowNode<MapViewComponentName, MapViewProps,MapViewEventEmitter>;
using HeatMapShadowNode = ConcreteViewShadowNode<HeatMapComponentName, HeatMapProps,HeatMapEventEmitter>;
using CircleShadowNode = ConcreteViewShadowNode<CircleComponentName, CircleProps,CircleEventEmitter>;
using PolylineShadowNode = ConcreteViewShadowNode<PolylineComponentName, PolylineProps,PolylineEventEmitter>;
using PolygonShadowNode = ConcreteViewShadowNode<PolygonComponentName, PolygonProps,PolygonEventEmitter>;
using MultipointShadowNode = ConcreteViewShadowNode<MultipointComponentName, MultipointProps,MultiPointEventEmitter>;
using MarkerShadowNode = ConcreteViewShadowNode<MarkerComponentName, MarkerProps,MarkerEventEmitter>;

} // namespace react
} // namespace facebook
#endif