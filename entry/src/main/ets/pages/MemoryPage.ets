import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { memoryDataService, MemoryCamera } from '../service/MemoryDataService';
import { componentSnapshot } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { ScreenshotUtil } from '../utils/ScreenshotUtil';

@Component
@Preview
export struct MemoryPage {
  @State memoryCameras: MemoryCamera[] = [];
  @State isShowingShareSheet: boolean = false;
  @State isShowingCameraSelector: boolean = false;
  @State availableCameras: CameraDataItem[] = [];
  @State selectedCameras: Set<string> = new Set(); // 存储选中的相机ID

  async aboutToAppear() {
    // 异步初始化，避免阻塞主线程
    this.initializeData();
  }
  
  // 异步初始化数据
  private async initializeData() {
    try {
      // 初始化数据存储服务
      await memoryDataService.init();
      
      // 加载回忆相机数据
      await this.loadMemoryCameras();
      
      // 加载可用相机数据
      await this.loadAvailableCameras();
    } catch (error) {
      console.error('数据初始化失败:', error);
    }
  }

  // 加载回忆相机数据
  private async loadMemoryCameras() {
    try {
      this.memoryCameras = await memoryDataService.loadMemoryCameras();
    } catch (error) {
      console.error('加载回忆数据失败:', error);
    }
  }

  // 加载可用相机数据
  private async loadAvailableCameras() {
    try {
      this.availableCameras = await cameraDataJsonService.getAllCameras();
    } catch (error) {
      console.error('加载可用相机数据失败:', error);
    }
  }

  // 为CameraDataItem生成唯一ID
  private generateCameraId(camera: CameraDataItem): string {
    return `${camera.Brand}_${camera.Model}_${camera.Year}`.replace(/\s+/g, '_');
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
        // 空状态 - 只有在没有回忆时才显示添加入口
        Column() {
          Image($r('app.media.icon_memory'))
            .width(80)
            .height(80)
            .fillColor('#BDC3C7')
            .margin({ bottom: 20 })
          
          Text('您还没有回忆')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 10 })
          
