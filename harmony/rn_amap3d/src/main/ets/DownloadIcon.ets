import { Marker, MarkerOptions, BitmapDescriptor, BitmapDescriptorFactory, } from '@amap/amap_lbs_map3d';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import Logger from './Logger';

export class DownloadIcon {
  static async updataMakerIcon(context: UIContext, marker: Marker | MarkerOptions, icon: BitmapDescriptor) {
    let src: string = icon['uri'];
    let bitmapDes: BitmapDescriptor | undefined
    if (src) {
      if (src!.startsWith('http://') || src!.startsWith('https://')) {
        const filePath: string = await DownloadIcon.doLoadHttpImage(context, src, 0);
        let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
        bitmapDes = await BitmapDescriptorFactory.fromFd(file.fd);
        marker.setIcon(bitmapDes);
        fileIo.closeSync(file.fd);
      } else {
        bitmapDes =
          await BitmapDescriptorFactory.fromRawfilePath(context.getHostContext()!.getApplicationContext(), src);
        marker.setIcon(bitmapDes);
      }
    }
  }

  static async doLoadHttpImage(uiContext: UIContext, url: string, redirectCount: number = 0): Promise<string> {
    let context = uiContext.getHostContext()! as common.UIAbilityContext;
    let filesDir = context.filesDir;
    const fullFileName: string = filesDir + "/" + new Date().getTime() + `.${url.slice(url.length - 3)}`;
    if (redirectCount > 5) {
      throw new Error("Too many redirects");
    }
    return new Promise((resolve, reject) => {
      const config: request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url,
        method: 'GET',
        headers: {},
        saveas: fullFileName,
        overwrite: true,
        mode: request.agent.Mode.FOREGROUND
      };
      request.agent.create(context, config).then((task: request.agent.Task) => {
        task.on('completed', () => {
          Logger.info(`[maker icon]: finish downloadFile`);
          resolve(fullFileName);
        })
        task.on('failed', (progress: request.agent.Progress) => {
          Logger.info('[maker icon]: downloadFile failed.', JSON.stringify(progress));
          reject(new Error('downloadFile failed: ' + JSON.stringify(progress)));
        });
        task.on('response', async (response: request.agent.HttpResponse) => {
          Logger.info('[maker icon]: downloadFile response.', JSON.stringify(response));
          if (response.statusCode > 300 && response.statusCode < 400) {
            let redirectUrl: string = response.headers.get('location')?.toString() ?? '';
            task.off('progress');
            task.off('completed');
            task.off('response');
            task.stop();
            try {
              const result = await DownloadIcon.doLoadHttpImage(uiContext, redirectUrl, redirectCount + 1);
              Logger.info(`[maker icon]:result: ${result} -----count: ${redirectCount}}`);
              resolve(result)
            } catch (e) {
              reject(e);
            }
          }
        });
        task.start();
      }).catch((err: BusinessError) => {
        Logger.info(`[maker icon]: error downloadHttpFile`);
        reject(new Error("downloadFile failed: " + err.message));
      });
    });
  }
}
