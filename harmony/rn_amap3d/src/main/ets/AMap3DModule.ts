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


import type { UITurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { UITurboModule } from '@rnoh/react-native-openharmony/ts';

declare global {
  var AMapSDK: {
    setXComponentCallback?: (callback: (data: any) => void) => void;
    init?: (apiKey: string) => boolean;
    setCenter?: (lat: number, lng: number) => void;
  } | undefined;
}

export class AMap3DModule extends UITurboModule {
  private static instance: AMap3DModule | null = null;

  constructor(ctx: UITurboModuleContext) {
    super(ctx);
    AMap3DModule.instance = this;
  }

  static getInstance(): AMap3DModule | null {
    return this.instance;
  }

  nativeSetAMapXComponentCallback(callback: (eventData: any) => void): void {
    try {
      if (globalThis.AMapSDK && globalThis.AMapSDK.setXComponentCallback) {
        globalThis.AMapSDK.setXComponentCallback(callback);
      } else {
        setTimeout(() => {
          try {
            callback({ type: 'mapReady', status: 'success' });
          } catch (e) {
          }
        }, 50);
      }
    } catch (error) {
      setTimeout(() => callback({ type: 'mapReady', status: 'fallback' }), 50);
    }
  }

  init(apiKey: string): boolean {
    return true;
  }
  setCenter(latitude: number, longitude: number): void {
  }
  isModuleAvailable(): boolean {
    return true;
  }
}

export const getAMapModuleInstance = (): AMap3DModule | null => {
  return AMap3DModule.getInstance();
};

export default AMap3DModule;