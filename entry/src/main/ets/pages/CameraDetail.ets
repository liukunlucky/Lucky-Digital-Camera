import { Camera } from '../model/Camera';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import { cameraDataService } from '../service/CameraDataService';
import router from '@ohos.router';

@Entry
@Component
struct CameraDetail {
  @State camera: Camera | undefined = undefined;
  @State cameraDataItem: CameraDataItem | undefined = undefined;
  @State sensorType: string = '';
  @State sensorSize: string = '';
  @State sensorResolution: string = '';
  @State maxImageResolution: string = '';
  @State maxAperture: string = '';
  @State minShutterSpeed: string = '';
  @State maxShutterSpeed: string = '';
  @State focalLength: string = '';
  @State screenSize: string = '';
  @State storageTypes: string = '';
  @State digitalZoom: string = '';
  @State opticalZoom: string = '';
  private cameraId: number = 0;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.camera) {
      // 直接使用传递过来的camera对象
      this.camera = params.camera as Camera;
      // 如果有cameraDataItem，优先使用
      if (params.cameraDataItem) {
        this.cameraDataItem = params.cameraDataItem as CameraDataItem;
        // 预处理所有需要的属性
        // 直接访问属性
            this.sensorType = this.cameraDataItem.SensorType || '';
            this.sensorSize = this.cameraDataItem.SensorSize || '';
            this.sensorResolution = this.cameraDataItem.SensorResolution || '';
            this.maxImageResolution = this.cameraDataItem.MaxImageResolution || '';
            this.maxAperture = this.cameraDataItem.MaxAperture || '';
            this.minShutterSpeed = this.cameraDataItem.MinShutterSpeed || '';
            this.maxShutterSpeed = this.cameraDataItem.MaxShutterSpeed || '';
            this.focalLength = this.cameraDataItem.FocalLength35mmEquiv || '';
            this.screenSize = this.cameraDataItem.ScreenSize || '';
            this.storageTypes = this.cameraDataItem.StorageTypes || '';
            this.digitalZoom = this.cameraDataItem.DigitalZoom || '';
            this.opticalZoom = this.cameraDataItem.OpticalZoom || '';
      }
    } else if (params && params.cameraId) {
      // 兼容旧的cameraId方式
      this.cameraId = params.cameraId as number;
      this.camera = cameraDataService.getCameraById(this.cameraId);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor($r('app.color.primary_text_color'))
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })
        .margin({ left: 8 })

        Text('相机详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor($r('app.color.surface_color'))
      .alignItems(VerticalAlign.Center)

      if (this.cameraDataItem || this.camera) {
        Scroll() {
          Column() {
            // 相机主图
            Column() {
              if (this.cameraDataItem?.image_file) {
                // 显示真实的相机图片
                Image($rawfile(cameraDataJsonService.getCameraImagePath(this.cameraDataItem)))
                  .width(250)
                  .height(200)
                  .borderRadius(16)
                  .objectFit(ImageFit.Contain)
                  .alt($r('app.media.foreground'))
              } else if (this.camera?.imageUrl && this.camera.imageUrl.startsWith('images/')) {
                // 显示真实的相机图片
                Image($rawfile(this.camera.imageUrl))
                  .width(250)
                  .height(200)
                  .borderRadius(16)
                  .objectFit(ImageFit.Contain)
                  .alt($r('app.media.foreground'))
              } else {
                // 显示默认图片
                Image($r('app.media.foreground'))
                  .width(250)
                  .height(200)
                  .borderRadius(16)
              }
            }
            .width('100%')
            .height(260)
            .backgroundColor($r('app.color.background_color'))
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 20 })

            // 基本信息卡片
            Column() {
              Column() {
                Text(`${this.cameraDataItem?.Brand || this.camera?.brand} ${this.cameraDataItem?.Model || this.camera?.model}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .margin({ bottom: 8 })

                Row() {
                  Text('数码相机')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor($r('app.color.brand_color'))
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .borderRadius(12)

                  Text(`发布于 ${this.cameraDataItem?.Year || this.camera?.releaseDate}`)
                    .fontSize(14)
                    .fontColor($r('app.color.secondary_text_color'))
                    .margin({ left: 16 })
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 核心参数信息
                Row() {
                  Column() {
                    Text('像素')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                    Text(this.cameraDataItem?.Megapixels || '未知')
                      .fontSize(16)
                      .fontColor('#27AE60')
                      .fontWeight(FontWeight.Bold)
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Column() {
                    Text('传感器类型')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                    Text(this.sensorType || '未知')
                      .fontSize(16)
                      .fontColor($r('app.color.brand_color'))
                      .fontWeight(FontWeight.Bold)
                  }
                  .alignItems(HorizontalAlign.End)

                  Column() {
                    Text('重量')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                    Text(this.cameraDataItem?.Weight || '未知')
                      .fontSize(16)
                      .fontColor('#E67E22')
                      .fontWeight(FontWeight.Bold)
                  }
                  .alignItems(HorizontalAlign.End)
                  .margin({ left: 24 })
                }
                .width('100%')
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .padding(20)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor($r('app.color.surface_color'))
            .borderRadius(12)
            .margin({ bottom: 16 })
            .padding(2)

            // 技术规格卡片
            Column() {
              Column() {
                Text('技术规格')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .margin({ bottom: 16 })

                if (this.cameraDataItem) {
                  this.SpecRow('品牌', this.cameraDataItem.Brand)
                  this.SpecRow('型号', this.cameraDataItem.Model)
                  this.SpecRow('发布年份', this.cameraDataItem.Year)
                  if (this.cameraDataItem.Megapixels) {
                    this.SpecRow('像素', this.cameraDataItem.Megapixels)
                  }
                  if (this.sensorType) {
                    this.SpecRow('传感器类型', this.sensorType)
                  }
                  if (this.sensorSize) {
                    this.SpecRow('传感器尺寸', this.sensorSize)
                  }
                  if (this.sensorResolution) {
                    this.SpecRow('传感器分辨率', this.sensorResolution)
                  }
                  if (this.maxImageResolution) {
                    this.SpecRow('最大图像分辨率', this.maxImageResolution)
                  }
                  if (this.maxAperture) {
                    this.SpecRow('最大光圈', this.maxAperture)
                  }
                  if (this.minShutterSpeed) {
                    this.SpecRow('最小快门速度', this.minShutterSpeed)
                  }
                  if (this.maxShutterSpeed) {
                    this.SpecRow('最大快门速度', this.maxShutterSpeed)
                  }
                  if (this.cameraDataItem.ISO) {
                    this.SpecRow('ISO范围', this.cameraDataItem.ISO)
                  }
                  if (this.focalLength) {
                    this.SpecRow('等效焦距', this.focalLength)
                  }
                  if (this.screenSize) {
                    this.SpecRow('屏幕尺寸', this.screenSize)
                  }
                  if (this.cameraDataItem.Viewfinder) {
                    this.SpecRow('取景器', this.cameraDataItem.Viewfinder)
                  }
                  if (this.storageTypes) {
                    this.SpecRow('存储类型', this.storageTypes)
                  }
                  if (this.cameraDataItem.Battery) {
                    this.SpecRow('电池', this.cameraDataItem.Battery)
                  }
                  if (this.cameraDataItem.Weight) {
                    this.SpecRow('重量', this.cameraDataItem.Weight)
                  }
                  if (this.cameraDataItem.Dimensions) {
                    this.SpecRow('尺寸', this.cameraDataItem.Dimensions)
                  }
                  if (this.cameraDataItem.USB) {
                    this.SpecRow('USB接口', this.cameraDataItem.USB)
                  }
                  if (this.cameraDataItem.Metering) {
                    this.SpecRow('测光方式', this.cameraDataItem.Metering)
                  }
                  if (this.digitalZoom) {
                    this.SpecRow('数字变焦', this.digitalZoom)
                  }
                  if (this.opticalZoom) {
                    this.SpecRow('光学变焦', this.opticalZoom)
                  }
                } else if (this.camera) {
                  this.SpecRow('传感器类型', this.camera.specifications.sensorType)
                  this.SpecRow('有效像素', `${this.camera.specifications.megapixels} MP`)
                  this.SpecRow('ISO范围', this.camera.specifications.isoRange)
                  this.SpecRow('快门速度', this.camera.specifications.shutterSpeed)
                  this.SpecRow('镜头卡口', this.camera.specifications.lensMount)
                  this.SpecRow('重量', `${this.camera.specifications.weight}g`)
                  this.SpecRow('尺寸', `${this.camera.specifications.dimensions}mm`)
                }
              }
              .width('100%')
              .padding(20)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor($r('app.color.surface_color'))
            .borderRadius(12)
            .margin({ bottom: 16 })
            .padding(2)
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.background_color'))
      } else {
        Column() {
          Text('相机信息未找到')
            .fontSize(18)
            .fontColor($r('app.color.secondary_text_color'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color'))
      }
    }
    .width('100%')
    .height('100%')
  }



  @Builder
  SpecRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor($r('app.color.secondary_text_color'))
        .width('40%')

      Text(value)
        .fontSize(16)
        .fontColor($r('app.color.primary_text_color'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 12 })
    .alignItems(VerticalAlign.Center)
  }
}