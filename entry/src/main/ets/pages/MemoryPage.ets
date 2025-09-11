import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { MemoryCamera, memoryDataService } from '../service/MemoryDataService';
import { image } from '@kit.ImageKit';
import { ScreenshotUtil } from '../utils/ScreenshotUtil';
import { MyEquipmentItem } from '../model/MyEquipmentModel';
import { myEquipmentService } from '../service/MyEquipmentService';
import { Camera, CameraCategory, SensorFormat } from '../model/Camera';

@Entry
@Component
export struct MemoryPage {
  @State memoryCameras: MemoryCamera[] = [];
  @State isShowingShareSheet: boolean = false;
  @State myEquipmentList: MyEquipmentItem[] = [];

  async aboutToAppear() {
    // 异步初始化，避免阻塞主线程
    this.initializeData();
  }
  
  // 异步初始化数据
  private async initializeData() {
    try {
      // 初始化数据存储服务
      await memoryDataService.init();
      
      // 加载我的器材数据
      this.loadMyEquipment();
      
      // 从我的器材生成回忆数据
      await this.generateMemoriesFromEquipment();
    } catch (error) {
      console.error('数据初始化失败:', error);
    }
  }

  // 加载我的器材数据
  private loadMyEquipment() {
    try {
      this.myEquipmentList = myEquipmentService.getAllEquipment();
    } catch (error) {
      console.error('加载我的器材数据失败:', error);
    }
  }

