import { Camera } from '../model/Camera';
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
    // 加载camera_data.json数据
    this.cameraDataItems = await cameraDataJsonService.getAllCameras();
    this.dataJsonBrands = await cameraDataJsonService.getAllBrands();
    this.brands = ['全部', ...this.dataJsonBrands];
    
    // 加载品牌详细信息
    this.brandDetails = await brandDataService.getAllBrands();
    
    // 初始化筛选结果
    this.updateFilteredCameras();
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
    return this.brandDetails.find(brand => brand.name_zh === brandName);
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        TextInput({ placeholder: '搜索相机品牌或型号...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F1F2F6')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.onSearchTextChange(value);
          })

        Button() {
          Image($r('app.media.ic_search'))
            .width(20)
            .height(20)
            .fillColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#3498DB')
        .margin({ left: 12 })
        .onClick(() => {
          // 搜索逻辑已在onChange中处理
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })

      // 品牌筛选栏
      Column() {
        Text('品牌筛选')
          .fontSize(14)
          .fontColor('#7F8C8D')
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
      .backgroundColor('#F8F9FA')

      // 相机列表
      List() {
        ForEach(this.filteredCameraDataItems, (camera: CameraDataItem) => {
          ListItem() {
            this.CameraDataCard(camera)
          }
          .margin({ bottom: 12 })
          .onClick(() => {
            // 暂时跳转到详情页，后续可以扩展
            console.info(`点击相机: ${camera.Brand} ${camera.Model}`);
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F8F9FA')
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
          Image($r('app.media.ic_home'))
            .width(24)
            .height(24)
            .fillColor(this.selectedBrand === brandName ? '#FFFFFF' : '#3498DB')
          
          Text(brandName)
            .fontSize(12)
            .fontColor(this.selectedBrand === brandName ? '#FFFFFF' : '#2C3E50')
            .margin({ top: 4 })
        }
      } else {
        // 具体品牌显示
        Column() {
          if (brandDetail && brandDetail.logo_url) {
            Image(brandDetail.logo_url)
              .width(32)
              .height(32)
              .objectFit(ImageFit.Contain)
              .borderRadius(4)
              .backgroundColor('#FFFFFF')
              .padding(2)
          } else {
            // 默认品牌图标
            Text(brandName.charAt(0))
              .fontSize(16)
              .fontColor(this.selectedBrand === brandName ? '#FFFFFF' : '#3498DB')
              .fontWeight(FontWeight.Bold)
              .width(32)
              .height(32)
              .textAlign(TextAlign.Center)
              .borderRadius(4)
              .backgroundColor(this.selectedBrand === brandName ? 'rgba(255,255,255,0.2)' : '#E3F2FD')
          }
          
          Text(brandName)
            .fontSize(12)
            .fontColor(this.selectedBrand === brandName ? '#FFFFFF' : '#2C3E50')
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
    }
    .width(70)
    .height(70)
    .padding(6)
    .backgroundColor(this.selectedBrand === brandName ? '#3498DB' : '#FFFFFF')
    .borderRadius(12)
    .border({
      width: 1,
      color: this.selectedBrand === brandName ? '#3498DB' : '#E8E8E8'
    })
    .margin({ right: 12 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: this.selectedBrand === brandName ? 8 : 2,
      color: this.selectedBrand === brandName ? '#3498DB40' : '#00000010',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onBrandChange(brandName);
    })
}

  @Builder
  CameraCard(camera: Camera) {
    Column() {
      Column() {
        Row() {
          // 相机图片占位符
          Column() {
            Image($r('app.media.foreground'))
              .width(60)
              .height(60)
              .borderRadius(8)
          }
          .width(80)
          .height(80)
          .backgroundColor('#E8E8E8')
          .justifyContent(FlexAlign.Center)
          .borderRadius(8)

          Column() {
            Text(`${camera.brand} ${camera.model}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C3E50')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(`发布时间: ${camera.releaseDate}`)
              .fontSize(14)
              .fontColor('#7F8C8D')
              .margin({ top: 4 })

            Text(`发布价格: $${camera.releasePrice}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#27AE60')
              .margin({ top: 4 })

            Row() {
              Text(camera.category)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor('#3498DB')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(10)
              
              Text(camera.sensorFormat)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor('#E67E22')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(10)
                .margin({ left: 8 })
            }
            .margin({ top: 6 })
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Text(camera.description)
          .fontSize(14)
          .fontColor('#34495E')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 12 })
          .lineHeight(20)
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
    .padding(2)
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

      // 相机信息
      Column({ space: 4 }) {
        Text(camera.Model)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(camera.Brand)
          .fontSize(14)
          .fontColor('#666666')

        Row({ space: 8 }) {
          if (camera.Year) {
            Text(camera.Year + '年')
              .fontSize(12)
              .fontColor('#999999')
          }
          if (camera.Megapixels) {
            Text(camera.Megapixels)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 箭头图标
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}