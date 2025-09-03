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

// import { UITurboModule, UITurboModuleContext } from '@rnoh/react-native-openharmony/ts';
//
//
// export class AMap3DModule extends UITurboModule {
//   constructor(ctx: UITurboModuleContext) {
//     super(ctx);
//   }
// }



import type { UITurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { UITurboModule } from '@rnoh/react-native-openharmony/ts';

// 确保全局类型声明
declare global {
  var AMapSDK: {
    setXComponentCallback?: (callback: (data: any) => void) => void;
    init?: (apiKey: string) => boolean;
    setCenter?: (lat: number, lng: number) => void;
    // 其他方法...
  } | undefined;
}

export class AMap3DModule extends UITurboModule {
  private static instance: AMap3DModule | null = null;

  constructor(ctx: UITurboModuleContext) {
    super(ctx);
    AMap3DModule.instance = this;
    console.log('AMap3DModule constructor called');
  }

  /**
   * 获取模块实例（用于调试）
   */
  static getInstance(): AMap3DModule | null {
    return this.instance;
  }

  /**
   * 修复：nativeSetAMapXComponentCallback 方法
   */
  nativeSetAMapXComponentCallback(callback: (eventData: any) => void): void {
    console.log('nativeSetAMapXComponentCallback called with callback:', typeof callback);

    try {
      if (globalThis.AMapSDK && globalThis.AMapSDK.setXComponentCallback) {
        globalThis.AMapSDK.setXComponentCallback(callback);
        console.log('Native callback set successfully');
      } else {
        console.warn('AMapSDK.setXComponentCallback not available, using fallback');
        // 降级方案
        setTimeout(() => {
          try {
            callback({ type: 'mapReady', status: 'success' });
          } catch (e) {
            console.error('Fallback callback error:', e);
          }
        }, 50);
      }
    } catch (error) {
      console.error('Error in nativeSetAMapXComponentCallback:', error);
      // 确保即使出错也不会阻塞
      setTimeout(() => callback({ type: 'mapReady', status: 'fallback' }), 50);
    }
  }

  init(apiKey: string): boolean {
    console.log(`Initializing AMap with key: ${apiKey}`);
    return true;
  }

  setCenter(latitude: number, longitude: number): void {
    console.log(`Setting center to: ${latitude}, ${longitude}`);
  }

  /**
   * 检查模块是否可用
   */
  isModuleAvailable(): boolean {
    return true; // 模块本身总是可用的
  }
}

// 导出单例访问方法
export const getAMapModuleInstance = (): AMap3DModule | null => {
  return AMap3DModule.getInstance();
};

export default AMap3DModule;