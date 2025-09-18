import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import { favoriteService } from '../service/FavoriteService';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { Camera, CameraCategory, SensorFormat } from '../model/Camera';

@Entry
@Component
struct FavoritePage {
  @State favoriteList: CameraDataItem[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear() {
    await this.loadFavorites();
    this.isLoading = false;
  }

  // 加载收藏列表
  private async loadFavorites() {
    try {
      this.favoriteList = favoriteService.getFavorites();
    } catch (error) {
      console.error('加载收藏列表失败:', error);
    }
  }

  // 取消收藏
  private async removeFavorite(camera: CameraDataItem) {
    try {
      const success = await favoriteService.removeFavorite(camera);
      if (success) {
        this.favoriteList = favoriteService.getFavorites();
        promptAction.showToast({
          message: '已取消收藏',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '操作失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('取消收藏失败:', error);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }
  }

  // 跳转到相机详情页面
  private navigateToCameraDetail(cameraDataItem: CameraDataItem) {
    // 将CameraDataItem转换为Camera对象（保持兼容性）
    const camera: Camera = this.convertCameraDataItemToCamera(cameraDataItem);
    
    // 跳转到详情页面，同时传递camera对象和原始cameraDataItem
    router.pushUrl({
      url: 'pages/CameraDetail',
      params: {
        camera: camera,
        cameraDataItem: cameraDataItem
      }
    }).catch((error: Error) => {
      console.error('跳转到相机详情页面失败:', error.message);
    });
  }

  // 将CameraDataItem转换为Camera对象
  private convertCameraDataItemToCamera(cameraDataItem: CameraDataItem): Camera {
    return {
      id: this.generateNumericId(cameraDataItem.Brand, cameraDataItem.Model),
      brand: cameraDataItem.Brand,
      model: cameraDataItem.Model,
      releaseDate: cameraDataItem.Year || '2023',
      releasePrice: 0,
      imageUrl: cameraDataItem.image_file || '',
      description: `${cameraDataItem.Brand} ${cameraDataItem.Model} 是一款优秀的相机产品。`,
      specifications: {
        sensorType: '',
        megapixels: parseFloat(cameraDataItem.Megapixels?.replace('MP', '') || '0'),
        isoRange: cameraDataItem.ISO || '100-51200',
        shutterSpeed: '1/4000s',
        lensMount: '',
        videoCapability: '4K/30p',
        weight: parseFloat(cameraDataItem.Weight?.replace('g', '') || '0'),
        dimensions: cameraDataItem.Dimensions || '130x100x70mm'
      },
      category: this.mapCameraType(cameraDataItem.SensorType),
      sensorFormat: this.mapSensorFormat(cameraDataItem.SensorType)
    };
  }

  // 生成数字ID
  private generateNumericId(brand: string, model: string): number {
    const str = brand + model;
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // 转换为32位整数
    }
    return Math.abs(hash);
  }

  // 映射相机类型
  private mapCameraType(type: string | null | undefined): CameraCategory {
    if (!type) return CameraCategory.MIRRORLESS;
    switch (type.toLowerCase()) {
      case 'mirrorless': return CameraCategory.MIRRORLESS;
      case 'dslr': return CameraCategory.DSLR;
      case 'compact': return CameraCategory.COMPACT;
      case 'instant': return CameraCategory.INSTANT;
      case 'film': return CameraCategory.FILM;
      case 'medium format': return CameraCategory.MEDIUM_FORMAT;
      case 'large format': return CameraCategory.LARGE_FORMAT;
      default: return CameraCategory.MIRRORLESS;
    }
  }

  // 映射传感器画幅
  private mapSensorFormat(format: string | null | undefined): SensorFormat {
    if (!format) return SensorFormat.FULL_FRAME;
    switch (format.toLowerCase()) {
      case 'full frame': return SensorFormat.FULL_FRAME;
      case 'aps-c': return SensorFormat.APS_C;
      case 'aps-h': return SensorFormat.APS_H;
      case 'micro four thirds':
      case 'm43': return SensorFormat.MICRO_FOUR_THIRDS;
      case 'medium format': return SensorFormat.MEDIUM_FORMAT;
      case 'large format': return SensorFormat.LARGE_FORMAT;
      case '1 inch': return SensorFormat.ONE_INCH;
      case 'four thirds': return SensorFormat.FOUR_THIRDS;
      default: return SensorFormat.FULL_FRAME;
    }
  }

  build() {
    Column() {
      // 顶部标题栏
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

        Text('我的收藏')
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
      .padding({ left: 16, right: 16 })
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color($r('app.color.brand_color'))
            .margin({ bottom: 16 })
          
          Text('加载中...')
            .fontSize(16)
            .fontColor($r('app.color.secondary_text_color'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color'))
      } else if (this.favoriteList.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_empty'))
            .width(173)
            .height(128)
            .margin({ bottom: 16 })

          Text('还没有收藏任何相机')
            .fontSize(18)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ bottom: 8 })

          Text('去首页发现更多精彩相机吧')
            .fontSize(14)
            .fontColor($r('app.color.tertiary_text_color'))
            .margin({ bottom: 24 })

          Button('去首页看看')
            .width(120)
            .height(40)
            .fontSize(14)
            .backgroundColor($r('app.color.brand_color'))
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              // 切换到首页tab (index: 0)
              AppStorage.setOrCreate('switchToTab', 0);
              router.back();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color'))
      } else {
        // 收藏列表
        Scroll() {
          Column() {
            Text(`共收藏了 ${this.favoriteList.length} 台相机`)
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ bottom: 16 })
              .alignSelf(ItemAlign.Start)

            ForEach(this.favoriteList, (camera: CameraDataItem, index: number) => {
              Column() {
                this.FavoriteCameraCard(camera)
              }
              .margin({ bottom: 12 })
            }, (camera: CameraDataItem) => camera.Brand + camera.Model)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor($r('app.color.background_color'))
        .align(Alignment.TopStart)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FavoriteCameraCard(camera: CameraDataItem) {
    Row() {
      // 相机图片
      Image($rawfile(cameraDataJsonService.getCameraImagePath(camera)))
        .width(80)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .margin({ right: 12 })
        .alt($r('app.media.foreground'))

      // 相机信息
      Column({ space: 4 }) {
        Text(camera.Model)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(camera.Brand)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))

        Row({ space: 8 }) {
          if (camera.Year) {
            Text(camera.Year + '年')
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
          }
          if (camera.Megapixels) {
            Text(camera.Megapixels)
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 操作按钮
      Column({ space: 8 }) {
        // 取消收藏按钮
        Button() {
          Image($r('app.media.icon_like'))
            .width(20)
            .height(20)
            .fillColor('#FF6B6B')
        }
        .width(36)
        .height(36)
        .backgroundColor('#FFE5E5')
        .borderRadius(18)
        .onClick(() => {
          this.removeFavorite(camera);
        })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: $r('app.color.shadow_color'),
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.navigateToCameraDetail(camera);
    })
  }
}