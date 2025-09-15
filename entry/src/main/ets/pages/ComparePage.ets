import router from '@ohos.router';
import { MyEquipmentItem } from '../model/MyEquipmentModel';
import { myEquipmentService } from '../service/MyEquipmentService';
import { promptAction } from '@kit.ArkUI';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import { EnhancedCompareView } from '../components/EnhancedCompareView';

@Component
export struct ComparePage {
  @State equipmentList: MyEquipmentItem[] = [];
  @State selectedEquipment1: MyEquipmentItem | null = null;
  @State selectedEquipment2: MyEquipmentItem | null = null;
  @State showSelector1: boolean = false;
  @State showSelector2: boolean = false;
  @State allCameras: CameraDataItem[] = [];
  @State filteredCameras: CameraDataItem[] = [];
  @State searchText: string = '';
  @State selectedTab: number = 0; // 0: 我的器材, 1: 全部相机
  @StorageLink('cameraToAdd') cameraToAdd: CameraDataItem | null = null;
  @State isAllCamerasLoaded: boolean = false; // 标记全部相机是否已加载
  @State showOnlyDifferent: boolean = false; // 仅展示不同选项的开关
  @StorageProp('refreshMyEquipment') @Watch('onRefreshMyEquipment') refreshMyEquipment: number = 0;

  aboutToAppear() {
    this.loadEquipmentData();
    this.handleRouterParams();
    this.handleAppStorageCamera();
    this.loadAllCameras()
  }

  // 监听我的器材数据刷新
  onRefreshMyEquipment() {
    this.loadEquipmentData();
  }

  private async loadEquipmentData() {
    this.equipmentList = myEquipmentService.getAllEquipment();
  }

  private async loadAllCameras() {
    if (!this.isAllCamerasLoaded) {
      this.allCameras = await cameraDataJsonService.getAllCameras();
      this.filteredCameras = this.allCameras;
      this.isAllCamerasLoaded = true;
    }
  }

