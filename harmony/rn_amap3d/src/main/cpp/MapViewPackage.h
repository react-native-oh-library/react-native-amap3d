#ifndef HARMONY_MAPVIEW_SRC_MAIN_CPP_MAPVIEWPACKAGE_H
#define HARMONY_MAPVIEW_SRC_MAIN_CPP_MAPVIEWPACKAGE_H


#include "RNOH/Package.h"
#include "ComponentDescriptors.h"
#include "MapViewJSIBinder.h"
#include "AMap3dEventEmitRequestHandler.h"

namespace rnoh {

class MapViewPackage : public Package {
public:
    MapViewPackage(Package::Context ctx) : Package(ctx) {}
    std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override {
        return {facebook::react::concreteComponentDescriptorProvider<facebook::react::MapViewComponentDescriptor>(),
                facebook::react::concreteComponentDescriptorProvider<facebook::react::HeatMapComponentDescriptor>(),
                facebook::react::concreteComponentDescriptorProvider<facebook::react::CircleComponentDescriptor>(),
                facebook::react::concreteComponentDescriptorProvider<facebook::react::PolylineComponentDescriptor>(),
                facebook::react::concreteComponentDescriptorProvider<facebook::react::PolygonComponentDescriptor>(),
                facebook::react::concreteComponentDescriptorProvider<facebook::react::MultipointComponentDescriptor>(),
                facebook::react::concreteComponentDescriptorProvider<facebook::react::MarkerComponentDescriptor>()};
    }

    ComponentJSIBinderByString createComponentJSIBinderByName() override {
        return {{"AMapView", std::make_shared<MapViewJSIBinder>()},
                {"AMapHeatMap", std::make_shared<HeatMapJSIBinder>()},
                {"AMapCircle", std::make_shared<CircleJSIBinder>()},
                {"AMapPolyline", std::make_shared<PolylineJSIBinder>()},
                {"AMapPolygon", std::make_shared<PolygonJSIBinder>()},
                {"AMapMultiPoint", std::make_shared<MultipointJSIBinder>()},
                {"AMapMarker", std::make_shared<MarkerJSIBinder>()}};
    }
    EventEmitRequestHandlers createEventEmitRequestHandlers() override {
        return {
            {std::make_shared<AMapViewEventEmitRequestHandler>()},
            {std::make_shared<AMapMarkerEventEmitRequestHandler>()},
            {std::make_shared<AMapPolylineEventEmitRequestHandler>()},
        };
    }
};
} // namespace rnoh
#endif