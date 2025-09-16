import { Marker, MarkerOptions, BitmapDescriptor, BitmapDescriptorFactory, } from '@amap/amap_lbs_map3d';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import Logger from './Logger';

interface packOptsType {
  format: string;
  quality: number;
}
const IMAGE_FORMAT = ['gif', 'jpeg', 'jpg', 'webp', 'png'];
const ENCODE_FORMAT = ['image/png', 'image/jpeg', 'image/webp'];

export class DownloadIcon {
  static async updataMakerIcon(context: UIContext, marker: Marker | MarkerOptions, icon: BitmapDescriptor) {
    let src: string = icon['uri'];
    let width: number | undefined = icon['width'] || undefined;
    let height: number | undefined = icon['height'] || undefined;

    let bitmapDes: BitmapDescriptor | undefined;

    if (src) {
      if (src!.startsWith('http://') || src!.startsWith('https://')) {
        const filePath: string = await DownloadIcon.doLoadHttpImage(context, src, 0);
        let imagePathToUse = filePath;
        
        if (width !== undefined || height !== undefined) {
          // Process the image and get the processed path (could be temp file or original)
          imagePathToUse = await DownloadIcon.resizeImage(filePath, width, height);
        }
        
        let file = fileIo.openSync(imagePathToUse, fileIo.OpenMode.READ_ONLY);
        bitmapDes = await BitmapDescriptorFactory.fromFd(file.fd);
        fileIo.closeSync(file.fd);
        marker.setIcon(bitmapDes);
        
        // Clean up temporary file if it was created and is different from original
        if (imagePathToUse !== filePath) {
          fileIo.unlinkSync(imagePathToUse);
        }
      } else {
        bitmapDes =
          await BitmapDescriptorFactory.fromRawfilePath(context.getHostContext()!.getApplicationContext(), src);
        marker.setIcon(bitmapDes);
      }
    }
  }

  static async resizeImage(filePath: string, targetWidth: number | undefined, targetHeight: number | undefined): Promise<string> {
    // Create a safe temporary file path by inserting .temp before the extension
    const lastDotIndex = filePath.lastIndexOf('.');
    let tempFilePath: string;
    if (lastDotIndex !== -1) {
      tempFilePath = filePath.substring(0, lastDotIndex) + '.temp' + filePath.substring(lastDotIndex);
    } else {
      tempFilePath = filePath + '.temp';
    }
    
    try {
      let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const imageSource = image.createImageSource(file.fd);
      // Get picture format information
      const imageInfo = imageSource.getImageInfoSync();
      const mimeType = imageInfo.mimeType || '';
      targetWidth = targetWidth !== undefined ? targetWidth : imageInfo.size.width;
      targetHeight = targetHeight !== undefined ? targetHeight : imageInfo.size.height;
      fileIo.closeSync(file.fd);
      
      const finalWidth = Math.round(targetWidth);
      const finalHeight = Math.round(targetHeight);
      let decodingOptions: image.DecodingOptions = {
        sampleSize: 1,
        editable: true,
        desiredSize: { width: finalWidth, height: finalHeight },
        index: 0
      };
      
      let pixelMap = imageSource.createPixelMapSync(decodingOptions);

      const imagePacker = image.createImagePacker();

      let outputFormat: string;
      if (mimeType.includes(IMAGE_FORMAT[0])) {
        outputFormat = ENCODE_FORMAT[0];
      } else if (mimeType.includes(IMAGE_FORMAT[1]) || mimeType.includes(IMAGE_FORMAT[2])) {
        outputFormat = ENCODE_FORMAT[1];
      } else if (mimeType.includes(IMAGE_FORMAT[3])) {
        outputFormat = ENCODE_FORMAT[2];
      } else {
        outputFormat = ENCODE_FORMAT[0];
      }

      const packOpts: packOptsType = {
        format: outputFormat,
        quality: 100
      };

      const data = await imagePacker.packToData(pixelMap, packOpts);
      const tempFile = fileIo.openSync(tempFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      await fileIo.write(tempFile.fd, data);
      fileIo.closeSync(tempFile.fd);
      
      pixelMap.release();
      imageSource.release();
      return tempFilePath;
    } catch (error) {
      Logger.error('[resizeImage] Error resizing image: ' + error);
      return filePath;
    }
  }

  static async doLoadHttpImage(uiContext: UIContext, url: string, redirectCount: number = 0): Promise<string> {
    let context = uiContext.getHostContext()! as common.UIAbilityContext;
    let filesDir = context.filesDir;
    let fileExtension = 'png';
    const urlWithoutParams = url.split('?')[0];
    const lastDotIndex = urlWithoutParams.lastIndexOf('.');
    if (lastDotIndex !== -1) {
      fileExtension = urlWithoutParams.slice(lastDotIndex + 1).toLowerCase();
    }
    const fullFileName: string = filesDir + "/" + new Date().getTime() + "." + fileExtension;

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
        mode: request.agent.Mode.FOREGROUND,
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
            task.off('failed');
            task.off('response');
            task.stop();
            try {
              const result = await DownloadIcon.doLoadHttpImage(uiContext, redirectUrl, redirectCount + 1);
              Logger.info(`[maker icon]:result: ${result} -----count: ${redirectCount}}`);
              resolve(result)
            } catch (error) {
              reject(error);
            }
          }
        });
        task.start();
      }).catch((error: BusinessError) => {
        Logger.info(`[maker icon]: error downloadHttpFile`);
        reject(new Error("downloadFile failed: " + error.message));
      });
    });
  }
}