          Text('创建你曾用过的相机回忆吧')
            .fontSize(16)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ bottom: 30 })
          
          // 添加回忆按钮
          Button('添加回忆')
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
              this.isShowingCameraSelector = true;
            })
          
          Text('从相机列表中选择您使用过的相机')
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
              Button({ type: ButtonType.Circle }) {
                Image($r('app.media.icon_share'))
                  .width(20)
                  .height(20)
                  .fillColor('#FFFFFF')
              }
              .width(40)
              .height(40)
              .backgroundColor('#007AFF')
              .border({ width: 1, color: '#0056CC' })
              .onClick(() => {
                this.shareMemory();
              })
              
              // 删除按钮
              Button({ type: ButtonType.Circle }) {
                Image($r('app.media.icon_delete'))
                  .width(20)
                  .height(20)
                  .fillColor('#FFFFFF')
              }
              .width(40)
              .height(40)
              .backgroundColor('#E74C3C')
              .border({ width: 1, color: '#C0392B' })
              .onClick(() => {
                this.showDeleteRouteConfirmDialog();
              })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.surface_color'))



          // 时间线列表 - 使用Scroll包装以支持完整截图
          Scroll() {
            Column({ space: 8 }) {
              ForEach([...this.memoryCameras].sort((a, b) => new Date(b.addedDate).getTime() - new Date(a.addedDate).getTime()), (memory: MemoryCamera, index: number) => {
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
    .bindSheet($$this.isShowingCameraSelector, this.CameraSelectorSheet(), {
      height: '80%',
      dragBar: true,
      showClose: false,
      backgroundColor: $r('app.color.surface_color'),
      onDisappear: () => {
        this.isShowingCameraSelector = false;
      }
    })
  }

  @Builder
  CameraSelectorSheet() {
    Column({ space: 16 }) {
      // 标题
      Text('选择相机')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 10 })
        .textAlign(TextAlign.Center)
        .width('100%')

      // 相机列表
      List({ space: 12 }) {
        ForEach(this.availableCameras, (camera: CameraDataItem) => {
          ListItem() {
            this.CameraSelectItem(camera)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      
      // 底部操作栏
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(16)
          .fontColor($r('app.color.primary_text_color'))
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.selectedCameras.clear();
            this.isShowingCameraSelector = false;
          })
        
        Button(`添加选中 (${this.selectedCameras.size})`)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius(8)
          .layoutWeight(1)
          .enabled(this.selectedCameras.size > 0)
          .onClick(() => {
            this.addSelectedCamerasToMemory();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CameraSelectItem(camera: CameraDataItem) {
    Row({ space: 12 }) {
      // 复选框
      Checkbox({ name: this.generateCameraId(camera), group: 'cameraGroup' })
        .select(this.selectedCameras.has(this.generateCameraId(camera)))
        .selectedColor($r('app.color.brand_color'))
        .onChange((value: boolean) => {
          const cameraId = this.generateCameraId(camera);
          if (value) {
            this.selectedCameras.add(cameraId);
          } else {
            this.selectedCameras.delete(cameraId);
          }
        })
      
      // 相机图片
      Image($rawfile(cameraDataJsonService.getCameraImagePath(camera)))
        .width(60)
        .height(60)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
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
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.selectedCameras.has(this.generateCameraId(camera)) ? 
      'rgba(255, 107, 107, 0.1)' : $r('app.color.surface_color'))
    .borderRadius(12)
    .border({
      width: this.selectedCameras.has(this.generateCameraId(camera)) ? 2 : 0,
      color: $r('app.color.brand_color')
    })
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      const cameraId = this.generateCameraId(camera);
      if (this.selectedCameras.has(cameraId)) {
        this.selectedCameras.delete(cameraId);
      } else {
        this.selectedCameras.add(cameraId);
      }
    })
  }

  // 添加相机到回忆
  private async addCameraToMemory(camera: CameraDataItem) {
    try {
      const memoryCamera: MemoryCamera = {
        id: this.generateCameraId(camera),
        camera: camera,
        addedDate: new Date().toISOString()
      };

      await memoryDataService.addMemoryCamera(memoryCamera);
      await this.loadMemoryCameras();
      
      this.isShowingCameraSelector = false;
      
      promptAction.showToast({
        message: `已添加 ${camera.Brand} ${camera.Model} 到回忆`,
        duration: 2000
      });
    } catch (error) {
      console.error('添加相机失败:', error);
      promptAction.showToast({
        message: '添加失败，请重试',
        duration: 2000
      });
    }
  }

  // 批量添加选中的相机到回忆
  private async addSelectedCamerasToMemory() {
    if (this.selectedCameras.size === 0) {
      return;
    }

    try {
      const selectedCameraList = this.availableCameras.filter(camera => 
        this.selectedCameras.has(this.generateCameraId(camera))
      );

      for (const camera of selectedCameraList) {
        const memoryCamera: MemoryCamera = {
          id: this.generateCameraId(camera),
          camera: camera,
          addedDate: new Date().toISOString()
        };
        await memoryDataService.addMemoryCamera(memoryCamera);
      }

      await this.loadMemoryCameras();
      
      this.selectedCameras.clear();
      this.isShowingCameraSelector = false;
      
      promptAction.showToast({
        message: `已添加 ${selectedCameraList.length} 台相机到回忆`,
        duration: 2000
      });
    } catch (error) {
      console.error('添加相机到回忆失败:', error);
      promptAction.showToast({
        message: '添加失败，请重试',
        duration: 2000
      });
    }
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
            .width(150)
            .height(112)
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
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C3E50')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Center)
              .shadow({ 
                radius: 2, 
                color: 'rgba(0, 0, 0, 0.1)', 
                offsetX: 0, 
                offsetY: 1 
              })
            
            Text(memory.addedDate)
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
        .width(170)
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
          router.pushUrl({
            url: 'pages/CameraDetail',
            params: {
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

        Button('删除')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#E74C3C')
          .borderRadius(8)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })

      // 时间线列表内容
      Column({ space: 8 }) {
        ForEach([...this.memoryCameras].sort((a, b) => new Date(b.addedDate).getTime() - new Date(a.addedDate).getTime()), (memory: MemoryCamera, index: number) => {
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
        ForEach([...this.memoryCameras].sort((a, b) => new Date(b.addedDate).getTime() - new Date(a.addedDate).getTime()), (memory: MemoryCamera, index: number) => {
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