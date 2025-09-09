import router from '@ohos.router';
import { MyEquipmentItem } from '../model/MyEquipmentModel';
import { myEquipmentService } from '../service/MyEquipmentService';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import { Camera, CameraCategory, SensorFormat } from '../model/Camera';
import promptAction from '@ohos.promptAction';

@Component
export struct MyEquipmentPage {
  @State equipmentList: MyEquipmentItem[] = [];
  @State showAddSheet: boolean = false;
  @State selectedCamera: CameraDataItem | null = null;
  @State transactionType: 'buy' | 'sell' = 'buy';
  @State transactionDate: string = '';
  @State transactionPrice: string = '';
  @State transactionNotes: string = '';
  @State cameraList: CameraDataItem[] = [];
  @State showCameraSelector: boolean = false;
  @State showDatePicker: boolean = false;

  aboutToAppear() {
    this.loadEquipmentData();
    this.loadCameraData();
    this.transactionDate = new Date().toISOString().split('T')[0];
  }

  private loadEquipmentData() {
    this.equipmentList = myEquipmentService.getAllEquipment();
  }

  private async loadCameraData() {
    this.cameraList = await cameraDataJsonService.getAllCameras();
  }

  private async addEquipment() {
    if (!this.selectedCamera) {
      promptAction.showToast({ message: '请选择器材', duration: 2000 });
      return;
    }

    const equipment: MyEquipmentItem = {
      id: Date.now(),
      cameraDataItem: this.selectedCamera,
      equipmentName: `${this.selectedCamera.Brand} ${this.selectedCamera.Model}`,
      brand: this.selectedCamera.Brand,
      model: this.selectedCamera.Model,
      imageUrl: this.selectedCamera.image_file,
      transactions: [{
        type: this.transactionType,
        date: this.transactionDate,
        price: this.transactionPrice ? parseFloat(this.transactionPrice) : 0,
        notes: this.transactionNotes
      }],
      addTime: new Date().toISOString()
    };

    const success = await myEquipmentService.addEquipment(equipment);
    if (success) {
      this.loadEquipmentData();
      this.resetForm();
      this.showAddSheet = false;
      promptAction.showToast({ message: '添加成功', duration: 2000 });
    } else {
      promptAction.showToast({ message: '添加失败', duration: 2000 });
    }
  }

  private resetForm() {
    this.selectedCamera = null;
    this.transactionType = 'buy';
    this.transactionDate = new Date().toISOString().split('T')[0];
    this.transactionPrice = '';
    this.transactionNotes = '';
  }

  // 跳转到回忆页面
  private navigateToMemory() {
    router.pushUrl({
      url: 'pages/MemoryPage'
    }).catch((error: Error) => {
      console.error('跳转到回忆页面失败:', error.message);
    });
  }

