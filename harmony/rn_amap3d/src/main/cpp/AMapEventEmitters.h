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

#pragma once
#include "react/renderer/components/view/ViewEventEmitter.h"
#include "jsi/jsi.h"

namespace facebook {
namespace react {
class JSI_EXPORT MapViewEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;
    struct LatLng {
        double latitude;
        double longitude;
    };
    struct LatLngBounds {
        LatLng southwest;
        LatLng northeast;
    };
    struct onPressEvent {
        double latitude;
        double longitude;
    };
    struct onMapPoiEvent {
        std::string id;
        std::string name;
        LatLng latLng;
    };
    struct onLongPressEvent {
        double latitude;
        double longitude;
    };
    struct CameraPosition {
        LatLng target;
        double zoom;
        double bearing;
        double tilt;
    };
    
    struct onLoadEvent {};

    void onPress(struct onPressEvent value) const;
    void onPressPoi(struct onMapPoiEvent value) const;
    void onLongPress(struct onLongPressEvent value) const;
    void onCameraMove(struct CameraPosition value) const;
    void onCameraIdle(struct CameraPosition value) const;
    void onLoad(struct onLoadEvent value) const;
};
class JSI_EXPORT CircleEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;
};
class JSI_EXPORT HeatMapEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;
};

class JSI_EXPORT MultiPointEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;
};

class JSI_EXPORT MarkerEventEmitter : public ViewEventEmitter {
public:
    struct onPressEvent {};
    struct onDragStartEvent {};
    struct onDragEvent {};
    struct onDragEndEvent {
        double latitude;
        double longitude;
    };
    void onPress(struct onPressEvent value) const;
    void onDragStart(struct onDragStartEvent value) const;
    void onDrag(struct onDragEvent value) const;
    void onDragEnd(struct onDragEndEvent value) const;
    using ViewEventEmitter::ViewEventEmitter;
};
class JSI_EXPORT PolygonEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;
};
class JSI_EXPORT PolylineEventEmitter : public ViewEventEmitter {
public:
    struct onPressEvent {};
    void onPress(struct onPressEvent value) const;
    using ViewEventEmitter::ViewEventEmitter;
};
} // namespace react
} // namespace facebook