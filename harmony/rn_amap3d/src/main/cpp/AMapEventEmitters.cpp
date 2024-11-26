/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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
#include "AMapEventEmitters.h"

namespace facebook {
namespace react {
void MapViewEventEmitter::onPress(struct onPressEvent event) const {
    
    dispatchEvent("Press", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "latitude", event.latitude);
        payload.setProperty(runtime, "longitude", event.longitude);
        return payload;
    });
}
void MapViewEventEmitter::onPressPoi(struct onMapPoiEvent event) const {
    dispatchEvent("PressPoi", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "id", event.id);
        payload.setProperty(runtime, "name", event.name);
        auto latLng = jsi::Object(runtime);
        latLng.setProperty(runtime, "latitude", event.latLng.latitude);
        latLng.setProperty(runtime, "longitude", event.latLng.longitude);
        payload.setProperty(runtime, "position", latLng);
        return payload;
    });
}

void MapViewEventEmitter::onLongPress(struct onLongPressEvent event) const {
    dispatchEvent("LongPress", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "latitude", event.latitude);
        payload.setProperty(runtime, "longitude", event.longitude);
        return payload;
    });
}

void MapViewEventEmitter::onCameraMove(struct CameraPosition event) const {
    dispatchEvent("CameraMove", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "zoom", event.zoom);
        payload.setProperty(runtime, "bearing", event.bearing);
        payload.setProperty(runtime, "tilt", event.tilt);
        auto target = jsi::Object(runtime);
        target.setProperty(runtime, "longitude", event.target.longitude);
        target.setProperty(runtime, "latitude", event.target.latitude);
        payload.setProperty(runtime, "targetValue", target);
        return payload;
    });
}

void MapViewEventEmitter::onCameraIdle(struct CameraPosition event) const {
    dispatchEvent("CameraIdle", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "zoom", event.zoom);
        payload.setProperty(runtime, "bearing", event.bearing);
        payload.setProperty(runtime, "tilt", event.tilt);
        auto target = jsi::Object(runtime);
        target.setProperty(runtime, "longitude", event.target.longitude);
        target.setProperty(runtime, "latitude", event.target.latitude);
        payload.setProperty(runtime, "targetValue", target);
        return payload;
    });
}

void MapViewEventEmitter::onLoad(struct onLoadEvent event) const {
    dispatchEvent("Load", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        return payload;
    });
}


void MarkerEventEmitter::onPress(struct onPressEvent event) const {
    dispatchEvent("Press", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void MarkerEventEmitter::onDragStart(struct onDragStartEvent event) const {
    dispatchEvent("DragStart", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void MarkerEventEmitter::onDrag(struct onDragEvent event) const {
    dispatchEvent("Drag", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void MarkerEventEmitter::onDragEnd(struct onDragEndEvent event) const {
    dispatchEvent("DragEnd", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "latitude", event.latitude);
        payload.setProperty(runtime, "longitude", event.longitude);
        return payload;
    });
}

void PolylineEventEmitter::onPress(struct onPressEvent event) const {
    dispatchEvent("Press", [event = std::move(event)](jsi::Runtime &runtime) {
        auto payload = jsi::Object(runtime);
        return payload;
    });
}
} // namespace react
} // namespace facebook