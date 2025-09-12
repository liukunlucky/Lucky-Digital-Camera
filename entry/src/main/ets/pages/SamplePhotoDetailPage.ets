// 样张详情页面

import {
  SamplePhotoDetail,
  SamplePhoto,
  CATEGORY_NAMES
} from '../model/SampleGalleryModel';
import { SampleGalleryService } from '../service/SampleGalleryService';
import router from '@ohos.router';
import { Camera } from '../model/Camera';
import { CameraUtil } from '../utils/CameraUtils';

@Entry
@Component
struct SamplePhotoDetailPage {
  @State photoDetail: SamplePhotoDetail | null = null;
  @State isLoading: boolean = true;
  @State isLiked: boolean = false;
  @State showExifData: boolean = false;
  // 评论相关状态已移除
  
  private photoId: string = '';
  private sampleService = SampleGalleryService.getInstance();

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.photoId = params['photoId'] as string;
    await this.loadPhotoDetail();
  }

  // 加载样张详情
  private async loadPhotoDetail() {
    try {
      this.isLoading = true;
      this.photoDetail = await this.sampleService.getSamplePhotoDetail(this.photoId);
      console.log('lucky photodetail is ' + JSON.stringify(this.photoDetail))
      if (this.photoDetail) {
        // 增加查看数
        await this.sampleService.incrementViews(this.photoId);
      }
      
      this.isLoading = false;
    } catch (error) {
      console.error('加载样张详情失败:', error);
      this.isLoading = false;
    }
  }

  // 点赞
  private async toggleLike() {
    if (!this.photoDetail) return;
    
    try {
      if (!this.isLiked) {
        await this.sampleService.likeSamplePhoto(this.photoId);
        this.photoDetail.likes++;
        this.isLiked = true;
      }
    } catch (error) {
      console.error('点赞失败:', error);
    }
  }

  // 查看相机详情
  private viewCameraDetail() {
    if (!this.photoDetail?.cameraDataItem) return;
    const camera: Camera = CameraUtil.convertCameraDataItemToCamera(this.photoDetail.cameraDataItem);
    router.pushUrl({
      url: 'pages/CameraDetail',
      params: {
        camera: camera,
        cameraDataItem: this.photoDetail.cameraDataItem
      }
    }).catch((error: Error) => {
      console.error('跳转到相机详情页面失败:', error.message);
    });
  }

  // 查看相关样张
  private viewRelatedPhoto(photo: SamplePhoto) {
    router.pushUrl({
      url: 'pages/SamplePhotoDetailPage',
      params: {
        photoId: photo.id
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar()
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.photoDetail) {
        this.buildErrorView()
      } else {
        Scroll() {
          Column() {
            // 主图片
            this.buildMainImage()
            
            // 基本信息
            this.buildBasicInfo()
            
            // 拍摄参数
            this.buildShootingParams()
            
            // 标签
            this.buildTags()
            
            // 相机信息
            this.buildCameraInfo()
            
            // EXIF数据
            if (this.photoDetail.exifData) {
              this.buildExifData()
            }
            
            // 相关样张
            if (this.photoDetail.relatedPhotos.length > 0) {
              this.buildRelatedPhotos()
            }
            
            // 评论区已移除
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        
        // 底部操作栏
        // this.buildBottomActions()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  // 顶部导航栏
  @Builder
  buildTopBar() {
    Row() {
      Button() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.primary_text_color'))
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back();
      })
      
      Text('样张详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Button() {
        Image($r('app.media.icon_share'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.primary_text_color'))
      }
      .width(40)
      .height(40)
      .visibility(Visibility.Hidden)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        // 分享功能
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.start_window_background'))
  }

  // 加载视图
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color($r('app.color.brand_color'))
      
      Text('加载中...')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // 错误视图
  @Builder
  buildErrorView() {
    Column() {
      Image($r('app.media.icon_error'))
        .width(80)
        .height(80)
        .fillColor($r('app.color.secondary_text_color'))
        .opacity(0.5)
      
      Text('样张不存在')
          .fontSize(16)
          .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 16 })
      
      Button('返回')
        .fontSize(14)
        .fontColor($r('app.color.background_color'))
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .margin({ top: 24 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // 主图片
  @Builder
  buildMainImage() {
    if (this.photoDetail) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.photoDetail.imageUri)
          .width('100%')
          .height(300)
          .objectFit(ImageFit.Cover)

        // 分类标签
        Text(CATEGORY_NAMES[this.photoDetail.category])
          .fontSize(12)
          .fontColor($r('app.color.background_color'))
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius(6)
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4
          })
          .margin(16)
      }
    }
  }

  // 基本信息
  @Builder
  buildBasicInfo() {
    if (this.photoDetail) {
      Column() {
      Text(this.photoDetail.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .width('100%')
      
      if (this.photoDetail.description) {
        Text(this.photoDetail.description)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .lineHeight(20)
          .width('100%')
          .margin({ top: 8 })
      }
      
      Row() {
        if (this.photoDetail.photographer) {
          Row() {
            Image($r('app.media.icon_user'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.secondary_text_color'))
            
            Text(this.photoDetail.photographer)
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ left: 4 })
          }
        }
        
        Blank()
        
        Row() {
          Image($r('app.media.icon_time'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.secondary_text_color'))
          
          Text(new Date(this.photoDetail.uploadTime).toLocaleDateString())
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
      }
      .width('100%')
      .margin({ top: 12 })
      
      Row() {
        Row() {
          Image($r('app.media.icon_like'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.secondary_text_color'))
          
          Text(this.photoDetail.likes.toString())
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
        
        Row() {
          Image($r('app.media.icon_view'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.secondary_text_color'))
          
          Text(this.photoDetail.views.toString())
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
        .margin({ left: 16 })
        
        if (this.photoDetail.location) {
          Row() {
            Image($r('app.media.icon_location'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.secondary_text_color'))
            
            Text(this.photoDetail.location)
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ left: 4 })
          }
          .margin({ left: 16 })
        }
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    }
  }

  // 拍摄参数
  @Builder
  buildShootingParams() {
    if (this.photoDetail) {
      Column() {
      Text('拍摄参数')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ bottom: 12 })

      Grid() {
        if (this.photoDetail.shootingParams.aperture) {
          GridItem() {
            this.buildParamItem('光圈', this.photoDetail.shootingParams.aperture)
          }
        }

        if (this.photoDetail.shootingParams.shutterSpeed) {
          GridItem() {
            this.buildParamItem('快门', this.photoDetail.shootingParams.shutterSpeed)
          }
        }

        if (this.photoDetail.shootingParams.iso) {
          GridItem() {
            this.buildParamItem('ISO', this.photoDetail.shootingParams.iso)
          }
        }

        if (this.photoDetail.shootingParams.focalLength) {
          GridItem() {
            this.buildParamItem('焦距', this.photoDetail.shootingParams.focalLength)
          }
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color'))
    .margin({ top: 8 })
    }
    }


  // 参数项
  @Builder
  buildParamItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 4 })
      
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.input_background_color'))
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    }


  // 标签
  @Builder
  buildTags() {
    if (this.photoDetail && this.photoDetail.tags.length > 0) {
      Column() {
      Text('标签')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ bottom: 12 })
      
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.photoDetail.tags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
            .backgroundColor($r('app.color.tag_background_primary'))
            .borderRadius(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
        })
      }
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color'))
    .margin({ top: 8 })
    }
  }

  // 相机信息
  @Builder
  buildCameraInfo() {
    if (this.photoDetail?.cameraDataItem) {
      Column() {
      Row() {
        Text('相机信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .layoutWeight(1)
        
        Button('查看详情')
          .fontSize(12)
          .fontColor($r('app.color.brand_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.viewCameraDetail();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Row() {
        Image($r('app.media.icon_camera'))
          .width(40)
          .height(40)
          .fillColor($r('app.color.secondary_text_color'))
        
        Column() {
          Text(`${this.photoDetail.cameraDataItem.Brand} ${this.photoDetail.cameraDataItem.Model}`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .width('100%')
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color'))
    .margin({ top: 8 })
    }
  }

  // EXIF数据
  @Builder
  buildExifData() {
    if (this.photoDetail?.exifData) {
      Column() {
        Row() {
          Text('EXIF数据')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .layoutWeight(1)

          Button(this.showExifData ? '收起' : '展开')
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showExifData = !this.showExifData;
            })
        }
        .width('100%')

        if (this.showExifData) {
          Column() {
            // EXIF数据项
            if (this.photoDetail.exifData.dateTime) {
              this.buildExifItem('拍摄时间', this.photoDetail.exifData.dateTime)
            }

            if (this.photoDetail.exifData.software) {
              this.buildExifItem('软件', this.photoDetail.exifData.software)
            }

            if (this.photoDetail.exifData.artist) {
              this.buildExifItem('艺术家', this.photoDetail.exifData.artist)
            }
          }
          .width('100%')
          .margin({ top: 12 })
        }
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.background_color'))
      .margin({ top: 8 })
    }
  }

  // EXIF数据项
  @Builder
  buildExifItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.secondary_text_color'))
        .width(80)
      
      Text(value)
        .fontSize(12)
        .fontColor($r('app.color.primary_text_color'))
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  // 相关样张
  @Builder
  buildRelatedPhotos() {
    if (this.photoDetail && this.photoDetail.relatedPhotos.length > 0) {
      Column() {
        Text('相关样张')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 12 })

        Scroll() {
          Row() {
            ForEach(this.photoDetail.relatedPhotos, (photo: SamplePhoto) => {
              Column() {
                Image(photo.thumbnailUri || photo.imageUri)
                  .width(120)
                  .height(120)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)

                Text(photo.title)
                  .fontSize(12)
                  .fontColor($r('app.color.primary_text_color'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width(120)
                  .margin({ top: 8 })
              }
              .margin({ right: 12 })
              .onClick(() => {
                this.viewRelatedPhoto(photo);
              })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.background_color'))
      .margin({ top: 8 })
    }
  }

  // 评论相关方法已移除


  // 底部操作栏
  @Builder
  buildBottomActions() {
    if (this.photoDetail) {
      Row() {
      Button() {
        Row() {
          Image(this.isLiked ? $r('app.media.icon_like_filled') : $r('app.media.icon_like'))
            .width(20)
            .height(20)
            .fillColor(this.isLiked ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
          
          Text(this.photoDetail.likes.toString())
            .fontSize(14)
            .fontColor(this.isLiked ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.toggleLike();
      })
      
      Blank()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.background_color'))
    .border({ width: { top: 1 }, color: $r('app.color.border_color') })
    }
  }
}