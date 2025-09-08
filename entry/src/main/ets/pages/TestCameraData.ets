import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';

@Entry
@Component
struct TestCameraData {
  @State brands: string[] = [];
  @State selectedBrand: string = '';
  @State models: CameraDataItem[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear() {
    try {
      this.brands = await cameraDataJsonService.getAllBrands();
      console.info(`加载了 ${this.brands.length} 个品牌`);
      this.isLoading = false;
    } catch (error) {
      console.error('加载品牌数据失败:', error.message);
      this.isLoading = false;
    }
  }

  async onBrandSelected(brand: string) {
    this.selectedBrand = brand;
    try {
      this.models = await cameraDataJsonService.getModelsByBrand(brand);
      console.info(`${brand} 品牌有 ${this.models.length} 个型号`);
    } catch (error) {
      console.error('加载型号数据失败:', error.message);
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('相机品牌和型号测试')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      if (this.isLoading) {
        Text('加载中...')
          .fontSize(16)
      } else {
        // 品牌列表
        Text(`共 ${this.brands.length} 个品牌`)
          .fontSize(16)
          .fontColor('#666666')

        List() {
          ForEach(this.brands.slice(0, 10), (brand: string) => {
            ListItem() {
              Row() {
                Text(brand)
                  .fontSize(16)
                  .layoutWeight(1)
                
                Button('查看型号')
                  .fontSize(14)
                  .onClick(() => {
                    this.onBrandSelected(brand);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.selectedBrand === brand ? '#E3F2FD' : Color.White)
              .borderRadius(8)
            }
          })
        }
        .height(300)
        .scrollBar(BarState.Auto)

        if (this.selectedBrand) {
          Divider().margin({ top: 16, bottom: 16 })
          
          Text(`${this.selectedBrand} 的型号 (${this.models.length}个)`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)

          List() {
            ForEach(this.models.slice(0, 5), (model: CameraDataItem) => {
              ListItem() {
                Row() {
                  Column({ space: 4 }) {
                    Text(model.Model)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    
                    Row({ space: 8 }) {
                      if (model.Year) {
                        Text(model.Year + '年')
                          .fontSize(12)
                          .fontColor('#666666')
                      }
                      if (model.Megapixels) {
                        Text(model.Megapixels)
                          .fontSize(12)
                          .fontColor('#666666')
                      }
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
              }
            })
          }
          .height(200)
          .scrollBar(BarState.Auto)
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FAFAFA')
  }
}