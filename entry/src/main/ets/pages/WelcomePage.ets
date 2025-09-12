import router from '@ohos.router';
import { myEquipmentService } from '../service/MyEquipmentService';
import { favoriteService } from '../service/FavoriteService';
import { cameraDataJsonService } from '../service/CameraDataJsonService';

@Component
export struct WelcomePage {
  @State totalCameras: number = 0;
  @State totalBrands: number = 0;
  @State myEquipmentCount: number = 0;
  @State favoritesCount: number = 0;
  @State isLoading: boolean = true;
  @State currentTime: string = '';
  @State greeting: string = '';

  aboutToAppear() {
    this.loadStatistics();
    this.updateTimeAndGreeting();
    // 每分钟更新一次时间
    setInterval((): void => {
      this.updateTimeAndGreeting();
    }, 60000);
  }

  private async loadStatistics() {
    try {
      // 加载相机数据统计
      const cameras = await cameraDataJsonService.getAllCameras();
      this.totalCameras = cameras.length;

      // 统计品牌数量
      const brands = new Set(cameras.map(camera => camera.Brand));
      this.totalBrands = brands.size;

      // 加载我的器材数量
      const equipment = myEquipmentService.getAllEquipment();
      this.myEquipmentCount = equipment.length;

      // 加载收藏数量
      const favorites = favoriteService.getFavorites();
      this.favoritesCount = favorites.length;

      this.isLoading = false;
    } catch (error) {
      console.error('加载统计数据失败:', error);
      this.isLoading = false;
    }
  }

  private updateTimeAndGreeting() {
    const now = new Date();
    const hour = now.getHours();

    // 更新时间
    this.currentTime = now.toLocaleTimeString('zh-CN', {
      hour: '2-digit',
      minute: '2-digit'
    });

    // 更新问候语
    if (hour < 6) {
      this.greeting = '夜深了，注意休息';
    } else if (hour < 12) {
      this.greeting = '早上好';
    } else if (hour < 18) {
      this.greeting = '下午好';
    } else {
      this.greeting = '晚上好';
    }
  }

  private navigateToDatabase() {
    router.pushUrl({
      url: 'pages/HomePage',
    });
  }

  private navigateToKnowledge() {
    AppStorage.setOrCreate('switchToTab', 1);
  }

  private navigateToComparison() {
    AppStorage.setOrCreate('switchToTab', 2);
  }

  private navigateToMyEquipment() {
    AppStorage.setOrCreate('switchToTab', 4);
  }

  private navigateToSetting() {
    router.pushUrl({
      url: 'pages/SettingPage'
    }).catch((_error: Error) => {
    });
  }

  private navigateToDataVisualization() {
    router.pushUrl({
      url: 'pages/DataVisualizationPage'
    }).catch((_error: Error) => {
    });
  }

  private navigateToShootingSimulator() {
    router.pushUrl({
      url: 'pages/ShootingSimulatorPage'
    }).catch((_error: Error) => {
    });
  }

  navigateToSamplePage(): void {
    AppStorage.setOrCreate('switchToTab', 3);
  }

  build() {
    Column() {
      // 顶部状态栏
      Row() {
        Column() {
          Text('数码回忆')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
          Text('管理、探索与学习您的数码装备')
            .fontSize(16)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // setting按钮
        Button() {
          Image($r('app.media.icon_settings'))
            .width(24)
            .height(24)
            .fillColor($r('app.color.secondary_text_color'))
        }
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(20)
        .onClick((): void => this.navigateToSetting())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 10 })

      // 可滚动内容区域
      Scroll() {
        Column() {
          // 统计卡片区域
          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#007AFF')
              Text('加载中...')
                .fontSize(16)
                .fontColor($r('app.color.secondary_text_color'))
                .margin({ left: 12 })
            }
            .justifyContent(FlexAlign.Center)
            .margin({ top: 40, bottom: 40 })
          } else {
            // 统计数据网格
            Grid() {
              GridItem() {
                this.StatisticCard('相机数据库', this.totalCameras.toString(), '款相机', '#FF6B6B', (): void => {
                  this.navigateToDatabase()
                })
              }

              GridItem() {
                this.StatisticCard('品牌覆盖', this.totalBrands.toString(), '个品牌', '#4ECDC4', (): void => {
                  this.navigateToDatabase()
                })
              }

              GridItem() {
                this.StatisticCard('我的器材', this.myEquipmentCount.toString(), '台设备', '#45B7D1', (): void => {
                  AppStorage.setOrCreate('switchToTab', 4);
                })
              }

              GridItem() {
                this.StatisticCard('我的收藏', this.favoritesCount.toString(), '个收藏', '#96CEB4', (): void => {
                  AppStorage.setOrCreate('switchToTab', 4);
                })
              }
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(16)
            .rowsGap(16)
            .width('100%')
            .height(200)
            .margin({top: 20})
            .padding({ left: 20, right: 20, })
          }

          // 功能导航区域
          Column() {
            Text('功能导航')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_text_color'))
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 20 })

            // 主要功能卡片
            Column({ space: 12 }) {
              this.FeatureCard('相机数据库', '浏览和搜索相机信息', '#FF6B6B', $r('app.media.icon_camera'),
                (): void => this.navigateToDatabase())

              this.FeatureCard('摄影知识库', '学习摄影技巧和知识', '#4ECDC4', $r('app.media.icon_knowledge'),
                (): void => this.navigateToKnowledge())

              this.FeatureCard('器材对比', '专业的相机参数对比', '#45B7D1', $r('app.media.icon_compare'),
                (): void => this.navigateToComparison())

              this.FeatureCard('我的器材', '管理您的摄影设备', '#96CEB4', $r('app.media.ic_mine'),
                (): void => this.navigateToMyEquipment())

              // 特色功能
              this.FeatureCard('数据可视化', '查看统计图表和数据分析', '#9C27B0', $r('app.media.icon_gallery'),
                (): void => this.navigateToDataVisualization())

              this.FeatureCard('样片库', '查看不同设备拍摄的绝美样张', '#eeC760', $r('app.media.icon_search'),
                (): void => this.navigateToSamplePage())

              // this.FeatureCard('拍摄模拟器', '模拟不同参数的拍摄效果', '#F7B731', $r('app.media.icon_eye'),
              //   (): void => this.navigateToShootingSimulator())
            }
            .margin({ bottom: 32 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 30 })
        }
        .width('100%')
        .padding({ left: 0, right: 0 })
      }
      .width('100%')
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_color'))
    }
  }

  @Builder
  StatisticCard(title: string, value: string, unit: string, color: string, onClick?: () => void): void {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 8 })
      
      Row() {
        Text(value)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
        
        Text(unit)
          .fontSize(12)
          .fontColor($r('app.color.tertiary_text_color'))
          .margin({ left: 4, top: 8 })
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: $r('app.color.shadow_color'),
      offsetX: 0,
      offsetY: 2
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  @Builder
  FeatureCard(title: string, description: string, color: string, icon: Resource, onClick: () => void): void {
    Row() {
      // 图标区域
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }
      .width(48)
      .height(48)
      .backgroundColor(color)
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })
      
      // 文字区域
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 4 })
        
        Text(description)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 箭头
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
      radius: 6,
      color: $r('app.color.shadow_color'),
      offsetX: 0,
      offsetY: 1
    })
    .onClick((): void => onClick())
  }
}