  private handleRouterParams() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['cameraToAdd']) {
      const cameraToAdd = params['cameraToAdd'] as CameraDataItem;
      this.addCameraToCompare(cameraToAdd);
    }
  }

  // 处理AppStorage传来的相机数据
  private handleAppStorageCamera() {
    if (this.cameraToAdd) {
      this.addCameraToCompare(this.cameraToAdd);
      // 清除AppStorage中的数据
      AppStorage.setOrCreate('cameraToAdd', null);
    }
  }

  // 添加相机到对比
  private addCameraToCompare(camera: CameraDataItem) {
    // 将传入的相机转换为MyEquipmentItem格式并自动选择
    const equipmentItem: MyEquipmentItem = {
      id: Date.now(),
      equipmentName: `${camera.Brand} ${camera.Model}`,
      brand: camera.Brand,
      model: camera.Model,
      cameraDataItem: camera,
      transactions: [],
      addTime: new Date().toISOString()
    };
    this.selectedEquipment1 = equipmentItem;
  }

  private filterCameras() {
    let filtered = this.allCameras;
    
    // 文本搜索
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      filtered = filtered.filter(camera => 
        camera.Brand.toLowerCase().includes(searchLower) ||
        camera.Model.toLowerCase().includes(searchLower)
      );
    }
    

    
    this.filteredCameras = filtered;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('器材对比')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.surface_color'))
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

      // 可滚动的对比内容
      Scroll() {
        Column() {
        // 相机图片展示区域
        if (this.selectedEquipment1 && this.selectedEquipment2) {
          Row() {
            // 器材1图片
            Column() {
              if (this.selectedEquipment1.cameraDataItem) {
                Image($rawfile(cameraDataJsonService.getCameraImagePath(this.selectedEquipment1.cameraDataItem)))
                  .width(140)
                  .height(105)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                  .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
                  .alt($r('app.media.foreground'))
              } else {
                Column() {
                  Text('📷')
                    .fontSize(40)
                    .fontColor($r('app.color.tertiary_text_color'))
                }
                .width(140)
                .height(105)
                .backgroundColor($r('app.color.divider_color'))
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
              }
              
              Text(this.selectedEquipment1.equipmentName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.primary_text_color'))
                .margin({ top: 12 })
                .maxLines(2)
                .textAlign(TextAlign.Center)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            
            // VS标识
            Column() {
              Text('VS')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.brand_color'))
                .textShadow({ radius: 2, color: 'rgba(255,107,53,0.3)', offsetX: 0, offsetY: 2 })
            }
            .width(60)
            .justifyContent(FlexAlign.Center)
            
            // 器材2图片
            Column() {
              if (this.selectedEquipment2.cameraDataItem) {
                Image($rawfile(cameraDataJsonService.getCameraImagePath(this.selectedEquipment2.cameraDataItem)))
                  .width(140)
                  .height(105)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                  .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
                  .alt($r('app.media.foreground'))
              } else {
                Column() {
                  Text('📷')
                    .fontSize(40)
                    .fontColor($r('app.color.tertiary_text_color'))
                }
                .width(140)
                .height(105)
                .backgroundColor($r('app.color.divider_color'))
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
              }
              
              Text(this.selectedEquipment2.equipmentName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.primary_text_color'))
                .margin({ top: 12 })
                .maxLines(2)
                .textAlign(TextAlign.Center)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 24 })
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius({bottomLeft: 16, bottomRight: 16})
          .margin({ left: 16, right: 16, bottom: 16 })
          .shadow({ radius: 6, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
        }

        // 选择器材区域
        Row() {
          // 器材1选择
          Column() {
            Text('器材1')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ bottom: 8 })

            Button(this.selectedEquipment1 ? this.selectedEquipment1.equipmentName : '点击选择器材')
              .width('100%')
              .height(52)
              .fontSize(14)
              .fontColor(this.selectedEquipment1 ? $r('app.color.primary_text_color') : $r('app.color.secondary_text_color'))
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.divider_color') })
              .onClick(() => {
                this.showSelector1 = true;
              })
          }
          .layoutWeight(1)
          .margin({ right: 8 })
          .bindSheet($$this.showSelector1, this.EquipmentSelector(1), {
            height: '60%',
            showClose: false,
            dragBar: true
          })

          // VS标识
          Text('VS')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_color'))
            .margin({ left: 8, right: 8 })

          // 器材2选择
          Column() {
            Text('器材2')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ bottom: 8 })

            Button(this.selectedEquipment2 ? this.selectedEquipment2.equipmentName : '点击选择器材')
              .width('100%')
              .height(52)
              .fontSize(14)
              .fontColor(this.selectedEquipment2 ? $r('app.color.primary_text_color') : $r('app.color.secondary_text_color'))
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.divider_color') })
              .onClick(() => {
                this.showSelector2 = true;
              })
          }
          .layoutWeight(1)
          .margin({ left: 8 })
          .bindSheet($$this.showSelector2, this.EquipmentSelector(2), {
            height: '60%',
            showClose: false,
            dragBar: true
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius({bottomLeft: 16, bottomRight: 16})
        .margin({ left: 16, right: 16, bottom: 16 })
        .shadow({ radius: 6, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })

        // 一键清空按钮
        if (this.selectedEquipment1 || this.selectedEquipment2) {
          Row() {
            Button('一键清空')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('transparent')
              .fontColor($r('app.color.brand_color'))
              .border({ width: 1.5, color: $r('app.color.brand_color') })
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .onClick(() => {
                this.selectedEquipment1 = null;
                this.selectedEquipment2 = null;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 16, left: 16, right: 16 })
        }

        // 对比结果
        if (this.selectedEquipment1 && this.selectedEquipment2) {
          EnhancedCompareView({
            equipment1: this.selectedEquipment1,
            equipment2: this.selectedEquipment2
          })
            .margin({ left: 16, right: 16 })
        } else {
          Column() {
            Image($r('app.media.icon_compare'))
              .width(64)
              .height(64)
              .fillColor($r('app.color.tertiary_text_color'))
              .margin({ bottom: 16 })

            Text('请选择两个器材进行对比')
              .fontSize(16)
              .fontColor($r('app.color.secondary_text_color'))
              .fontWeight(FontWeight.Medium)
              
            Text('选择器材后可查看详细参数对比')
              .fontSize(14)
              .fontColor($r('app.color.tertiary_text_color'))
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.background_color'))
          .margin({ left: 16, right: 16 })
          .borderRadius(16)
        }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .height('100%')
    }
    .backgroundColor($r('app.color.background_color'))
  }

  @Builder
  CompareResultCard() {
    Column() {
      // 器材图片对比
      Row() {
        // 器材1图片
        Column() {
          if (this.selectedEquipment1!.cameraDataItem) {
            Image($rawfile(cameraDataJsonService.getCameraImagePath(this.selectedEquipment1!.cameraDataItem)))
              .width(120)
              .height(90)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.foreground'))
          } else {
            Column() {
              Text('📷')
                .fontSize(32)
            }
            .width(120)
            .height(90)
            .backgroundColor($r('app.color.divider_color'))
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
          }
          
          Text(this.selectedEquipment1!.equipmentName)
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 8 })
            .maxLines(2)
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Text('VS')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_color'))
          .margin({ left: 16, right: 16 })
        
        // 器材2图片
        Column() {
          if (this.selectedEquipment2!.cameraDataItem) {
            Image($rawfile(cameraDataJsonService.getCameraImagePath(this.selectedEquipment2!.cameraDataItem)))
              .width(120)
              .height(90)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.foreground'))
          } else {
            Column() {
              Text('📷')
                .fontSize(32)
            }
            .width(120)
            .height(90)
            .backgroundColor($r('app.color.divider_color'))
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
          }
          
          Text(this.selectedEquipment2!.equipmentName)
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 8 })
            .maxLines(2)
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background_color'))
      .borderRadius(12)
      .margin({ bottom: 16 })
      
      // 基本信息对比
      Column() {
        Text('基本信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 16 })
        
        this.CompareRowWithFilter('器材名称', this.selectedEquipment1!.equipmentName, this.selectedEquipment2!.equipmentName)
        this.CompareRowWithFilter('品牌', this.selectedEquipment1!.brand, this.selectedEquipment2!.brand)
        this.CompareRowWithFilter('型号', this.selectedEquipment1!.model, this.selectedEquipment2!.model)
        this.CompareRowWithFilter('添加时间', this.formatDate(this.selectedEquipment1!.addTime), this.formatDate(this.selectedEquipment2!.addTime))
        
        // 相机详细属性对比
          if (this.selectedEquipment1!.cameraDataItem && this.selectedEquipment2!.cameraDataItem) {
            this.CompareRowWithFilter('发布年份', this.selectedEquipment1!.cameraDataItem.Year || '未知', this.selectedEquipment2!.cameraDataItem.Year || '未知')
            this.CompareRowWithFilter('传感器尺寸', this.selectedEquipment1!.cameraDataItem.SensorSize || '未知', this.selectedEquipment2!.cameraDataItem.SensorSize || '未知')
            this.CompareRowWithFilter('有效像素', this.selectedEquipment1!.cameraDataItem.EffectiveMegapixels || this.selectedEquipment1!.cameraDataItem.Megapixels || '未知', this.selectedEquipment2!.cameraDataItem.EffectiveMegapixels || this.selectedEquipment2!.cameraDataItem.Megapixels || '未知')
            this.CompareRowWithFilter('ISO范围', this.selectedEquipment1!.cameraDataItem.ISO || '未知', this.selectedEquipment2!.cameraDataItem.ISO || '未知')
            this.CompareRowWithFilter('最大光圈', this.selectedEquipment1!.cameraDataItem.MaxAperture || '未知', this.selectedEquipment2!.cameraDataItem.MaxAperture || '未知')
            this.CompareRowWithFilter('视频规格', this.selectedEquipment1!.cameraDataItem.MaxVideoResolution || '未知', this.selectedEquipment2!.cameraDataItem.MaxVideoResolution || '未知')
            this.CompareRowWithFilter('屏幕尺寸', this.selectedEquipment1!.cameraDataItem.ScreenSize || '未知', this.selectedEquipment2!.cameraDataItem.ScreenSize || '未知')
            this.CompareRowWithFilter('取景器', this.selectedEquipment1!.cameraDataItem.Viewfinder || '未知', this.selectedEquipment2!.cameraDataItem.Viewfinder || '未知')
            this.CompareRowWithFilter('存储类型', this.selectedEquipment1!.cameraDataItem.StorageTypes || '未知', this.selectedEquipment2!.cameraDataItem.StorageTypes || '未知')
            this.CompareRowWithFilter('电池', this.selectedEquipment1!.cameraDataItem.Battery || '未知', this.selectedEquipment2!.cameraDataItem.Battery || '未知')
            this.CompareRowWithFilter('重量', this.selectedEquipment1!.cameraDataItem.Weight || '未知', this.selectedEquipment2!.cameraDataItem.Weight || '未知')
            this.CompareRowWithFilter('尺寸', this.selectedEquipment1!.cameraDataItem.Dimensions || '未知', this.selectedEquipment2!.cameraDataItem.Dimensions || '未知')
          }
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background_color'))
      .borderRadius(12)
      .margin({ bottom: 16 })

      // 交易信息对比
      if (this.selectedEquipment1!.transactions.length > 0 && this.selectedEquipment2!.transactions.length > 0) {
        Column() {
          Text('交易信息')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          this.CompareRowWithFilter('交易类型', 
            this.selectedEquipment1!.transactions[0]?.type === 'buy' ? '买入' : '卖出',
            this.selectedEquipment2!.transactions[0]?.type === 'buy' ? '买入' : '卖出'
          )
          this.CompareRowWithFilter('交易价格', 
            (this.selectedEquipment1!.transactions[0]?.price || 0) > 0 ? `¥${this.selectedEquipment1!.transactions[0]?.price}` : '未填写',
            (this.selectedEquipment2!.transactions[0]?.price || 0) > 0 ? `¥${this.selectedEquipment2!.transactions[0]?.price}` : '未填写'
          )
          this.CompareRowWithFilter('交易日期', 
            this.selectedEquipment1!.transactions[0]?.date || '未知',
            this.selectedEquipment2!.transactions[0]?.date || '未知'
          )
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
      }
    }
    .width('100%')
  }

  @Builder
  CompareRow(label: string, value1: string, value2: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .width(80)
      
      Text(value1)
        .fontSize(14)
        .fontColor(value1 !== value2 ? $r('app.color.brand_color') : $r('app.color.primary_text_color'))
        .fontWeight(value1 !== value2 ? FontWeight.Medium : FontWeight.Normal)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Text(value2)
        .fontSize(14)
        .fontColor(value1 !== value2 ? $r('app.color.brand_color') : $r('app.color.primary_text_color'))
        .fontWeight(value1 !== value2 ? FontWeight.Medium : FontWeight.Normal)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .border({ width: { bottom: 1 }, color: $r('app.color.divider_color') })
  }
  
  @Builder
  CompareRowWithFilter(label: string, value1: string, value2: string) {
    // 如果开启了"仅展示不同"开关，且两个值相同，则不显示该行
    if (this.showOnlyDifferent && value1 === value2) {
      // 不渲染任何内容
    } else {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .width(80)
        
        Text(value1)
          .fontSize(14)
          .fontColor(value1 !== value2 ? $r('app.color.brand_color') : $r('app.color.primary_text_color'))
          .fontWeight(value1 !== value2 ? FontWeight.Medium : FontWeight.Normal)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text(value2)
          .fontSize(14)
          .fontColor(value1 !== value2 ? $r('app.color.brand_color') : $r('app.color.primary_text_color'))
          .fontWeight(value1 !== value2 ? FontWeight.Medium : FontWeight.Normal)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .border({ width: { bottom: 1 }, color: $r('app.color.divider_color') })
    }
  }

  @Builder
  EquipmentSelector(selectorType: number) {
    Column() {
      Text(`选择器材${selectorType}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })
      
      // 搜索框
      TextInput({ placeholder: '搜索相机品牌或型号...', text: this.searchText })
        .width('calc(100% - 32vp)')
        .height(40)
        .borderRadius(8)
        .backgroundColor($r('app.color.card_background_color'))
        .margin({ left: 16, right: 16, bottom: 16 })
        .border({ width: 1, color: $r('app.color.divider_color') })
        .onChange((value: string) => {
          this.searchText = value;
          this.filterCameras();
        })
      
      // Tab切换
      Row({space: 25}) {
        Button('我的器材')
          .width('40%')
          .height(40)
          .fontSize(14)
          .fontWeight(this.selectedTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === 0 ? '#FFFFFF' : $r('app.color.secondary_text_color'))
          .backgroundColor(this.selectedTab === 0 ? $r('app.color.brand_color') : $r('app.color.card_background_color'))
          .borderRadius(0)
          .onClick(() => {
            this.selectedTab = 0;
          })
        
        Button('全部相机')
          .width('40%')
          .height(40)
          .fontSize(14)
          .fontWeight(this.selectedTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTab === 1 ? '#FFFFFF' : $r('app.color.secondary_text_color'))
          .backgroundColor(this.selectedTab === 1 ? $r('app.color.brand_color') : $r('app.color.card_background_color'))
          .borderRadius(0)
          .onClick(async () => {
            this.selectedTab = 1;
          })
      }
      .width('calc(100% - 32vp)')
      .margin({ left: 16, right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.divider_color'))
      .borderRadius(8)
      
      // 内容区域
      if (this.selectedTab === 0) {
        // 我的器材列表
        if (this.equipmentList.length > 0) {
          List() {
            ForEach(this.equipmentList, (item: MyEquipmentItem) => {
              ListItem() {
                this.EquipmentItemCard(item, selectorType, true)
              }
              .margin({ bottom: 8 })
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .padding({ left: 16, right: 16 })
        } else {
          Column() {
            Text('暂无器材')
              .fontSize(16)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ bottom: 8 })
            
            Text('去添加你的第一台器材吧')
              .fontSize(14)
              .fontColor($r('app.color.tertiary_text_color'))
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      } else {
        // 全部相机列表
        List() {
          ForEach(this.filteredCameras, (camera: CameraDataItem) => {
            ListItem() {
              this.CameraItemCard(camera, selectorType)
            }
            .margin({ bottom: 8 })
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  EquipmentItemCard(item: MyEquipmentItem, selectorType: number, isMyEquipment: boolean) {
    Row() {
      if (item.cameraDataItem) {
        Image($rawfile(cameraDataJsonService.getCameraImagePath(item.cameraDataItem)))
          .width(50)
          .height(50)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .margin({ right: 12 })
          .alt($r('app.media.foreground'))
      } else {
        Column() {
          Text('📷')
            .fontSize(20)
        }
        .width(50)
        .height(50)
        .backgroundColor($r('app.color.divider_color'))
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })
      }
      
      Column() {
        Text(item.equipmentName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(`${item.brand} ${item.model}`)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      if (isMyEquipment) {
        Text('我的')
          .fontSize(12)
          .fontColor('#4CAF50')
          .backgroundColor('#E8F5E8')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .margin({ right: 8 })
      }
      
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor($r('app.color.tertiary_text_color'))
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(8)
    .onClick(() => {
      if (selectorType === 1) {
        this.selectedEquipment1 = item;
        this.showSelector1 = false;
      } else {
        this.selectedEquipment2 = item;
        this.showSelector2 = false;
      }
    })
  }
  
  @Builder
  CameraItemCard(camera: CameraDataItem, selectorType: number) {
    Row() {
      Image($rawfile(cameraDataJsonService.getCameraImagePath(camera)))
        .width(50)
        .height(50)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })
        .alt($r('app.media.foreground'))
      
      Column() {
        Text(`${camera.Brand} ${camera.Model}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row() {
          if (camera.Year) {
            Text(camera.Year + '年')
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
              .margin({ right: 8 })
          }

        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor($r('app.color.tertiary_text_color'))
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(8)
    .onClick(() => {
      // 将相机转换为MyEquipmentItem格式
      const equipmentItem: MyEquipmentItem = {
        id: Date.now(),
        equipmentName: `${camera.Brand} ${camera.Model}`,
        brand: camera.Brand,
        model: camera.Model,
        cameraDataItem: camera,
        transactions: [],
        addTime: new Date().toISOString()
      };
      
      if (selectorType === 1) {
        this.selectedEquipment1 = equipmentItem;
        this.showSelector1 = false;
      } else {
        this.selectedEquipment2 = equipmentItem;
        this.showSelector2 = false;
      }
    })
  }
  


  private formatDate(dateString: string): string {
    const date = new Date(dateString);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
  }
}