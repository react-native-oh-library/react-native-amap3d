#ifndef HARMONY_MAPVIEW_SRC_MAIN_CPP_MAPVIEWJSIBINDER_H
#define HARMONY_MAPVIEW_SRC_MAIN_CPP_MAPVIEWJSIBINDER_H
#include "RNOHCorePackage/ComponentBinders/ViewComponentJSIBinder.h"

namespace rnoh {
class MapViewJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "mapType", "number");
        object.setProperty(rt, "initialCameraPosition", "Object");
        object.setProperty(rt, "myLocationEnabled", "boolean");
        object.setProperty(rt, "indoorViewEnabled", "boolean");
        object.setProperty(rt, "buildingsEnabled", "boolean");
        object.setProperty(rt, "compassEnabled", "boolean");
        object.setProperty(rt, "zoomControlsEnabled", "boolean");
        object.setProperty(rt, "scaleControlsEnabled", "boolean");
        object.setProperty(rt, "trafficEnabled", "boolean");
        object.setProperty(rt, "maxZoom", "number");
        object.setProperty(rt, "minZoom", "number");
        object.setProperty(rt, "zoomGesturesEnabled", "boolean");
        object.setProperty(rt, "scrollGesturesEnabled", "boolean");
        object.setProperty(rt, "rotateGesturesEnabled", "boolean");
        object.setProperty(rt, "tiltGesturesEnabled", "boolean");
        object.setProperty(rt, "distanceFilter", "number");
        object.setProperty(rt, "headingFilter", "number");
        return object;
    }
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override
    {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        events.setProperty(rt, "topPress", createDirectEvent(rt, "onPress"));
        events.setProperty(rt, "topPressPoi", createDirectEvent(rt, "onPressPoi"));
        events.setProperty(rt, "topLongPress", createDirectEvent(rt, "onLongPress"));
        events.setProperty(rt, "topCameraMove", createDirectEvent(rt, "onCameraMove"));
        events.setProperty(rt, "topCameraIdle", createDirectEvent(rt, "onCameraIdle"));
        events.setProperty(rt, "topLoad", createDirectEvent(rt, "onLoad"));
        return events;
    }
};

class CircleJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "center", "Object");
        object.setProperty(rt, "strokeColor", "number");
        object.setProperty(rt, "radius", "number");
        object.setProperty(rt, "strokeWidth", "number");
        object.setProperty(rt, "fillColor", "number");
        object.setProperty(rt, "levelIndex", "number");
        return object;
    }
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        return events;
    }
};

class HeatMapJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "data", "array");
        object.setProperty(rt, "radius", "number");
        object.setProperty(rt, "opacity", "number");
        return object;
    }
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        return events;
    }
};

class MultipointJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "items", "array");
        object.setProperty(rt, "icon", "Object");
        return object;
    }
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        return events;
    }
};

class MarkerJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "position", "Object");
        object.setProperty(rt, "opacity", "number");
        object.setProperty(rt, "draggable", "boolean");
        object.setProperty(rt, "flat", "boolean");
        object.setProperty(rt, "levelIndex", "number");
        object.setProperty(rt, "anchor", "Object");
        object.setProperty(rt, "centerOffset", "Object");
        object.setProperty(rt, "icon", "number");
        return object;
    }
    
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        events.setProperty(rt, "topPress", createDirectEvent(rt, "onPress"));
        events.setProperty(rt, "topDragStart", createDirectEvent(rt, "onDragStart"));
        events.setProperty(rt, "topDrag", createDirectEvent(rt, "onDrag"));
        events.setProperty(rt, "topDragEnd", createDirectEvent(rt, "onDragEnd"));
        return events;
    }
};

class PolygonJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "points", "array");
        object.setProperty(rt, "strokeWidth", "number");
        object.setProperty(rt, "strokeColor", "number");
        object.setProperty(rt, "fillColor", "number");
        object.setProperty(rt, "levelIndex", "number");
        return object;
    }
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        return events;
    }
};

class PolylineJSIBinder : public ViewComponentJSIBinder {
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "points", "array");
        object.setProperty(rt, "dotted", "boolean");
        object.setProperty(rt, "geodesic", "boolean");
        object.setProperty(rt, "levelIndex", "number");
        object.setProperty(rt, "color", "number");
        object.setProperty(rt, "colors", "array");
        object.setProperty(rt, "levelIndex", "number");
        object.setProperty(rt, "gradient", "boolean");
        return object;
    }
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        return facebook::jsi::Object(rt);
    }
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        events.setProperty(rt, "topPress", createDirectEvent(rt, "onPress"));
        return events;
    }
};

} // namespace  rnoh
#endif