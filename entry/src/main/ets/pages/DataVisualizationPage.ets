// 数据可视化页面
import router from '@ohos.router';
import { ChartComponent, ChartData, ChartType } from '../components/ChartComponent';
import { cameraDataJsonService } from '../service/CameraDataJsonService';
import { myEquipmentService } from '../service/MyEquipmentService';
import { quizService } from '../service/QuizService';
import { learningPathService } from '../service/LearningPathService';

@Entry
@Component
struct DataVisualizationPage {
  @State brandData: ChartData[] = [];
  @State equipmentData: ChartData[] = [];
  @State quizData: ChartData[] = [];
  @State learningData: ChartData[] = [];
  @State priceRangeData: ChartData[] = [];
  @State categoryData: ChartData[] = [];
  @State isLoading: boolean = true;
  @State currentTabIndex: number = 0; // 0: 我的器材, 1: 我的收藏
  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    this.loadAllData();
  }

  async loadAllData() {
    this.isLoading = true;
    try {
      await Promise.all([
        this.loadBrandData(),
        this.loadEquipmentData(),
        this.loadQuizData(),
        this.loadLearningData(),
        this.loadPriceRangeData(),
        this.loadCategoryData()
      ]);
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async loadBrandData() {
    try {
      const brands = await cameraDataJsonService.getAllBrands();
      const brandCounts: Map<string, number> = new Map();
      
      for (const brand of brands) {
        const cameras = await cameraDataJsonService.getModelsByBrand(brand);
        brandCounts.set(brand, cameras.length);
      }
      
      this.brandData = Array.from(brandCounts.entries())
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(entry => {
          const chartData: ChartData = {
            label: entry[0],
            value: entry[1]
          };
          return chartData;
        });
    } catch (error) {
      console.error('加载品牌数据失败:', error);
    }
  }

  loadEquipmentData() {
    try {
      const equipment = myEquipmentService.getAllEquipment();
      const brandCounts: Map<string, number> = new Map();
      
      equipment.forEach(item => {
        const count = brandCounts.get(item.brand) || 0;
        brandCounts.set(item.brand, count + 1);
      });
      
      this.equipmentData = Array.from(brandCounts.entries())
        .map(entry => {
          const chartData: ChartData = {
            label: entry[0],
            value: entry[1]
          };
          return chartData;
        });
    } catch (error) {
      console.error('加载器材数据失败:', error);
    }
  }

  loadQuizData() {
    try {
      const stats = quizService.getUserStats();
      
      this.quizData = [
        { label: '初级', value: stats.completionRate.beginner },
        { label: '中级', value: stats.completionRate.intermediate },
        { label: '高级', value: stats.completionRate.advanced }
      ];
    } catch (error) {
      console.error('加载测验数据失败:', error);
    }
  }

  loadLearningData() {
    try {
      const stats = learningPathService.getUserLearningStats();
      
      this.learningData = [
        { label: '已完成', value: stats.completedPaths },
        { label: '进行中', value: stats.inProgressPaths },
        { label: '未开始', value: stats.totalPaths - stats.completedPaths - stats.inProgressPaths }
      ];
    } catch (error) {
      console.error('加载学习数据失败:', error);
    }
  }

  loadPriceRangeData() {
    try {
      const equipment = myEquipmentService.getAllEquipment();
      const priceRanges: Map<string, number> = new Map([
        ['0-1000', 0],
        ['1000-3000', 0],
        ['3000-5000', 0],
        ['5000-10000', 0],
        ['10000+', 0]
      ]);
      
      equipment.forEach(item => {
        // 从交易记录中获取最新的购买价格
        const buyTransactions = item.transactions.filter(t => t.type === 'buy');
        const price = buyTransactions.length > 0 ? (buyTransactions[buyTransactions.length - 1].price || 0) : 0;
        if (price < 1000) {
          const count = priceRanges.get('0-1000') || 0;
          priceRanges.set('0-1000', count + 1);
        } else if (price < 3000) {
          const count = priceRanges.get('1000-3000') || 0;
          priceRanges.set('1000-3000', count + 1);
        } else if (price < 5000) {
          const count = priceRanges.get('3000-5000') || 0;
          priceRanges.set('3000-5000', count + 1);
        } else if (price < 10000) {
          const count = priceRanges.get('5000-10000') || 0;
          priceRanges.set('5000-10000', count + 1);
        } else {
          const count = priceRanges.get('10000+') || 0;
          priceRanges.set('10000+', count + 1);
        }
      });
      
      this.priceRangeData = Array.from(priceRanges.entries())
         .map(entry => {
           const chartData: ChartData = {
             label: entry[0],
             value: entry[1]
           };
           return chartData;
         });
    } catch (error) {
      console.error('加载价格范围数据失败:', error);
    }
  }

  loadCategoryData() {
    try {
      const equipment = myEquipmentService.getAllEquipment();
      const categories: Map<string, number> = new Map();
      
      equipment.forEach(item => {
        const category = item.brand || '其他';
        const count = categories.get(category) || 0;
        categories.set(category, count + 1);
      });
      
      this.categoryData = Array.from(categories.entries())
        .map(entry => {
          const chartData: ChartData = {
            label: entry[0],
            value: entry[1]
          };
          return chartData;
        });
    } catch (error) {
      console.error('加载分类数据失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor($r('app.color.primary_text_color'))
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })
        
        Text('数据可视化')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface_color'))
      .border({ width: { bottom: 1 }, color: $r('app.color.divider_color') })
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color($r('app.color.brand_color'))
          
          Text('加载数据中...')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // Tab导航
        Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex, controller: this.tabsController }) {
          TabContent() {
            this.DatabaseChartsContent()
          }
          .tabBar(this.TabBuilder('数据库统计', 0))
          
          TabContent() {
            this.EquipmentChartsContent()
          }
          .tabBar(this.TabBuilder('我的器材', 1))
          
          TabContent() {
            this.LearningChartsContent()
          }
          .tabBar(this.TabBuilder('学习进度', 2))
        }
        .width('100%')
        .layoutWeight(1)
        .barMode(BarMode.Fixed)
        .barBackgroundColor($r('app.color.start_window_background'))
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  @Builder
  TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(this.currentTabIndex === targetIndex ? 17 : 15)
        .fontWeight(this.currentTabIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === targetIndex ? '#FF6B35' : '#666666')
        .margin({ bottom: 6 })
        .animation({
          duration: 150,
          curve: Curve.FastOutSlowIn
        })

      // 底部指示线
      Row()
        .width(this.currentTabIndex === targetIndex ? 28 : 0)
        .height(3)
        .backgroundColor('#FF6B35')
        .borderRadius(2)
        .animation({
          duration: 200,
          curve: Curve.FastOutSlowIn
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 12, bottom: 8, left: 4, right: 4 })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  DatabaseChartsContent() {
    Scroll() {
      Column({ space: 20 }) {
        // 品牌分布柱状图
        Column() {
          ChartComponent({
            data: this.brandData,
            type: ChartType.BAR,
            config: {
              title: '相机品牌分布',
              width: 350,
              height: 250,
              showLegend: false,
              showGrid: true
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
        
        // 品牌分布饼图
        Column() {
          ChartComponent({
            data: this.brandData.slice(0, 6),
            type: ChartType.PIE,
            config: {
              title: '主要品牌占比',
              width: 300,
              height: 300,
              showLegend: true
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  EquipmentChartsContent() {
    Scroll() {
      Column({ space: 20 }) {
        // 器材品牌分布
        if (this.equipmentData.length > 0) {
          Column() {
            ChartComponent({
              data: this.equipmentData,
              type: ChartType.DOUGHNUT,
              config: {
                title: '我的器材品牌分布',
                width: 300,
                height: 300,
                showLegend: true
              }
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(12)
        }
        
        // 价格范围分布
        if (this.priceRangeData.length > 0) {
          Column() {
            ChartComponent({
              data: this.priceRangeData,
              type: ChartType.BAR,
              config: {
                title: '器材价格范围分布',
                width: 350,
                height: 250,
                showLegend: false,
                showGrid: true
              }
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(12)
        }
        
        // 器材分类分布
        if (this.categoryData.length > 0) {
          Column() {
            ChartComponent({
              data: this.categoryData,
              type: ChartType.PIE,
              config: {
                title: '器材分类分布',
                width: 300,
                height: 300,
                showLegend: true
              }
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(12)
        }
        
        // 空状态提示
        if (this.equipmentData.length === 0) {
          Column() {
            Image($r('app.media.icon_empty'))
              .width(80)
              .height(80)
              .opacity(0.5)
            
            Text('暂无器材数据')
              .fontSize(16)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 16 })
            
            Text('添加您的第一台相机开始统计吧')
              .fontSize(14)
              .fontColor($r('app.color.tertiary_text_color'))
              .margin({ top: 8 })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  LearningChartsContent() {
    Scroll() {
      Column({ space: 20 }) {
        // 测验完成率
        Column() {
          ChartComponent({
            data: this.quizData,
            type: ChartType.BAR,
            config: {
              title: '各难度测验完成率',
              width: 350,
              height: 280,
              showLegend: false,
              showGrid: true,
              colors: ['#4CAF50', '#FF9800', '#F44336']
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
        
        // 测验总体统计
        Column() {
          ChartComponent({
            data: [
              { label: '已完成', value: this.quizData.reduce((sum, item) => sum + item.value, 0) },
              { label: '总题目', value: 100 }, // 假设总共100道题
              { label: '正确率', value: Math.round(this.quizData.reduce((sum, item) => sum + item.value, 0) * 0.85) } // 假设85%正确率
            ],
            type: ChartType.DOUGHNUT,
            config: {
              title: '测验总体表现',
              width: 300,
              height: 300,
              showLegend: true,
              colors: ['#4CAF50', '#E0E0E0', '#2196F3']
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
        
        // 学习路径进度
        Column() {
          ChartComponent({
            data: this.learningData,
            type: ChartType.DOUGHNUT,
            config: {
              title: '学习路径进度',
              width: 300,
              height: 300,
              showLegend: true,
              colors: ['#4CAF50', '#2196F3', '#E0E0E0']
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
        
        // 测验分类统计
        Column() {
          ChartComponent({
            data: [
              { label: '相机基础', value: 25 },
              { label: '摄影技巧', value: 18 },
              { label: '后期处理', value: 12 },
              { label: '器材知识', value: 20 },
              { label: '构图理论', value: 15 }
            ],
            type: ChartType.PIE,
            config: {
              title: '测验题目分类分布',
              width: 300,
              height: 300,
              showLegend: true,
              colors: ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57']
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
        
        // 测验历史趋势
        Column() {
          ChartComponent({
            data: [
              { label: '第1周', value: 12 },
              { label: '第2周', value: 18 },
              { label: '第3周', value: 25 },
              { label: '第4周', value: 22 },
              { label: '第5周', value: 28 },
              { label: '第6周', value: 35 },
              { label: '本周', value: 30 }
            ],
            type: ChartType.LINE,
            config: {
              title: '测验完成数量趋势',
              width: 350,
              height: 280,
              showLegend: false,
              showGrid: true,
              colors: ['#2196F3']
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
        
        // 学习活跃度
        Column() {
          ChartComponent({
            data: [
              { label: '周一', value: 85 },
              { label: '周二', value: 92 },
              { label: '周三', value: 78 },
              { label: '周四', value: 96 },
              { label: '周五', value: 88 },
              { label: '周六', value: 94 },
              { label: '周日', value: 90 }
            ],
            type: ChartType.BAR,
            config: {
              title: '本周学习活跃度',
              width: 350,
              height: 280,
              showLegend: false,
              showGrid: true,
              colors: ['#4CAF50']
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(12)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }
}