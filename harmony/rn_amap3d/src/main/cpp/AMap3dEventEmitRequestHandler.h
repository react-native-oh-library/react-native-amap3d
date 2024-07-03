/**
 * MIT License
 *
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#pragma once
#include "RNOH/ArkJS.h"
#include "RNOH/EventEmitRequestHandler.h"
#include "AMapEventEmitters.h"

#include <glog/logging.h>
#include "folly/json.h"

using namespace facebook;
namespace rnoh {

enum class AMapViewEventType {
    RNC_ONPress = 0,
    RNC_ONPressPoi = 1,
    RNC_ONLongPress = 2,
    RNC_ONCameraMove = 3,
    RNC_ONCameraIdle = 4,
    RNC_ONLoad = 5
};

enum class AMapMarkerEventType { RNC_ONPress = 0, RNC_ONDragStart = 2, RNC_ONDrag = 3, RNC_ONDragEnd = 4 };

AMapViewEventType getAMapViewEventType(ArkJS &arkJs, napi_value eventObject) {
    auto eventType = arkJs.getString(arkJs.getObjectProperty(eventObject, "type"));
    if (eventType == "onPress") {
        return AMapViewEventType::RNC_ONPress;
    } else if (eventType == "onPressPoi") {
        return AMapViewEventType::RNC_ONPressPoi;
    } else if (eventType == "onLongPress") {
        return AMapViewEventType::RNC_ONLongPress;
    } else if (eventType == "onCameraMove") {
        return AMapViewEventType::RNC_ONCameraMove;
    } else if (eventType == "onCameraIdle") {
        return AMapViewEventType::RNC_ONCameraIdle;
    } else if (eventType == "onLoad") {
        return AMapViewEventType::RNC_ONLoad;
    } else {
        throw std::runtime_error("Unknown Page event type");
    }
}

AMapMarkerEventType getAMapMarkerEventType(ArkJS &arkJs, napi_value eventObject) {
    auto eventType = arkJs.getString(arkJs.getObjectProperty(eventObject, "type"));
    if (eventType == "onPress") {
        return AMapMarkerEventType::RNC_ONPress;
    } else if (eventType == "onDragStart") {
        return AMapMarkerEventType::RNC_ONDragStart;
    } else if (eventType == "onDrag") {
        return AMapMarkerEventType::RNC_ONDrag;
    } else if (eventType == "onDragEnd") {
        return AMapMarkerEventType::RNC_ONDragEnd;
    } else {
        throw std::runtime_error("Unknown Page event type");
    }
}

class AMapViewEventEmitRequestHandler : public EventEmitRequestHandler {
public:
    void handleEvent(EventEmitRequestHandler::Context const &ctx) override {
        LOG(INFO) << "AMapViewEventEmitRequestHandler AMapViewEventType::RNC_ONLoad entry";
        if (ctx.eventName != "AMapView") {
            return;
        }
        ArkJS arkJs(ctx.env);
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<facebook::react::MapViewEventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }
        LOG(INFO) << "AMapViewEventEmitRequestHandler AMapViewEventType eventEmitter not nullptr";
        switch (getAMapViewEventType(arkJs, ctx.payload)) {
        case AMapViewEventType::RNC_ONPress: {
            RNOHNapiObject target = arkJs.getObject((arkJs.getObjectProperty(ctx.payload, "LatLng")));
            double latitude = (double)arkJs.getDouble(target.getProperty("latitude"));
            double longitude = (double)arkJs.getDouble(target.getProperty("longitude"));
            facebook::react::MapViewEventEmitter::onPressEvent event{latitude, longitude};
            eventEmitter->onPress(event);
            break;
        }
        case AMapViewEventType::RNC_ONPressPoi: {
            RNOHNapiObject Poi = arkJs.getObject((arkJs.getObjectProperty(ctx.payload, "Poi")));
            std::string id = (std::string)arkJs.getString(Poi.getProperty("poiid"));
            std::string name = (std::string)arkJs.getString(Poi.getProperty("name"));
            RNOHNapiObject latLngObject = arkJs.getObject(Poi.getProperty("coordinate"));
            double latitude = (double)arkJs.getDouble(latLngObject.getProperty("latitude"));
            double longitude = (double)arkJs.getDouble(latLngObject.getProperty("longitude"));
            facebook::react::MapViewEventEmitter::LatLng latLngC{latitude, longitude};
            facebook::react::MapViewEventEmitter::onMapPoiEvent event{id, name, latLngC};
            eventEmitter->onPressPoi(event);
            break;
        }
         case AMapViewEventType::RNC_ONLongPress: {
            RNOHNapiObject target = arkJs.getObject((arkJs.getObjectProperty(ctx.payload, "LatLng")));
            double latitude = (double)arkJs.getDouble(target.getProperty("latitude"));
            double longitude = (double)arkJs.getDouble(target.getProperty("longitude"));
            facebook::react::MapViewEventEmitter::onLongPressEvent event{latitude, longitude};
            eventEmitter->onLongPress(event);
            break;
        }
        case AMapViewEventType::RNC_ONCameraMove: {
            RNOHNapiObject cameraPosition = arkJs.getObject((arkJs.getObjectProperty(ctx.payload, "CameraPosition")));
            double zoom = (double)arkJs.getDouble(cameraPosition.getProperty("zoom"));
            double bearing = (double)arkJs.getDouble(cameraPosition.getProperty("bearing"));
            double tilt = (double)arkJs.getDouble(cameraPosition.getProperty("tilt"));
            RNOHNapiObject target = arkJs.getObject(cameraPosition.getProperty("target"));
            double latitude = (double)arkJs.getDouble(target.getProperty("latitude"));
            double longitude = (double)arkJs.getDouble(target.getProperty("longitude"));
            facebook::react::MapViewEventEmitter::LatLng targetL{latitude, longitude};
            facebook::react::MapViewEventEmitter::CameraPosition event{targetL, zoom, bearing, tilt};
            eventEmitter->onCameraMove(event);
            break;
        }
        case AMapViewEventType::RNC_ONCameraIdle: {
            RNOHNapiObject cameraPosition = arkJs.getObject((arkJs.getObjectProperty(ctx.payload, "CameraPosition")));
            double zoom = (double)arkJs.getDouble(cameraPosition.getProperty("zoom"));
            double bearing = (double)arkJs.getDouble(cameraPosition.getProperty("bearing"));
            double tilt = (double)arkJs.getDouble(cameraPosition.getProperty("tilt"));
            RNOHNapiObject target = arkJs.getObject(cameraPosition.getProperty("target"));
            double latitude = (double)arkJs.getDouble(target.getProperty("latitude"));
            double longitude = (double)arkJs.getDouble(target.getProperty("longitude"));
            facebook::react::MapViewEventEmitter::LatLng targetL{latitude, longitude};
            facebook::react::MapViewEventEmitter::CameraPosition event{targetL, zoom, bearing, tilt};
            eventEmitter->onCameraIdle(event);
            break;
        }
        case AMapViewEventType::RNC_ONLoad: {
            LOG(INFO) << "AMapViewEventEmitRequestHandler AMapViewEventType::RNC_ONLoad entry";
            facebook::react::MapViewEventEmitter::onLoadEvent event{};
            eventEmitter->onLoad(event);
            break;
        }
        default:
            break;
        }
    };
};

class AMapMarkerEventEmitRequestHandler : public EventEmitRequestHandler {
public:
    void handleEvent(EventEmitRequestHandler::Context const &ctx) override {
        if (ctx.eventName != "AMapMarker") {
            return;
        }
        ArkJS arkJs(ctx.env);
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<react::MarkerEventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }

        switch (getAMapMarkerEventType(arkJs, ctx.payload)) {
        case AMapMarkerEventType::RNC_ONPress: {
            facebook::react::MarkerEventEmitter::onPressEvent event{};
            eventEmitter->onPress(event);
            break;
        }
        case AMapMarkerEventType::RNC_ONDragStart: {
            facebook::react::MarkerEventEmitter::onDragStartEvent event{};
            eventEmitter->onDragStart(event);
            break;
        }
        case AMapMarkerEventType::RNC_ONDrag: {
            facebook::react::MarkerEventEmitter::onDragEvent event{};
            eventEmitter->onDrag(event);
            break;
        }
        case AMapMarkerEventType::RNC_ONDragEnd: {
            RNOHNapiObject target = arkJs.getObject((arkJs.getObjectProperty(ctx.payload, "LatLng")));
            double latitude = (double)arkJs.getDouble(target.getProperty("latitude"));
            double longitude = (double)arkJs.getDouble(target.getProperty("longitude"));
            facebook::react::MarkerEventEmitter::onDragEndEvent event{latitude, longitude};
            eventEmitter->onDragEnd(event);
            break;
        }
        default:
            break;
        }
    };
};

class AMapPolylineEventEmitRequestHandler : public EventEmitRequestHandler {
public:
    void handleEvent(EventEmitRequestHandler::Context const &ctx) override {
        if (ctx.eventName != "AMapPolyline") {
            return;
        }
        ArkJS arkJs(ctx.env);
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<facebook::react::PolylineEventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }
        facebook::react::PolylineEventEmitter::onPressEvent event{};
        eventEmitter->onPress(event);
    };
};

} // namespace rnoh