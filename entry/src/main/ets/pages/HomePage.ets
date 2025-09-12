import { Camera, CameraCategory, SensorFormat } from '../model/Camera';
import { Brand } from '../model/Brand';
import { brandDataService } from '../service/BrandDataService';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import router from '@ohos.router';
import { favoriteService } from '../service/FavoriteService';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct HomePage {
  @State cameras: Camera[] = [];
  @State searchText: string = '';
  @State filteredCameras: Camera[] = [];
  @State brands: string[] = [];
  @State brandDetails: Brand[] = [];
  @State selectedBrand: string = '全部';
  @State favoriteList: CameraDataItem[] = [];
  // 新增：camera_data.json相关状态
  @State cameraDataItems: CameraDataItem[] = [];
  @State filteredCameraDataItems: CameraDataItem[] = [];
  @State dataJsonBrands: string[] = [];
  @StorageProp('refreshHomeFavorites') @Watch('onRefreshFavorites') refreshHomeFavorites: number = 0;
  // 反馈弹窗相关状态
  @State showFeedbackDialog: boolean = false;
  @State feedbackText: string = '';


  async aboutToAppear() {
    // 异步初始化，避免阻塞主线程
    this.initializeData();
    this.loadFavorites();
  }

  // 监听收藏状态刷新
  onRefreshFavorites() {
    this.loadFavorites();
  }
  
  // 异步初始化数据
  private async initializeData() {
    try {
      // 并行加载数据以提高性能
      const results = await Promise.all([
        cameraDataJsonService.getAllCameras(),
        brandDataService.getAllBrands()
      ]);
      
      this.cameraDataItems = results[0];
      this.brandDetails = results[1];
      
      // 从brand.json中获取品牌列表
      const brandNames = this.brandDetails.map(brand => brand.name_en);
      this.brands = ['全部', ...brandNames];

      // 初始化显示所有相机
      this.filteredCameraDataItems = this.cameraDataItems;
    } catch (error) {
      console.error('数据初始化失败:', error);
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
    // 使用默认值，避免索引访问
    const sensorType = '';
    const sensorSize = '';
    const maxShutterSpeed = '1/4000s';
    const maxVideoResolution = '4K/30p';
    
    return {
      id: this.generateNumericId(cameraDataItem.Brand, cameraDataItem.Model),
      brand: cameraDataItem.Brand,
      model: cameraDataItem.Model,
      releaseDate: cameraDataItem.Year || '2023',
      releasePrice: 0,
      imageUrl: cameraDataItem.image_file || '',
      description: `${cameraDataItem.Brand} ${cameraDataItem.Model} 是一款优秀的相机产品。`,
      specifications: {
        sensorType: sensorType,
        megapixels: parseFloat(cameraDataItem.Megapixels?.replace('MP', '') || '0'),
        isoRange: cameraDataItem.ISO || '100-51200',
        shutterSpeed: maxShutterSpeed,
        lensMount: '',
        videoCapability: maxVideoResolution,
        weight: parseFloat(cameraDataItem.Weight?.replace('g', '') || '0'),
        dimensions: cameraDataItem.Dimensions || '130x100x70mm'
      },
      category: this.mapCameraType(sensorType),
      sensorFormat: this.mapSensorFormat(sensorSize)
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
  private mapCameraType(type: string | undefined): CameraCategory {
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
  private mapSensorFormat(format: string | undefined): SensorFormat {
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

  async onSearchTextChange(text: string) {
    this.searchText = text;
    await this.updateFilteredCameras();
  }

  async onBrandChange(brand: string) {
    this.selectedBrand = brand;
    await this.updateFilteredCameras();
  }

  async updateFilteredCameras() {
    this.filteredCameraDataItems = await cameraDataJsonService.getCamerasByBrandAndSearch(
      this.selectedBrand,
      this.searchText
    );
  }

  getBrandDetail(brandName: string): Brand | undefined {
    return this.brandDetails.find(brand => brand.name_en === brandName);
  }

  getBrandLogoPath(brandName: string): string {
    if (brandName === '全部') {
      return '';
    }
    return `brand/${brandName}.png`;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
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
        Text('数码库')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface_color'))
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

      // 顶部搜索栏
      Row() {
        TextInput({ placeholder: '搜索相机品牌或型号...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.divider_color'))
          .fontColor($r('app.color.primary_text_color'))
          .placeholderColor($r('app.color.secondary_text_color'))
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.onSearchTextChange(value);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor($r('app.color.surface_color'))
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

      // 品牌筛选栏
      Column() {
        Text('品牌筛选')
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ left: 16, bottom: 8 })
          .alignSelf(ItemAlign.Start)

        Scroll() {
          Row() {
            ForEach(this.brands, (brand: string) => {
              this.BrandCard(brand, this.getBrandDetail(brand))
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding({ top: 8, bottom: 12 })
      .backgroundColor($r('app.color.background_color'))

      // 相机列表
      List() {
        ForEach(this.filteredCameraDataItems, (camera: CameraDataItem) => {
          ListItem() {
            this.CameraDataCard(camera)
          }
          .margin({ bottom: 8 })
          .onClick(() => {
            console.info(`点击相机: ${camera.Brand} ${camera.Model}`);
            // 跳转到相机详情页面
            this.navigateToCameraDetail(camera);
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.background_color'))

      // 底部反馈提醒
      Row() {
        Text('数据有误或缺失？')
          .fontSize(12)
          .fontColor($r('app.color.secondary_text_color'))
        
        Text('点击反馈')
          .fontSize(12)
          .fontColor($r('app.color.brand_color'))
          .margin({ left: 4 })
          .onClick(() => {
            this.showFeedbackDialog = true;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 16, bottom: 16 })
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.showFeedbackDialog, this.FeedbackDialog(), {
      modalTransition: ModalTransition.NONE,
      backgroundColor: Color.Transparent,
      onAppear: () => {
        console.info('反馈弹窗显示');
      },
      onDisappear: () => {
        console.info('反馈弹窗隐藏');
        this.feedbackText = '';
      }
    })
  }

  @Builder
  FeedbackDialog() {
    Column() {
      // 弹窗背景遮罩
      Column() {
        // 弹窗内容
        Column() {
          // 标题
          Text('请输入相关器材信息')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 8 })
          
          // 副标题
          Text('如 Nikon D780')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ bottom: 20 })
          
          // 输入框
          TextInput({ placeholder: '请输入器材型号...', text: this.feedbackText })
            .width('100%')
            .height(48)
            .borderRadius(8)
            .backgroundColor($r('app.color.surface_color'))
            .fontColor($r('app.color.primary_text_color'))
            .placeholderColor($r('app.color.secondary_text_color'))
            .padding({ left: 16, right: 16 })
            .border({
              width: 1,
              color: $r('app.color.divider_color')
            })
            .margin({ bottom: 24 })
            .onChange((value: string) => {
              this.feedbackText = value;
            })
          
          // 按钮区域
          Row() {
            // 取消按钮
            Button('取消')
              .width('48%')
              .height(44)
              .fontSize(16)
              .fontColor($r('app.color.secondary_text_color'))
              .backgroundColor($r('app.color.surface_color'))
              .border({
                width: 1,
                color: $r('app.color.divider_color')
              })
              .borderRadius(8)
              .onClick(() => {
                this.showFeedbackDialog = false;
              })
            
            Blank()
            
            // 提交按钮
            Button('提交')
              .width('48%')
              .height(44)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor($r('app.color.brand_color'))
              .borderRadius(8)
              .onClick(() => {
                if (this.feedbackText.trim()) {
                  // 处理提交逻辑
                  promptAction.showToast({
                    message: '感谢您的反馈！我们会尽快处理',
                    duration: 2000
                  });
                  this.showFeedbackDialog = false;
                } else {
                  promptAction.showToast({
                    message: '请输入器材信息',
                    duration: 1500
                  });
                }
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('85%')
        .padding(24)
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(16)
        .shadow({
          radius: 20,
          color: $r('app.color.shadow_color'),
          offsetX: 0,
          offsetY: 8
        })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .onClick(() => {
        // 点击遮罩关闭弹窗
        this.showFeedbackDialog = false;
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BrandCard(brandName: string, brandDetail: Brand | undefined) {
    Column() {
      if (brandName === '全部') {
        // 全部品牌的特殊显示
        Column() {
          Image($r('app.media.icon_all'))
            .width(20)
            .height(20)
            .fillColor(this.selectedBrand === brandName ? '#FFFFFF' : $r('app.color.brand_color'))
          
          Text(brandName)
            .fontSize(14)
            .fontColor(this.selectedBrand === brandName ? '#FFFFFF' : '#2C3E50')
            .margin({ top: 6 })
        }
      } else {
        // 具体品牌显示
        Column() {
          // 从rawfile/brand文件夹加载品牌logo
          Image($rawfile(this.getBrandLogoPath(brandName)))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)
            .borderRadius(6)
            .backgroundColor('#FFFFFF')
            .padding(4)
            .onError(() => {
              // 如果图片加载失败，显示默认图标
              console.warn(`Brand logo not found: ${brandName}`);
            })
          
          Text(brandDetail ? brandDetail.name_zh : brandName)
            .fontSize(12)
            .fontColor(this.selectedBrand === brandName ? '#FFFFFF' : $r('app.color.primary_text_color'))
            .margin({ top: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
    }
    .width(90)
    .height(90)
    .padding(8)
    .backgroundColor(this.selectedBrand === brandName ? $r('app.color.brand_color') : $r('app.color.card_background_color'))
    .borderRadius(12)
    .border({
      width: 1,
      color: this.selectedBrand === brandName ? $r('app.color.brand_color') : $r('app.color.border_color')
    })
    .margin({ right: 12 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: this.selectedBrand === brandName ? 8 : 2,
      color: this.selectedBrand === brandName ? $r('app.color.brand_color_light') : $r('app.color.shadow_color'),
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onBrandChange(brandName);
    })
  }

  // 加载收藏列表
  private loadFavorites() {
    try {
      this.favoriteList = favoriteService.getFavorites();
    } catch (error) {
      console.error('加载收藏列表失败:', error);
    }
  }

  // 检查是否已收藏
  private isFavorite(camera: CameraDataItem): boolean {
    return this.favoriteList.some(fav => 
      fav.Brand === camera.Brand && fav.Model === camera.Model
    );
  }

  // 收藏按钮点击事件
  private async onFavoriteClick(camera: CameraDataItem) {
    try {
      const isFav = this.isFavorite(camera);
      
      if (isFav) {
        // 取消收藏
        await favoriteService.removeFavorite(camera);
        promptAction.showToast({
          message: '已取消收藏',
          duration: 2000
        });
      } else {
        // 添加收藏
        await favoriteService.addFavorite(camera);
        promptAction.showToast({
          message: '已添加到收藏',
          duration: 2000
        });
      }
      
      // 更新本地收藏列表状态
      this.favoriteList = favoriteService.getFavorites();
      
      // 通知其他页面刷新收藏数据
      AppStorage.setOrCreate('refreshHomeFavorites', Date.now());
    } catch (error) {
      console.error('收藏操作失败:', error);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }
  }

  // 添加到对比按钮点击事件
  private onAddToCompareClick(camera: CameraDataItem) {
    try {
      // 将相机数据存储到AppStorage
      AppStorage.setOrCreate('cameraToAdd', camera);
      // 切换到器材对比tab (index: 2)
      AppStorage.setOrCreate('switchToTab', 2);
      
      promptAction.showToast({
        message: '已添加到对比',
        duration: 2000
      });
    } catch (error) {
      console.error('添加到对比失败:', error);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }
  }

  @Builder
  CameraDataCard(camera: CameraDataItem) {
    Row() {
      // 相机图片
      Image($rawfile(cameraDataJsonService.getCameraImagePath(camera)))
        .width(70)
        .height(50)
        .objectFit(ImageFit.Cover)
        .borderRadius(6)
        .margin({ right: 10 })
        .alt($r('app.media.foreground'))

      // 相机信息
      Column({ space: 2 }) {
        Text(camera.Model)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(camera.Brand)
          .fontSize(13)
          .fontColor($r('app.color.secondary_text_color'))

        Row({ space: 6 }) {
          if (camera.Year) {
            Text(camera.Year + '年')
              .fontSize(11)
              .fontColor($r('app.color.tertiary_text_color'))
          }
          if (camera.Megapixels) {
            Text(camera.Megapixels)
              .fontSize(11)
              .fontColor($r('app.color.tertiary_text_color'))
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 操作按钮区域
      Row({ space: 6 }) {
        // 收藏按钮
        Column() {
          Image($r('app.media.icon_like'))
            .width(20)
            .height(20)
            .fillColor(this.isFavorite(camera) ? '#FF6B6B' : $r('app.color.secondary_text_color'))
          Text(this.isFavorite(camera) ? '已收藏' : '收藏')
            .fontSize(8)
            .fontColor(this.isFavorite(camera) ? '#FF6B6B' : $r('app.color.secondary_text_color'))
        }
        .padding(4)
        .borderRadius(3)
        .backgroundColor(this.isFavorite(camera) ? '#FFE5E5' : $r('app.color.divider_color'))
        .onClick(() => {
          this.onFavoriteClick(camera);
        })
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(8)
    .shadow({
      radius: 2,
      color: $r('app.color.shadow_color'),
      offsetX: 0,
      offsetY: 1
    })
  }
}