  // 显示删除确认对话框
  private showDeleteConfirmDialog(item: MyEquipmentItem) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除 "${item.equipmentName}" 吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
          // 取消操作
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF5722',
        action: () => {
          this.deleteEquipmentById(item.id);
        }
      }
    });
  }

  // 删除器材
  private async deleteEquipmentById(id: number) {
    try {
      await myEquipmentService.deleteEquipment(id);
      this.loadEquipmentData();
      promptAction.showToast({
        message: '器材删除成功',
        duration: 2000
      });
    } catch (error) {
      console.error('删除器材失败:', error);
      promptAction.showToast({
        message: '删除失败，请重试',
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

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button() {
          Image($r('app.media.ic_add'))
            .width(20)
            .height(20)
            .fillColor('#FFFFFF')
        }
        .width(36)
        .height(36)
        .visibility(Visibility.Hidden)
        Text('我的器材')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))

        Button() {
          Image($r('app.media.ic_add'))
            .width(20)
            .height(20)
            .fillColor('#FFFFFF')
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor($r('app.color.brand_color'))
        .onClick(() => {
          this.showAddSheet = true;
        })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface_color'))
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
      .bindSheet($$this.showAddSheet, this.AddEquipmentSheet(), {
        height: '60%',
        dragBar: true,
        backgroundColor: $r('app.color.surface_color'),
        onDisappear: () => {
          this.showAddSheet = false;
          this.resetForm();
        }
      })
      .bindContentCover($$this.showDatePicker, this.DatePickerSheet(), ModalTransition.NONE)

      if (this.equipmentList.length > 0) {
        // 器材列表
        Column() {
          List() {
            ForEach(this.equipmentList, (item: MyEquipmentItem) => {
              ListItem() {
                this.EquipmentCard(item)
              }
              .margin({ bottom: 12 })
              .onClick(() => {
                if (item.cameraDataItem) {
                  this.navigateToCameraDetail(item.cameraDataItem);
                }
              })
            })
          }

          // 生成回忆按钮
          Button('生成回忆')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.brand_color'))
            .fontColor('#FFFFFF')
            .borderRadius(12)
            .margin({ top: 16 })
            .onClick(() => {
              this.navigateToMemory();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 16 })
        .backgroundColor($r('app.color.background_color'))
      } else {
        // 空状态
        Column() {
          Image($r('app.media.ic_empty'))
            .width(120)
            .height(120)
            .fillColor($r('app.color.tertiary_text_color'))
            .margin({ bottom: 16 })

          Text('器材库空空如也～')
            .fontSize(16)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ bottom: 8 })

          Text('点击右上角 + 号添加你的第一台器材')
            .fontSize(14)
            .fontColor($r('app.color.tertiary_text_color'))
            .margin({ bottom: 24 })

          Button('添加器材')
            .width(120)
            .height(40)
            .fontSize(14)
            .backgroundColor($r('app.color.brand_color'))
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              this.showAddSheet = true;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color'))
      }
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showCameraSelector, this.CameraSelectorSheet(), {
      height: '80%',
      dragBar: true,
      backgroundColor: $r('app.color.surface_color'),
      onDisappear: () => {
        this.showCameraSelector = false;
      }
    })
  }

  @Builder
  EquipmentCard(item: MyEquipmentItem) {
    Row() {
      // 器材图片
      if (item.cameraDataItem) {
        Image($rawfile(cameraDataJsonService.getCameraImagePath(item.cameraDataItem)))
          .width(80)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.foreground'))
      } else {
        Image($r('app.media.foreground'))
          .width(80)
          .height(60)
          .borderRadius(8)
      }

      // 器材信息
      Column() {
        Text(item.equipmentName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 4 })

        Text(`${item.brand} · ${item.model}`)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          if (item.transactions && item.transactions.length > 0) {
            Text(item.transactions[item.transactions.length - 1].type === 'buy' ? '买入' : '卖出')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor(item.transactions[item.transactions.length - 1].type === 'buy' ? '#4CAF50' : '#FF5722')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(4)

            Blank()

            Text(item.transactions[item.transactions.length - 1].date)
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 删除按钮
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.icon_delete'))
          .width(20)
          .height(20)
          .fillColor('#FF5722')
      }
      .width(36)
      .height(36)
      .backgroundColor('rgba(255, 87, 34, 0.1)')
      .margin({ left: 8 })
      .onClick(() => {
        this.showDeleteConfirmDialog(item);
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }

  @Builder
  AddEquipmentSheet() {
    Column() {
      Text('添加器材')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      Column() {
        // 选择器材
        Row() {
          Text('选择器材')
            .fontSize(16)
            .fontColor($r('app.color.primary_text_color'))
            .width(80)

          Button(this.selectedCamera ? `${this.selectedCamera.Brand} ${this.selectedCamera.Model}` : '点击选择器材')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor($r('app.color.divider_color'))
            .fontColor($r('app.color.primary_text_color'))
            .onClick(() => {
              this.showCameraSelector = true;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(VerticalAlign.Center)

        // 交易类型
        Row() {
          Text('交易类型')
            .fontSize(16)
            .fontColor($r('app.color.primary_text_color'))
            .width(80)

          Row() {
            Button('买入')
              .width(60)
              .height(32)
              .fontSize(14)
              .backgroundColor(this.transactionType === 'buy' ? $r('app.color.brand_color') : $r('app.color.divider_color'))
              .fontColor(this.transactionType === 'buy' ? '#FFFFFF' : $r('app.color.primary_text_color'))
              .onClick(() => {
                this.transactionType = 'buy';
              })

            Button('卖出')
              .width(60)
              .height(32)
              .fontSize(14)
              .backgroundColor(this.transactionType === 'sell' ? $r('app.color.brand_color') : $r('app.color.divider_color'))
              .fontColor(this.transactionType === 'sell' ? '#FFFFFF' : $r('app.color.primary_text_color'))
              .margin({ left: 12 })
              .onClick(() => {
                this.transactionType = 'sell';
              })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(VerticalAlign.Center)

        // 交易日期
        Row() {
          Text('交易日期')
            .fontSize(16)
            .fontColor($r('app.color.primary_text_color'))
            .width(80)

          Button(this.transactionDate || '选择日期')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor($r('app.color.divider_color'))
            .fontColor($r('app.color.primary_text_color'))
            .onClick(() => {
              this.showDatePicker = true;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(VerticalAlign.Center)

        // 价格（可选）
        Row() {
          Text('价格')
            .fontSize(16)
            .fontColor($r('app.color.primary_text_color'))
            .width(80)

          TextInput({ text: this.transactionPrice, placeholder: '请输入价格（可选）' })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.transactionPrice = value;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(VerticalAlign.Center)

        // 备注（可选）
        Row() {
          Text('备注')
            .fontSize(16)
            .fontColor($r('app.color.primary_text_color'))
            .width(80)

          TextInput({ text: this.transactionNotes, placeholder: '请输入备注（可选）' })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .onChange((value: string) => {
              this.transactionNotes = value;
            })
        }
        .width('100%')
        .margin({ bottom: 24 })
        .alignItems(VerticalAlign.Center)

        // 操作按钮
        Row() {
          Button('取消')
            .width(100)
            .height(40)
            .fontSize(16)
            .backgroundColor($r('app.color.divider_color'))
            .fontColor($r('app.color.primary_text_color'))
            .onClick(() => {
              this.showAddSheet = false;
              this.resetForm();
            })

          Blank()

          Button('确定')
            .width(100)
            .height(40)
            .fontSize(16)
            .backgroundColor($r('app.color.brand_color'))
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.addEquipment();
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DatePickerSheet() {
    Column() {
      Column() {
        Text('选择日期')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ top: 20, bottom: 20 })

        DatePicker({
          start: new Date('1990-1-1'),
          end: new Date(),
          selected: this.transactionDate ? new Date(this.transactionDate) : new Date()
        })
          .onChange((value: DatePickerResult) => {
            if (value.year && value.month !== undefined && value.day) {
              this.transactionDate = `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
            }
          })

        Row() {
          Button('取消')
            .width(100)
            .height(40)
            .fontSize(16)
            .backgroundColor($r('app.color.divider_color'))
            .fontColor($r('app.color.primary_text_color'))
            .onClick(() => {
              this.showDatePicker = false;
            })

          Blank()

          Button('确定')
            .width(100)
            .height(40)
            .fontSize(16)
            .backgroundColor($r('app.color.brand_color'))
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.showDatePicker = false;
            })
        }
        .width('100%')
        .margin({ top: 20 })
      }
      .width('90%')
      .constraintSize({ maxWidth: 400 })
      .padding(24)
      .backgroundColor($r('app.color.surface_color'))
      .borderRadius(12)
      .shadow({ radius: 8, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
  }

  @Builder
  CameraSelectorSheet() {
    Column() {
      Text('选择器材')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      List() {
        ForEach(this.cameraList, (camera: CameraDataItem) => {
          ListItem() {
            Row() {
              Image($rawfile(cameraDataJsonService.getCameraImagePath(camera)))
                .width(60)
                .height(45)
                .borderRadius(6)
                .objectFit(ImageFit.Cover)
                .alt($r('app.media.foreground'))

              Column() {
                Text(`${camera.Brand} ${camera.Model}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .margin({ bottom: 4 })

                Text(camera.SensorType || '')
                  .fontSize(14)
                  .fontColor($r('app.color.secondary_text_color'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .layoutWeight(1)
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.card_background_color'))
            .borderRadius(8)
            .onClick(() => {
              this.selectedCamera = camera;
              this.showCameraSelector = false;
            })
          }
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
  }
}