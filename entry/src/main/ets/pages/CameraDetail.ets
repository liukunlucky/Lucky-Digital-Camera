import { Camera } from '../model/Camera';
import { cameraDataService } from '../service/CameraDataService';
import router from '@ohos.router';

@Entry
@Component
struct CameraDetail {
  @State camera: Camera | undefined = undefined;
  private cameraId: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.cameraId) {
      this.cameraId = params.cameraId as number;
    }
    this.camera = cameraDataService.getCameraById(this.cameraId);
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#2C3E50')
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
          .fontColor('#2C3E50')
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor('#ECF0F1')
      .alignItems(VerticalAlign.Center)

      if (this.camera) {
        Scroll() {
          Column() {
            // 相机主图
            Column() {
              Image($r('app.media.foreground'))
                .width(200)
                .height(200)
                .borderRadius(16)
            }
            .width('100%')
            .height(240)
            .backgroundColor('#F8F9FA')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 20 })

            // 基本信息卡片
            Column() {
              Column() {
                Text(`${this.camera.brand} ${this.camera.model}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C3E50')
                  .margin({ bottom: 8 })

                Row() {
                  Text(this.camera.category)
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#3498DB')
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .borderRadius(12)

                  Text(`发布于 ${this.camera.releaseDate}`)
                    .fontSize(14)
                    .fontColor('#7F8C8D')
                    .margin({ left: 16 })
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 价格信息
                Row() {
                  Column() {
                    Text('发布价格')
                      .fontSize(14)
                      .fontColor('#7F8C8D')
                    Text(`$${this.camera.releasePrice}`)
                      .fontSize(24)
                      .fontColor('#27AE60')
                      .fontWeight(FontWeight.Bold)
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Column() {
                    Text('相机类型')
                      .fontSize(14)
                      .fontColor('#7F8C8D')
                    Text(this.camera.category)
                      .fontSize(16)
                      .fontColor('#3498DB')
                      .fontWeight(FontWeight.Bold)
                  }
                  .alignItems(HorizontalAlign.End)

                  Column() {
                    Text('传感器画幅')
                      .fontSize(14)
                      .fontColor('#7F8C8D')
                    Text(this.camera.sensorFormat)
                      .fontSize(16)
                      .fontColor('#E67E22')
                      .fontWeight(FontWeight.Bold)
                  }
                  .alignItems(HorizontalAlign.End)
                  .margin({ left: 24 })
                }
                .width('100%')
                .alignItems(VerticalAlign.Bottom)

                Divider()
                  .margin({ top: 16, bottom: 16 })

                Text(this.camera.description)
                  .fontSize(16)
                  .fontColor('#34495E')
                  .lineHeight(24)
              }
              .width('100%')
              .padding(20)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 16 })
            .padding(2)

            // 技术规格卡片
            Column() {
              Column() {
                Text('技术规格')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C3E50')
                  .margin({ bottom: 16 })

                this.SpecRow('传感器类型', this.camera.specifications.sensorType)
                this.SpecRow('有效像素', `${this.camera.specifications.megapixels} MP`)
                this.SpecRow('ISO范围', this.camera.specifications.isoRange)
                this.SpecRow('快门速度', this.camera.specifications.shutterSpeed)
                this.SpecRow('镜头卡口', this.camera.specifications.lensMount)
                this.SpecRow('视频能力', this.camera.specifications.videoCapability)
                this.SpecRow('重量', `${this.camera.specifications.weight}g`)
                this.SpecRow('尺寸', `${this.camera.specifications.dimensions}mm`)
              }
              .width('100%')
              .padding(20)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 16 })
            .padding(2)
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .backgroundColor('#F8F9FA')
      } else {
        Column() {
          Text('相机信息未找到')
            .fontSize(18)
            .fontColor('#7F8C8D')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F8F9FA')
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
        .fontColor('#7F8C8D')
        .width('40%')

      Text(value)
        .fontSize(16)
        .fontColor('#2C3E50')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 12 })
    .alignItems(VerticalAlign.Center)
  }
}