  // 从我的器材生成回忆数据
  private async generateMemoriesFromEquipment() {
    try {
      if (this.myEquipmentList.length === 0) {
        this.memoryCameras = [];
        return;
      }

      const memories: MemoryCamera[] = [];
      for (const equipment of this.myEquipmentList) {
        if (equipment.cameraDataItem && equipment.transactions.length > 0) {
          // 使用最早的交易日期作为回忆日期
          const earliestTransaction = equipment.transactions.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())[0];
          const memoryCamera: MemoryCamera = {
            id: this.generateCameraId(equipment.cameraDataItem),
            camera: equipment.cameraDataItem,
            addedDate: earliestTransaction.date,
            description: `我的${equipment.brand} ${equipment.model}`
          };
          memories.push(memoryCamera);
        }
      }

      // 按添加时间排序
      memories.sort((a, b) => new Date(a.addedDate).getTime() - new Date(b.addedDate).getTime());
      this.memoryCameras = memories;
      
      // 保存到回忆服务
      await this.saveMemoryCameras();
    } catch (error) {
      console.error('生成回忆数据失败:', error);
    }
  }

  // 为CameraDataItem生成唯一ID
  private generateCameraId(camera: CameraDataItem): string {
    return `${camera.Brand}_${camera.Model}_${camera.Year}`.replace(/\s+/g, '_');
  }

  // 格式化日期显示
  private formatDate(dateString: string): string {
    try {
      const date = new Date(dateString);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    } catch (error) {
      return dateString;
    }
  }



  // 保存回忆数据
  private async saveMemoryCameras() {
    try {
      await memoryDataService.saveMemoryCameras(this.memoryCameras);
    } catch (error) {
      console.error('保存回忆数据失败:', error);
    }
  }

  // 分享功能
  private shareMemory() {
    this.isShowingShareSheet = true;
  }

  // 微信分享（暂未实现）
  private shareToWechat() {
    promptAction.showToast({
      message: '开发中，尽请期待～',
      duration: 2000
    });
    this.isShowingShareSheet = false;
  }

  // 保存为本地图片 - 使用优化的长截图方法
  private async saveAsImage() {
    try {
      console.log('MemoryPage', '开始保存长截图');
      
      // 使用优化的长截图方法
       const pixelMap: image.PixelMap = await ScreenshotUtil.captureLongScreenshotOptimized(() => {
         this.ScreenshotTimelineContent();
       });
       
       // 保存到相册
       const success: boolean = await ScreenshotUtil.savePixelMapToGallery(pixelMap);
      
      // 释放资源
       pixelMap.release();
       
       if (success) {
         console.log('MemoryPage', '长截图保存成功');
         promptAction.showToast({
           message: '图片已保存至相册',
           duration: 2000
         });
       } else {
         throw new Error('保存失败');
       }
      
    } catch (error) {
      console.error('MemoryPage', '长截图保存失败', error?.toString() || 'Unknown error');
      promptAction.showToast({
        message: '图片保存失败: ' + (error as Error).message,
        duration: 2000
      });
    }
    
    this.isShowingShareSheet = false;
  }



  // 显示删除路线确认对话框
  private showDeleteRouteConfirmDialog() {
    AlertDialog.show({
      title: '删除回忆路线',
      message: `确定要删除整个回忆路线吗？\n这将删除所有 ${this.memoryCameras.length} 台相机的回忆记录。`,
      primaryButton: {
        value: '取消',
        fontColor: '#007AFF',
        backgroundColor: '#FFFFFF',
        action: () => {
          // 取消操作
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FFFFFF',
        backgroundColor: '#E74C3C',
        action: () => {
          this.deleteMemoryRoute();
        }
      }
    });
  }

  // 删除整个回忆路线
  private async deleteMemoryRoute() {
    this.memoryCameras = [];
    await this.saveMemoryCameras();
    promptAction.showToast({
      message: '已删除回忆路线',
      duration: 1500
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
      category: this.mapCameraType(''),
      sensorFormat: this.mapSensorFormat('')
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

        Text('相机回忆')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color')).align(Alignment.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .backgroundColor($r('app.color.surface_color'))
      .justifyContent(FlexAlign.Center)

      if (this.memoryCameras.length === 0) {
        // 空状态 - 提示用户去我的器材页面添加器材
        Column() {
          Image($r('app.media.icon_memory'))
            .width(80)
            .height(80)
            .fillColor('#BDC3C7')
            .margin({ bottom: 20 })
          
          Text('您还没有器材回忆')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 10 })
          
          Text('请先在"我的器材"页面添加您的相机')
            .fontSize(16)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ bottom: 30 })
          
          // 跳转到我的器材页面按钮
          Button('去添加器材')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.brand_color'))
            .borderRadius(12)
            .padding({ left: 32, right: 32, top: 12, bottom: 12 })
            .margin({ bottom: 20 })
            .shadow({ 
              radius: 8, 
              color: $r('app.color.brand_color_light'), 
              offsetX: 0, 
              offsetY: 4 
            })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Index' });
            })
          
          Text('添加器材后，这里将自动生成您的相机回忆')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color'))
      } else {
        // 回忆时间线
        Column() {
          // 标题栏
          Row() {
            Column() {
              Text(`我的相机回忆路线`)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.primary_text_color'))
              
              Text(`${this.memoryCameras.length} 台相机`)
                .fontSize(14)
                .fontColor($r('app.color.secondary_text_color'))
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            
            Blank()
            
            // 操作按钮组
            Row({ space: 8 }) {
              // 分享按钮
              Column({ space: 4 }) {
                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.icon_share'))
                    .width(20)
                    .height(20)
                    .fillColor('#FFFFFF')
                }
                .width(40)
                .height(40)
                .backgroundColor($r('app.color.brand_color'))
                .onClick(() => {
                  this.shareMemory();
                })
                
                Text('分享')
                  .fontSize(12)
                  .fontColor($r('app.color.secondary_text_color'))
                  .textAlign(TextAlign.Center)
              }
              .alignItems(HorizontalAlign.Center)
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.surface_color'))



          // 时间线列表 - 使用Scroll包装以支持完整截图
          Scroll() {
            Column({ space: 8 }) {
              ForEach([...this.memoryCameras].sort((a, b) => new Date(a.addedDate).getTime() - new Date(b.addedDate).getTime()), (memory: MemoryCamera, index: number) => {
                this.MemoryTimelineItem(memory, index)
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
          .id('scrollContainer')
          .width('100%')
          .layoutWeight(1)
          .backgroundColor($r('app.color.background_color'))
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .layoutWeight(1)
        .bindSheet(this.isShowingShareSheet, this.ShareSheet(), {
          height: 200,
          showClose: false,
          onWillDismiss: ((dismissSheetAction: DismissSheetAction) => {
            this.isShowingShareSheet = false;
            dismissSheetAction.dismiss();
          }),
        })
      }
    }
    .id('memoryPageContainer')
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }





   // 回忆时间线项目 - 自定义路线图
   @Builder
   MemoryTimelineItem(memory: MemoryCamera, index: number) {
    Column() {
      // 路线节点和连接线
      Row() {
        // 左侧路线轨道
        Column() {
          // 上方连接线
          if (index > 0) {
            Canvas(new CanvasRenderingContext2D(new RenderingContextSettings(true)))
              .width(6)
              .height(45)
              .onReady(() => {
                const ctx = new CanvasRenderingContext2D(new RenderingContextSettings(true));
                // 更丰富的渐变连接线
                const gradient = ctx.createLinearGradient(0, 0, 0, 45);
                gradient.addColorStop(0, '#FF6B6B');
                gradient.addColorStop(0.3, '#4ECDC4');
                gradient.addColorStop(0.7, '#45B7D1');
                gradient.addColorStop(1, '#96CEB4');
                ctx.strokeStyle = gradient;
                ctx.lineWidth = 6;
                ctx.lineCap = 'round';
                ctx.beginPath();
                ctx.moveTo(3, 0);
                ctx.lineTo(3, 45);
                ctx.stroke();
              })
              .animation({
                duration: 1000,
                curve: Curve.EaseInOut,
                delay: index * 200,
                iterations: 1,
                playMode: PlayMode.Normal
              })
          }
          
          // 路线节点圆圈
          Stack() {
            // 外圈光晕效果
            Circle()
              .width(44)
              .height(44)
              .fill('rgba(255, 107, 107, 0.2)')
              .blur(8)
            
            // 主要外圈
            Circle()
              .width(36)
              .height(36)
              .fill('#FF6B6B')
              .shadow({ 
                radius: 12, 
                color: 'rgba(255, 107, 107, 0.4)', 
                offsetX: 0, 
                offsetY: 4 
              })
            
            // 内圈
            Circle()
              .width(28)
              .height(28)
              .fill('#FFFFFF')
              .shadow({ 
                radius: 4, 
                color: 'rgba(0, 0, 0, 0.1)', 
                offsetX: 0, 
                offsetY: 2 
              })
            
            // 路线编号
            Text(`${index + 1}`)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B6B')
          }
          .alignContent(Alignment.Center)
          .scale({ x: 0.8, y: 0.8 })
          .animation({
            duration: 800,
            curve: Curve.EaseInOut,
            delay: index * 150,
            iterations: 1,
            playMode: PlayMode.Normal
          })
          .onAppear(() => {
            animateTo({
              duration: 800,
              curve: Curve.EaseInOut,
              delay: index * 150
            }, () => {
              // 动画到正常大小
            })
          })
          

          
          // 下方连接线
          if (index < this.memoryCameras.length - 1) {
            Canvas()
              .width(6)
              .height(45)
              .onReady(() => {
                const context = new CanvasRenderingContext2D(new RenderingContextSettings(true));
                // 垂直虚线连接
                context.strokeStyle = '#FF6B6B';
                context.lineWidth = 3;
                context.lineCap = 'round';
                context.setLineDash([8, 4]); // 虚线样式
                context.beginPath();
                context.moveTo(3, 0);
                context.lineTo(3, 45);
                context.stroke();
              })
              .scale({ x: 0.8, y: 0.8 })
              .animation({
                duration: 1000,
                curve: Curve.EaseInOut,
                delay: index * 200 + 300,
                iterations: 1,
                playMode: PlayMode.Normal
              })
              .onAppear(() => {
                animateTo({
                  duration: 1000,
                  curve: Curve.EaseInOut,
                  delay: index * 200 + 300
                }, () => {
                  // 虚线缩放动画
                })
              })
          }
        }
        .alignItems(HorizontalAlign.Center)
        .width(40)
        
        // 连接线到相机卡片
        Canvas(new CanvasRenderingContext2D(new RenderingContextSettings(true)))
          .width(40)
          .height(6)

          .onReady(() => {
            const ctx = new CanvasRenderingContext2D(new RenderingContextSettings(true));
            // 渐变连接线
            const gradient = ctx.createLinearGradient(0, 0, 40, 0);
            gradient.addColorStop(0, '#FF6B6B');
            gradient.addColorStop(0.5, '#4ECDC4');
            gradient.addColorStop(1, '#45B7D1');
            ctx.strokeStyle = gradient;
            ctx.lineWidth = 4;
            ctx.lineCap = 'round';
            ctx.setLineDash([6, 3]);
            ctx.beginPath();
            ctx.moveTo(0, 3);
            ctx.lineTo(32, 3);
            ctx.stroke();
            
            // 更精美的箭头
            ctx.fillStyle = '#45B7D1';
            ctx.shadowColor = 'rgba(69, 183, 209, 0.4)';
            ctx.shadowBlur = 4;
            ctx.shadowOffsetX = 1;
            ctx.shadowOffsetY = 1;
            ctx.beginPath();
            ctx.moveTo(40, 3);
            ctx.lineTo(32, 0);
            ctx.lineTo(34, 3);
            ctx.lineTo(32, 6);
            ctx.closePath();
            ctx.fill();
          })
          .alignSelf(ItemAlign.Center)
          .opacity(0)
          .animation({
            duration: 600,
            curve: Curve.EaseOut,
            delay: index * 150 + 400,
            iterations: 1,
            playMode: PlayMode.Normal
          })
          .onAppear(() => {
            animateTo({
              duration: 600,
              curve: Curve.EaseOut,
              delay: index * 150 + 400
            }, () => {
              // 箭头淡入动画
            })
          })
        
        // 相机信息卡片
        Column({ space: 16 }) {
          // 相机图片
          Image($rawfile(cameraDataJsonService.getCameraImagePath(memory.camera)))
            .width(170)
            .height(127)
            .objectFit(ImageFit.Cover)
            .borderRadius(20)
            .alt($r('app.media.foreground'))
            .shadow({ 
              radius: 12, 
              color: 'rgba(0, 0, 0, 0.15)', 
              offsetX: 0, 
              offsetY: 6 
            })
            .border({ width: 3, color: 'rgba(255, 255, 255, 0.8)' })
          
          // 相机信息
          Column({ space: 8 }) {
            Text(`${memory.camera.Brand} ${memory.camera.Model}`)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C3E50')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Center)
              .shadow({ 
                radius: 2, 
                color: 'rgba(0, 0, 0, 0.1)', 
                offsetX: 0, 
                offsetY: 1 
              })
            
            Text(this.formatDate(memory.addedDate))
              .fontSize(13)
              .fontColor('#7F8C8D')
              .textAlign(TextAlign.Center)
              .opacity(0.8)
            
            // 路线标签
            Text(`第 ${index + 1} 站`)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#FF6B6B')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .borderRadius(12)
              .textAlign(TextAlign.Center)
              .shadow({ 
                radius: 6, 
                color: 'rgba(255, 107, 107, 0.3)', 
                offsetX: 0, 
                offsetY: 2 
              })
          }
          .width('100%')
        }
        .width(200)
        .padding(20)
        .backgroundColor('rgba(255, 255, 255, 0.95)')
        .borderRadius(24)
        .shadow({ 
          radius: 16, 
          color: 'rgba(0, 0, 0, 0.08)', 
          offsetX: 0, 
          offsetY: 8 
        })
        .border({ 
           width: 1, 
           color: 'rgba(255, 107, 107, 0.3)'
         })
        .scale({ x: 0.9, y: 0.9 })
        .animation({
          duration: 700,
          curve: Curve.EaseInOut,
          delay: index * 150 + 600,
          iterations: 1,
          playMode: PlayMode.Normal
        })
        .onAppear(() => {
          animateTo({
            duration: 700,
            curve: Curve.EaseInOut,
            delay: index * 150 + 600
          }, () => {
            // 卡片缩放动画
          })
        })
        .onClick(() => {
          // 将CameraDataItem转换为Camera对象
          const camera = this.convertCameraDataItemToCamera(memory.camera);
          
          router.pushUrl({
            url: 'pages/CameraDetail',
            params: {
              camera: camera,
              cameraDataItem: memory.camera
            }
          }).catch((error: Error) => {
            console.error('跳转到相机详情页面失败:', error.message);
          });
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 8, bottom: 8 })
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }





  // 分享弹窗
  @Builder
  ShareSheet() {
    Column() {
      Text('分享回忆')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 30 })
      
      Row({ space: 40 }) {
        // 微信分享
        Column({ space: 8 }) {
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.icon_wechat'))
              .width(32)
              .height(32)
              .fillColor('#FFFFFF')
          }
          .width(60)
          .height(60)
          .backgroundColor('#07C160')
          .onClick(() => {
            this.shareToWechat();
          })
          
          Text('微信分享')
            .fontSize(14)
            .fontColor($r('app.color.primary_text_color'))
        }
        .alignItems(HorizontalAlign.Center)
        
        // 保存图片 - 使用SaveButton安全控件
        Column({ space: 8 }) {
          SaveButton({
            icon: SaveIconStyle.FULL_FILLED, 
            buttonType: ButtonType.Circle
          })
            .width(60)
            .height(60)
            .onClick((event, result: SaveButtonOnClickResult) => {
              if (result == SaveButtonOnClickResult.SUCCESS) {
                this.saveAsImage();
              }
            })
          
          Text('保存图片')
            .fontSize(14)
            .fontColor($r('app.color.primary_text_color'))
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 20, right: 20, bottom: 30 })
    }
    .width('100%')
  }

  // 用于截图的完整页面内容（包含按钮）
  @Builder
  FullPageContent() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('相机回忆')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .align(Alignment.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .backgroundColor($r('app.color.surface_color'))
      .justifyContent(FlexAlign.Center)

      // 操作按钮组
      Row({ space: 12 }) {
        Button('分享')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#007AFF')
          .borderRadius(8)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })

      // 时间线列表内容
      Column({ space: 8 }) {
        ForEach([...this.memoryCameras].sort((a, b) => new Date(a.addedDate).getTime() - new Date(b.addedDate).getTime()), (memory: MemoryCamera, index: number) => {
          this.MemoryTimelineItem(memory, index)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .height(this.memoryCameras.length * 400 + 300)
    .backgroundColor($r('app.color.background_color'))
  }

  // 专门用于截图的时间线内容（不包含按钮）
  @Builder
  ScreenshotTimelineContent() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('相机回忆')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .align(Alignment.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor($r('app.color.surface_color'))
      .justifyContent(FlexAlign.Center)

      // 时间线列表内容
      Column({ space: 8 }) {
        ForEach([...this.memoryCameras].sort((a, b) => new Date(a.addedDate).getTime() - new Date(b.addedDate).getTime()), (memory: MemoryCamera, index: number) => {
          this.MemoryTimelineItem(memory, index)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .height(this.memoryCameras.length * 400 + 100) // 精确计算高度：每个项目400px + 标题和padding 100px
    .backgroundColor($r('app.color.background_color'))
  }
}