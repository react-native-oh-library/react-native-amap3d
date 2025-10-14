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
import type {
  UITurboModule,
  UITurboModuleContext
} from '@rnoh/react-native-openharmony/ts';
import { RNPackage } from '@rnoh/react-native-openharmony/ts';
import { AMap3DModule } from './AMap3DModule';

export class AMap3DPackage extends RNPackage {
  // 确保模块被正确创建
  getUITurboModuleFactoryByNameMap(): Map<
  string,
  (ctx: UITurboModuleContext) => UITurboModule | null
  > {
    const map = new Map<string, (ctx: UITurboModuleContext) => UITurboModule | null>();
    map.set('AMapSdk', (ctx: UITurboModuleContext) => {
      try {
        const module = new AMap3DModule(ctx);
        return module;
      } catch (error) {
        return null;
      }
    });
    return map;
  }

  createTurboModulesFactory(ctx: UITurboModuleContext): any {
    return {
      createTurboModule: (name: string) => {
        if (name === 'AMapSdk') {
          return new AMap3DModule(ctx);
        }
        return null;
      },
      hasTurboModule: (name: string) => name === 'AMapSdk',
      prepareEagerTurboModules: () => Promise.resolve()
    };
  }

  getDebugName(): string {
    return 'AMap3DPackage';
  }
}

export const createAMap3DPackage = () => {
  console.log('Creating AMap3DPackage instance');
  return new AMap3DPackage({} as any);
};

export default AMap3DPackage;