// 相机样张库页面 - 展示特定相机的所有样张

import {
  SamplePhoto,
  SampleFilter,
  PhotoCategory,
  SortType,
  CATEGORY_NAMES,
  CameraSampleStats
} from '../model/SampleGalleryModel';
import { SampleGalleryService } from '../service/SampleGalleryService';
import { CameraDataService } from '../service/CameraDataService';
import { Camera, CameraCategory, CameraSpecs, SensorFormat } from '../model/Camera';
import router from '@ohos.router';

// 排序选项接口
interface SortOption {
  type: SortType;
  name: string;
}

@Entry
@Component
struct CameraSampleGalleryPage {
  @State cameraInfo: Camera | null = null;
  @State samplePhotos: SamplePhoto[] = [];
  @State filteredPhotos: SamplePhoto[] = [];
  @State sampleStats: CameraSampleStats | null = null;
  @State isLoading: boolean = true;
  @State selectedCategory: PhotoCategory | undefined = undefined;
  @State sortType: SortType = SortType.UPLOAD_TIME_DESC;
  @State showFilterPanel: boolean = false;
  @State gridColumns: number = 2;
  @State showStats: boolean = false;
  
  private cameraId: string = '';
  private cameraBrand: string = '';
  private cameraModel: string = '';
  private sampleService = SampleGalleryService.getInstance();
  private cameraService = new CameraDataService();

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.cameraId = params['cameraId'] as string;
    await this.loadCameraInfo();
    await this.loadCameraSamples();
  }

  // 加载相机信息
  private async loadCameraInfo() {
    try {
      // 从路由参数获取相机信息
      const params = router.getParams() as Record<string, Object>;
      this.cameraBrand = params['cameraBrand'] as string || '';
      this.cameraModel = params['cameraModel'] as string || '';
      
      // 查找相机信息
      const cameras = this.cameraService.getAllCameras();
      const foundCamera = cameras.find(camera => 
        camera.brand === this.cameraBrand && camera.model === this.cameraModel
      );
      
      if (foundCamera) {
        this.cameraInfo = foundCamera;
      } else {
        // 创建默认相机信息
         const defaultSpecs: CameraSpecs = {
           sensorType: '',
           megapixels: 0,
           isoRange: '',
           shutterSpeed: '',
           lensMount: '',
           weight: 0,
           dimensions: '',
           videoCapability: ''
         };
         
         this.cameraInfo = {
           id: 1,
           brand: this.cameraBrand,
           model: this.cameraModel,
           category: CameraCategory.DSLR,
           releasePrice: 0,
           releaseDate: '',
           specifications: defaultSpecs,
           imageUrl: '',
           description: '',
           sensorFormat: SensorFormat.FULL_FRAME
         };
      }
    } catch (error) {
      console.error('加载相机信息失败:', error);
    }
  }

  // 获取排序选项
  private getSortOptions(): SortOption[] {
    return [
      { type: SortType.UPLOAD_TIME_DESC, name: '最新上传' },
      { type: SortType.LIKES_DESC, name: '最多点赞' },
      { type: SortType.VIEWS_DESC, name: '最多查看' }
    ];
  }

  // 加载相机样张
  private async loadCameraSamples() {
    try {
      this.isLoading = true;
      
      const filter: SampleFilter = {
        cameraId: this.cameraId,
        sortBy: this.sortType
      };
      
      this.samplePhotos = await this.sampleService.getSamplePhotos(filter);
      this.filteredPhotos = [...this.samplePhotos];
      
      // 获取相机样张统计
      this.sampleStats = await this.sampleService.getCameraSampleStats(this.cameraId);
      
      this.isLoading = false;
    } catch (error) {
      console.error('加载相机样张失败:', error);
      this.isLoading = false;
    }
  }

  // 应用筛选
  private async applyFilter() {
    const filter: SampleFilter = {
      cameraId: this.cameraId,
      category: this.selectedCategory,
      sortBy: this.sortType
    };
    
    this.filteredPhotos = await this.sampleService.getSamplePhotos(filter);
    this.showFilterPanel = false;
  }

  // 重置筛选
  private resetFilter() {
    this.selectedCategory = undefined;
    this.sortType = SortType.UPLOAD_TIME_DESC;
    this.filteredPhotos = [...this.samplePhotos];
    this.showFilterPanel = false;
  }

  // 查看样张详情
  private viewPhotoDetail(photo: SamplePhoto) {
    router.pushUrl({
      url: 'pages/SamplePhotoDetailPage',
      params: {
        photoId: photo.id
      }
    });
  }

  // 上传新样张
  private uploadNewSample() {
    router.pushUrl({
      url: 'pages/UploadSamplePage',
      params: {
        preSelectedCameraId: this.cameraId
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar()
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        Column() {
          // 相机信息卡片
          this.buildCameraInfoCard()
          
          // 统计信息
          if (this.showStats && this.sampleStats) {
            this.buildStatsCard()
          }
          
          // 筛选和排序栏
          this.buildFilterBar()
          
          // 样张网格
          if (this.filteredPhotos.length > 0) {
            this.buildPhotoGrid()
          } else {
            this.buildEmptyView()
          }
        }
      }
      
      // 筛选面板
      if (this.showFilterPanel) {
        this.buildFilterPanel()
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
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back();
      })
      
      Text(this.cameraInfo ? `${this.cameraInfo.brand} ${this.cameraInfo.model}` : '相机样张库')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Button() {
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.primary_text_color'))
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.uploadNewSample();
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.background_color'))
    .border({ width: { bottom: 1 }, color: $r('app.color.border_color') })
  }

  // 相机信息卡片
  @Builder
  buildCameraInfoCard() {
    if (this.cameraInfo) {
      Column() {
        Row() {
          Image(this.cameraInfo.imageUrl)
            .width(80)
            .height(60)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
          
          Column() {
            Text(`${this.cameraInfo.brand} ${this.cameraInfo.model}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.primary_text_color'))
              .width('100%')
            
            Text(`${this.samplePhotos.length} 张样张`)
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .width('100%')
              .margin({ top: 4 })
            
            if (this.sampleStats) {
              Text(`平均 ${this.sampleStats.avgLikes} 赞 · ${this.sampleStats.avgViews} 次查看`)
                .fontSize(12)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)
          
          Button(this.showStats ? '收起' : '统计')
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showStats = !this.showStats;
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.background_color'))
      .borderRadius(12)
      .margin({ top: 8, left: 16, right: 16 })
      .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    }
  }

  // 统计信息卡片
  @Builder
  buildStatsCard() {
    if (this.sampleStats) {
      Column() {
        Text('样张统计')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 12 })
        
        Row() {
          Column() {
            Text(this.sampleStats.photoCount.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_color'))
            Text('总样张')
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          
          Column() {
            Text(Math.round(this.sampleStats.avgLikes).toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_color'))
            Text('平均点赞')
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          
          Column() {
            Text(Math.round(this.sampleStats.avgViews).toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_color'))
            Text('平均查看')
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        
        if (this.sampleStats.popularCategories.length > 0) {
          Text('热门分类')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .width('100%')
            .margin({ top: 16, bottom: 8 })
          
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.sampleStats.popularCategories.slice(0, 5), (category: PhotoCategory) => {
              Text(CATEGORY_NAMES[category])
                .fontSize(12)
                .fontColor($r('app.color.brand_color'))
                .backgroundColor('#E3F2FD')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
                .margin({ right: 8, bottom: 8 })
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.background_color'))
      .borderRadius(12)
      .margin({ top: 8, left: 16, right: 16 })
      .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    }
  }

  // 筛选和排序栏
  @Builder
  buildFilterBar() {
    Row() {
      Button() {
        Row() {
          Image($r('app.media.icon_filter'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.secondary_text_color'))
          
          Text('筛选')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
      }
      .backgroundColor($r('app.color.input_background_color'))
      .borderRadius(20)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .onClick(() => {
        this.showFilterPanel = true;
      })
      
      Blank()
      
      Button() {
        Row() {
          Image($r('app.media.ic_add'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.secondary_text_color'))
          
          Text(this.gridColumns === 2 ? '2列' : '3列')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
      }
      .backgroundColor($r('app.color.input_background_color'))
      .borderRadius(20)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .onClick(() => {
        this.gridColumns = this.gridColumns === 2 ? 3 : 2;
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  // 样张网格
  @Builder
  buildPhotoGrid() {
    Scroll() {
      Grid() {
        ForEach(this.filteredPhotos, (photo: SamplePhoto) => {
          GridItem() {
            this.buildPhotoCard(photo)
          }
        })
      }
      .columnsTemplate(this.gridColumns === 2 ? '1fr 1fr' : '1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  // 样张卡片
  @Builder
  buildPhotoCard(photo: SamplePhoto) {
    Column() {
      // 图片
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(photo.thumbnailUri || photo.imageUri)
          .width('100%')
          .aspectRatio(1)
          .borderRadius({ topLeft: 8, topRight: 8 })
          .objectFit(ImageFit.Cover)
        
        // 分类标签
        Text(CATEGORY_NAMES[photo.category])
          .fontSize(10)
          .fontColor($r('app.color.background_color'))
          .backgroundColor($r('app.color.brand_color'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .margin(8)
      }
      
      // 信息
      Column() {
        Text(photo.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        
        Text(photo.photographer || '匿名')
          .fontSize(12)
          .fontColor($r('app.color.secondary_text_color'))
          .width('100%')
          .margin({ top: 4 })
        
        Row() {
          Row() {
            Image($r('app.media.icon_like'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.secondary_text_color'))
            
            Text(photo.likes.toString())
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ left: 2 })
          }
          
          Row() {
            Image($r('app.media.icon_view'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.secondary_text_color'))
            
            Text(photo.views.toString())
              .fontSize(12)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ left: 2 })
          }
          .margin({ left: 12 })
          
          Blank()
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(8)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.viewPhotoDetail(photo);
    })
  }

  // 空状态视图
  @Builder
  buildEmptyView() {
    Column() {
      Image($r('app.media.icon_gallery'))
        .width(120)
        .height(120)
        .fillColor($r('app.color.secondary_text_color'))
        .opacity(0.5)
      
      Text('暂无样张')
        .fontSize(16)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 16 })
      
      Text('成为第一个上传样张的人吧！')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 8 })
      
      Button('上传样张')
        .fontSize(14)
        .fontColor($r('app.color.background_color'))
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .margin({ top: 24 })
        .onClick(() => {
          this.uploadNewSample();
        })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
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
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  // 筛选面板
  @Builder
  buildFilterPanel() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showFilterPanel = false;
        })
      
      // 筛选内容
      Column() {
        Row() {
          Text('筛选条件')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .layoutWeight(1)
          
          Button('重置')
            .fontSize(14)
            .fontColor($r('app.color.brand_color'))
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.resetFilter();
            })
        }
        .width('100%')
        .margin({ bottom: 24 })
        
        // 分类筛选
        Text('分类')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 12 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(Object.values(PhotoCategory), (category: PhotoCategory) => {
            Button(CATEGORY_NAMES[category])
              .fontSize(14)
              .fontColor(this.selectedCategory === category ? 
                $r('app.color.background_color') : $r('app.color.primary_text_color'))
              .backgroundColor(this.selectedCategory === category ? 
                $r('app.color.brand_color') : $r('app.color.input_background_color'))
              .borderRadius(20)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.selectedCategory = this.selectedCategory === category ? undefined : category;
              })
          })
        }
        .width('100%')
        .margin({ bottom: 24 })
        
        // 排序方式
        Text('排序')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 12 })
        
        Column() {
          ForEach(this.getSortOptions(), (item: SortOption) => {
            Row() {
              Text(item.name)
                .fontSize(14)
                .fontColor($r('app.color.primary_text_color'))
                .layoutWeight(1)
              
              Radio({ value: item.type, group: 'sortType' })
                .checked(this.sortType === item.type)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.sortType = item.type;
                  }
                })
            }
            .width('100%')
            .height(44)
            .onClick(() => {
              this.sortType = item.type;
            })
          }, (item: SortOption) => item.type.toString())
        }
        .width('100%')
        .margin({ bottom: 24 })
        
        // 操作按钮
        Row() {
          Button('取消')
            .fontSize(16)
            .fontColor($r('app.color.primary_text_color'))
            .backgroundColor($r('app.color.input_background_color'))
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(() => {
              this.showFilterPanel = false;
            })
          
          Button('确定')
            .fontSize(16)
            .fontColor($r('app.color.background_color'))
            .backgroundColor($r('app.color.brand_color'))
            .borderRadius(8)
            .layoutWeight(1)
            .margin({ left: 12 })
            .onClick(() => {
              this.applyFilter();
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .backgroundColor($r('app.color.background_color'))
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }
}