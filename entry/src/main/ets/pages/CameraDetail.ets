import { Camera, CameraCategory, SensorFormat } from '../model/Camera';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import { cameraDataService } from '../service/CameraDataService';
import { cameraRatingService } from '../service/CameraRatingService';
import { CameraRating, CameraRatingStats, SimilarCamera, UpgradeCamera, PREDEFINED_TAGS } from '../model/CameraRating';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

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
  
  // 评分相关状态
  @State currentRating: CameraRating | undefined = undefined;
  @State ratingStats: CameraRatingStats | undefined = undefined;
  @State showRatingDialog: boolean = false;
  @State userRating: number = 5;
  @State userTags: string[] = [];
  @State userComment: string = '';
  @State selectedTags: Set<string> = new Set();
  
  // 推荐相关状态
  @State similarCameras: SimilarCamera[] = [];
  @State upgradeCameras: UpgradeCamera[] = [];
  @State allCameraData: CameraDataItem[] = [];

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
    
    // 加载评分和推荐数据
    await this.loadRatingData();
    await this.loadRecommendations();
  }
  
  // 加载评分数据
  private async loadRatingData(): Promise<void> {
    if (!this.cameraDataItem && !this.camera) return;
    
    const brand = this.cameraDataItem?.Brand || this.camera?.brand || '';
    const model = this.cameraDataItem?.Model || this.camera?.model || '';
    
    this.currentRating = cameraRatingService.getRating(brand, model);
    this.ratingStats = cameraRatingService.getRatingStats(brand, model);
    
    // 如果有当前评分，初始化编辑状态
    if (this.currentRating) {
      this.userRating = this.currentRating.rating;
      this.userTags = [...this.currentRating.tags];
      this.userComment = this.currentRating.comment || '';
      this.selectedTags = new Set(this.currentRating.tags);
    }
  }
  
  // 加载推荐数据
  private async loadRecommendations(): Promise<void> {
    if (!this.cameraDataItem) return;
    
    try {
      // 获取所有相机数据
      this.allCameraData = await cameraDataJsonService.getAllCameras();
      
      // 获取相似产品推荐
      this.similarCameras = cameraRatingService.getSimilarCameras(this.cameraDataItem, this.allCameraData);
      
      // 获取升级路径推荐
      this.upgradeCameras = cameraRatingService.getUpgradeCameras(this.cameraDataItem, this.allCameraData);
    } catch (error) {
      console.error('加载推荐数据失败:', error);
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
            
            // 用户评分和标签卡片
            this.RatingAndTagsCard()
            
            // // 样张库入口卡片
            // this.SampleGalleryCard()
            
            // 相似产品推荐卡片
            if (this.similarCameras.length > 0) {
              this.SimilarCamerasCard()
            }
            
            // 升级路径推荐卡片
            if (this.upgradeCameras.length > 0) {
              this.UpgradeCamerasCard()
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
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
    .bindSheet($$this.showRatingDialog, this.RatingDialog(), {
      height: 600,
      showClose: true,
      dragBar: true,
      onDisappear: (): void => {
        this.showRatingDialog = false;
      }
    })
  }



  @Builder
  SampleGalleryCard() {
    Column() {
      Column() {
        Row() {
          Text('样张库')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
          
          Blank()
          
          Text('查看更多 >')
            .fontSize(14)
            .fontColor($r('app.color.brand_color'))
            .onClick(() => {
              this.navigateToSampleGallery();
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        
        Text('查看该相机的实拍样张，了解真实拍摄效果')
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ bottom: 16 })
        
        Button('浏览样张库')
          .width('100%')
          .height(44)
          .backgroundColor($r('app.color.brand_color'))
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            this.navigateToSampleGallery();
          })
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
  
  // 导航到样张库页面
  private navigateToSampleGallery(): void {
    if (!this.cameraDataItem && !this.camera) return;
    
    const brand = this.cameraDataItem?.Brand || this.camera?.brand || '';
    const model = this.cameraDataItem?.Model || this.camera?.model || '';
    const cameraId = `${brand}_${model}`.replace(/\s+/g, '_');
    
    router.pushUrl({
      url: 'pages/CameraSampleGalleryPage',
      params: {
        cameraId: cameraId,
        cameraBrand: brand,
        cameraModel: model
      }
    }).catch((error: Error) => {
      console.error('导航到样张库失败:', error);
      promptAction.showToast({
        message: '页面跳转失败',
        duration: 2000
      });
    });
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
  
  // 评分和标签卡片
  @Builder
  RatingAndTagsCard() {
    Column() {
      Column() {
        Row() {
          Text('用户评价')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
          
          // Blank()
          //
          // Button('评价')
          //   .fontSize(14)
          //   .backgroundColor($r('app.color.brand_color'))
          //   .fontColor('#FFFFFF')
          //   .borderRadius(16)
          //   .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          //   .onClick((): void => {
          //     this.showRatingDialog = true;
          //   })
        }
        .width('100%')
        .margin({ bottom: 16 })
        
        // 当前评分显示
        if (this.currentRating) {
          Column() {
            Row() {
              Text('我的评分：')
                .fontSize(16)
                .fontColor($r('app.color.secondary_text_color'))
              
              Row() {
                ForEach([1, 2, 3, 4, 5], (star: number) => {
                  Image($r('app.media.ic_star'))
                    .width(20)
                    .height(20)
                    .fillColor(star <= this.currentRating!.rating ? '#FFD700' : '#E0E0E0')
                    .margin({ right: 4 })
                }, (star: number) => star.toString())
              }
            }
            .width('100%')
            .margin({ bottom: 8 })
            
            // 标签显示
            if (this.currentRating.tags.length > 0) {
              Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
                ForEach(this.currentRating.tags, (tag: string) => {
                  Text(tag)
                    .fontSize(12)
                    .fontColor($r('app.color.brand_color'))
                    .backgroundColor('#E3F2FD')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(12)
                    .margin({ right: 8, bottom: 8 })
                })
              }
              .width('100%')
              .margin({ bottom: 8 })
            }
            
            // 评论显示
            if (this.currentRating.comment) {
              Text(this.currentRating.comment)
                .fontSize(14)
                .fontColor($r('app.color.primary_text_color'))
                .backgroundColor('#F5F5F5')
                .padding(12)
                .borderRadius(8)
                .width('100%')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        } else {
          Text('暂无评价')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(20)
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
  
  // 相似产品推荐卡片
  @Builder
  SimilarCamerasCard() {
    Column() {
      Column() {
        Text('相似产品推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 16 })
        
        Scroll() {
          Row() {
            ForEach(this.similarCameras, (camera: SimilarCamera) => {
              this.SimilarCameraItem(camera)
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
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
  
  // 升级路径推荐卡片
  @Builder
  UpgradeCamerasCard() {
    Column() {
      Column() {
        Text('升级路径推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 16 })
        
        ForEach(this.upgradeCameras, (camera: UpgradeCamera) => {
          this.UpgradeCameraItem(camera)
        })
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
  
  // 相似产品项
  @Builder
  SimilarCameraItem(camera: SimilarCamera) {
    Column() {
      // 相机图片
      if (camera.imageUrl) {
        Image($rawfile(cameraDataJsonService.getCameraImagePath({ image_file: camera.imageUrl } as CameraDataItem)))
          .width(120)
          .height(90)
          .borderRadius(8)
          .objectFit(ImageFit.Contain)
          .alt($r('app.media.foreground'))
      } else {
        Image($r('app.media.foreground'))
          .width(120)
          .height(90)
          .borderRadius(8)
      }
      
      // 相机信息
      Text(`${camera.brand} ${camera.model}`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .width(120)
        .margin({ top: 8 })
      
      // 相似度
      Text(`相似度: ${Math.round(camera.similarityScore * 100)}%`)
        .fontSize(12)
        .fontColor($r('app.color.brand_color'))
        .margin({ top: 4 })
      
      // 价格范围
      if (camera.priceRange) {
        Text(camera.priceRange)
          .fontSize(12)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ top: 2 })
      }
    }
    .width(140)
    .padding(10)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .margin({ right: 12 })
    .onClick((): void => {
      this.navigateToSimilarCamera(camera);
    })
  }
  
  // 升级产品项
  @Builder
  UpgradeCameraItem(camera: UpgradeCamera) {
    Row() {
      // 相机图片
      if (camera.imageUrl) {
        Image($rawfile(cameraDataJsonService.getCameraImagePath({ image_file: camera.imageUrl } as CameraDataItem)))
          .width(80)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Contain)
          .alt($r('app.media.foreground'))
      } else {
        Image($r('app.media.foreground'))
          .width(80)
          .height(60)
          .borderRadius(8)
      }
      
      // 相机信息
      Column() {
        Text(`${camera.brand} ${camera.model}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(`推荐度: ${Math.round(camera.upgradeScore * 100)}%`)
          .fontSize(14)
          .fontColor($r('app.color.brand_color'))
          .margin({ top: 4 })
        
        // 升级原因
        if (camera.upgradeReasons.length > 0) {
          Text(camera.upgradeReasons.slice(0, 2).join(', '))
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      // 价格和升级类型
      Column() {
        if (camera.priceRange) {
          Text(camera.priceRange)
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
        }
        
        Text(this.getUpgradeTypeText(camera.upgradeType))
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_color'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick((): void => {
      this.navigateToUpgradeCamera(camera);
    })
  }
  
  // 获取升级类型文本
  private getUpgradeTypeText(type: string): string {
    switch (type) {
      case 'entry_to_mid':
        return '进阶升级';
      case 'mid_to_pro':
        return '专业升级';
      case 'brand_switch':
        return '品牌切换';
      case 'format_upgrade':
        return '画幅升级';
      default:
        return '升级';
    }
  }
  
  // 导航到相似相机
  private navigateToSimilarCamera(camera: SimilarCamera): void {
    const targetCamera = this.allCameraData.find(c => 
      c.Brand === camera.brand && c.Model === camera.model
    );
    
    if (targetCamera) {
      this.navigateToCameraDetail(targetCamera);
    }
  }
  
  // 导航到升级相机
  private navigateToUpgradeCamera(camera: UpgradeCamera): void {
    const targetCamera = this.allCameraData.find(c => 
      c.Brand === camera.brand && c.Model === camera.model
    );
    
    if (targetCamera) {
      this.navigateToCameraDetail(targetCamera);
    }
  }
  
  // 导航到相机详情
  private navigateToCameraDetail(cameraDataItem: CameraDataItem): void {
    const camera = this.convertCameraDataItemToCamera(cameraDataItem);
    
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
  
  // 转换CameraDataItem为Camera对象
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
        sensorType: cameraDataItem.SensorType || '',
        megapixels: parseFloat(cameraDataItem.Megapixels?.replace('MP', '') || '0'),
        isoRange: cameraDataItem.ISO || '100-51200',
        shutterSpeed: '1/4000s',
        lensMount: '',
        videoCapability: '4K/30p',
        weight: parseFloat(cameraDataItem.Weight?.replace('g', '') || '0'),
        dimensions: cameraDataItem.Dimensions || '130x100x70mm'
      },
      category: CameraCategory.DSLR, // 默认值
      sensorFormat: SensorFormat.FULL_FRAME // 默认值
    };
  }
  
  // 生成数字ID
   private generateNumericId(brand: string, model: string): number {
     let hash = 0;
     const str = `${brand}_${model}`;
     for (let i = 0; i < str.length; i++) {
       const char = str.charCodeAt(i);
       hash = ((hash << 5) - hash) + char;
       hash = hash & hash; // 转换为32位整数
     }
     return Math.abs(hash);
   }
   
   // 评分对话框
   @Builder
   RatingDialog() {
     Column() {
       // 标题
       Text('为这款相机评分')
         .fontSize(20)
         .fontWeight(FontWeight.Bold)
         .fontColor($r('app.color.primary_text_color'))
         .margin({ bottom: 20 })
       
       // 相机名称
       Text(`${this.cameraDataItem?.Brand || this.camera?.brand} ${this.cameraDataItem?.Model || this.camera?.model}`)
         .fontSize(16)
         .fontColor($r('app.color.secondary_text_color'))
         .margin({ bottom: 20 })
       
       // 星级评分
       Column() {
         Text('评分')
           .fontSize(16)
           .fontWeight(FontWeight.Medium)
           .fontColor($r('app.color.primary_text_color'))
           .alignSelf(ItemAlign.Start)
           .margin({ bottom: 12 })
         
         Row() {
           ForEach([1, 2, 3, 4, 5], (star: number) => {
             Image($r('app.media.ic_star'))
               .width(32)
               .height(32)
               .fillColor(star <= this.userRating ? '#FFD700' : '#E0E0E0')
               .margin({ right: 8 })
               .onClick((): void => {
                 this.userRating = star;
               })
           }, (star: number) => star.toString())
         }
         .justifyContent(FlexAlign.Center)
         .width('100%')
       }
       .width('100%')
       .margin({ bottom: 20 })
       
       // 标签选择
       Column() {
         Text('标签 (可多选)')
           .fontSize(16)
           .fontWeight(FontWeight.Medium)
           .fontColor($r('app.color.primary_text_color'))
           .alignSelf(ItemAlign.Start)
           .margin({ bottom: 12 })
         
         Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
           ForEach(PREDEFINED_TAGS, (tag: string) => {
             Text(tag)
               .fontSize(14)
               .fontColor(this.selectedTags.has(tag) ? '#FFFFFF' : $r('app.color.brand_color'))
               .backgroundColor(this.selectedTags.has(tag) ? $r('app.color.brand_color') : '#E3F2FD')
               .padding({ left: 12, right: 12, top: 6, bottom: 6 })
               .borderRadius(16)
               .margin({ right: 8, bottom: 8 })
               .onClick((): void => {
                 if (this.selectedTags.has(tag)) {
                   this.selectedTags.delete(tag);
                 } else {
                   this.selectedTags.add(tag);
                 }
                 this.userTags = Array.from(this.selectedTags);
               })
           })
         }
         .width('100%')
       }
       .width('100%')
       .margin({ bottom: 20 })
       
       // 评论输入
       Column() {
         Text('评论 (可选)')
           .fontSize(16)
           .fontWeight(FontWeight.Medium)
           .fontColor($r('app.color.primary_text_color'))
           .alignSelf(ItemAlign.Start)
           .margin({ bottom: 12 })
         
         TextArea({ placeholder: '分享您的使用体验...' })
           .width('100%')
           .height(80)
           .backgroundColor('#F5F5F5')
           .borderRadius(8)
           .fontSize(14)
           .onChange((value: string): void => {
             this.userComment = value;
           })
       }
       .width('100%')
       .margin({ bottom: 30 })
       
       // 操作按钮
       Row() {
         Button('取消')
           .fontSize(16)
           .backgroundColor('#F5F5F5')
           .fontColor($r('app.color.primary_text_color'))
           .borderRadius(8)
           .layoutWeight(1)
           .onClick((): void => {
             this.showRatingDialog = false;
           })
         
         Button('保存')
           .fontSize(16)
           .backgroundColor($r('app.color.brand_color'))
           .fontColor('#FFFFFF')
           .borderRadius(8)
           .layoutWeight(1)
           .margin({ left: 12 })
           .onClick((): void => {
             this.saveRating();
           })
       }
       .width('100%')
     }
     .width('100%')
     .padding(20)
   }
   
   // 保存评分
   private async saveRating(): Promise<void> {
     if (!this.cameraDataItem && !this.camera) return;
     
     const brand = this.cameraDataItem?.Brand || this.camera?.brand || '';
     const model = this.cameraDataItem?.Model || this.camera?.model || '';
     
     try {
       await cameraRatingService.addOrUpdateRating(
         brand,
         model,
         this.userRating,
         this.userTags,
         this.userComment
       );
       
       // 重新加载评分数据
       await this.loadRatingData();
       
       this.showRatingDialog = false;
       
       promptAction.showToast({
         message: '评分保存成功',
         duration: 2000
       });
     } catch (error) {
       console.error('保存评分失败:', error);
       promptAction.showToast({
         message: '保存失败，请重试',
         duration: 2000
       });
     }
   }
 }