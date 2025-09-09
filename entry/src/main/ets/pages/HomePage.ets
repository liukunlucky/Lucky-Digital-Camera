import { Camera, CameraCategory, SensorFormat } from '../model/Camera';
import { cameraDataService } from '../service/CameraDataService';
import { Brand } from '../model/Brand';
import { brandDataService } from '../service/BrandDataService';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import router from '@ohos.router';


@Component
export struct HomePage {
  @State cameras: Camera[] = [];
  @State searchText: string = '';
  @State filteredCameras: Camera[] = [];
  @State brands: string[] = [];
  @State brandDetails: Brand[] = [];
  @State selectedBrand: string = '全部';
  // 新增：camera_data.json相关状态
  @State cameraDataItems: CameraDataItem[] = [];
  @State filteredCameraDataItems: CameraDataItem[] = [];
  @State dataJsonBrands: string[] = [];


  async aboutToAppear() {
    // 异步初始化，避免阻塞主线程
    this.initializeData();
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
        Text('数码库')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
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
          .margin({ bottom: 12 })
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

  @Builder
  CameraDataCard(camera: CameraDataItem) {
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

      // 箭头图标
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor($r('app.color.tertiary_text_color'))
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
  }
}