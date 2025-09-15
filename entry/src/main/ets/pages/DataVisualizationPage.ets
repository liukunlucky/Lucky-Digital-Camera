// 数据可视化页面
import router from '@ohos.router';
import { hmChart, ChartOptions, hmChartType } from '@wuyan/hm_chart';
import { cameraDataJsonService } from '../service/CameraDataJsonService';
import { myEquipmentService } from '../service/MyEquipmentService';
import { quizService } from '../service/QuizService';
import { learningPathService } from '../service/LearningPathService';

// 定义图表数据接口
interface ChartData {
  label: string;
  value: number;
}

interface ColorStep {
  offset: number;
  color: string;
}

interface TrendData {
  date: string;
  count: number;
}

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
  @State currentTabIndex: number = 0; // 0: 数据库统计, 1: 我的器材, 2: 学习进度
  private tabsController: TabsController = new TabsController();
  
  // ECharts 图表实例
  @State brandChart: hmChartType | null = null;
  @State equipmentChart: hmChartType | null = null;
  @State priceChart: hmChartType | null = null;
  @State learningChart: hmChartType | null = null;
  @State quizChart: hmChartType | null = null;
  @State trendChart: hmChartType | null = null;
  @State quizOverallChart: hmChartType | null = null;
  @State quizCategoryChart: hmChartType | null = null;
  @State quizTrendChart: hmChartType | null = null;
  @State learningActivityChart: hmChartType | null = null;

  aboutToAppear() {
    this.loadAllData();
  }

  // 生成测验完成率柱状图配置
  getQuizBarChartOptions(): ChartOptions {
    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: this.quizData.map(item => item.label),
        axisLabel: {
          fontSize: 12
        }
      },
      yAxis: {
        type: 'value',
        axisLabel: {
          fontSize: 12,
          formatter: '{value}%'
        }
      },
      series: [{
        name: '完成率',
        type: 'bar',
        data: this.quizData.map(item => item.value),
        itemStyle: {
          color: '#FFEAA7'
        },
        emphasis: {
          itemStyle: {
            color: '#FFEAA7'
          }
        }
      }]
    };
  }

  // 生成测验总体表现饼图配置
  getQuizOverallChartOptions(): ChartOptions {
    return {
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left',
        data: ['已完成', '进行中', '未开始']
      },
      series: [{
        name: '测验状态',
        type: 'pie',
        radius: ['40%', '70%'],
        data: [60, 25, 15],
        label: {
          show: true
        }
      }]
    };
  }

  // 生成学习路径进度饼图配置
  getLearningProgressChartOptions(): ChartOptions {
    const colors = ['#4ECDC4', '#FFE66D', '#FF6B6B'];
    return {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        left: 'left',
        data: this.learningData.map(item => item.label)
      },
      series: [{
        name: '学习进度',
        type: 'pie',
        radius: ['40%', '70%'],
        data: this.learningData.map(item => item.value)
      }]
    };
  }

  // 生成测验分类分布饼图配置
  getQuizCategoryChartOptions(): ChartOptions {
    const categoryData: ChartData[] = [
      { label: '基础理论', value: 25 },
      { label: '拍摄技巧', value: 30 },
      { label: '后期处理', value: 20 },
      { label: '器材知识', value: 15 },
      { label: '构图美学', value: 10 }
    ];
    const colors = ['#FF6B35', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'];
    
    return {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        left: 'left',
        data: categoryData.map(item => item.label)
      },
      series: [{
        name: '题目分类',
        type: 'pie',
        radius: ['0%', '70%'],
        data: categoryData.map(item => item.value)
      }]
    };
  }

  // 生成测验趋势折线图配置
  getQuizTrendChartOptions(): ChartOptions {
    const trendData: TrendData[] = [
      { date: '1月', count: 12 },
      { date: '2月', count: 19 },
      { date: '3月', count: 15 },
      { date: '4月', count: 25 },
      { date: '5月', count: 22 },
      { date: '6月', count: 30 }
    ];
    
    return {
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: trendData.map(item => item.date)
      },
      yAxis: {
        type: 'value'
      },
      series: [{
        name: '完成数量',
        type: 'line',
        data: trendData.map(item => item.count),
        itemStyle: {
          color: '#45B7D1'
        },
        lineStyle: {
          width: 3
        },
        smooth: true
      }]
    };
  }

  // 生成学习活跃度柱状图配置
  getLearningActivityChartOptions(): ChartOptions {
    return {
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '10%',
        right: '10%',
        bottom: '10%',
        top: '10%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
      },
      yAxis: {
        type: 'value'
      },
      series: [{
        name: '学习时长',
        type: 'bar',
        data: [45, 52, 38, 65, 42, 28, 35],
        itemStyle: {
          color: '#96CEB4'
        }
      }]
    };
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

  // 生成品牌柱状图配置
  getBrandBarChartOptions(): ChartOptions {
    return {
      title: {
        text: '',
        left: 'center',
        textStyle: {
          fontSize: 16,
          fontWeight: 'bold'
        }
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: this.brandData.map(item => item.label),
        axisLabel: {
          rotate: 45,
          fontSize: 12
        }
      },
      yAxis: {
        type: 'value',
        axisLabel: {
          fontSize: 12
        }
      },
      series: [{
        name: '相机数量',
        type: 'bar',
        data: this.brandData.map(item => item.value),
        itemStyle: {
          color: '#FF6B35'
        },
        emphasis: {
          itemStyle: {
            color: '#FF6B35'
          }
        }
      }]
    };
  }

  // 生成品牌饼图配置
  getBrandPieChartOptions(): ChartOptions {
    const colors = ['#FF6B35', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57', '#FF9FF3'];
    return {
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left',
        data: this.brandData.slice(0, 6).map(item => item.label)
      },
      series: [{
        name: '品牌分布',
        type: 'pie',
        radius: ['0%', '70%'],
        data: this.brandData.slice(0, 6).map(item => item.value)
      }]
    };
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
          Text('相机品牌分布')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
            .alignSelf(ItemAlign.Start)
          
          hmChart({
            Options: this.getBrandBarChartOptions(),
            myChart: this.brandChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        
        // 品牌分布饼图
        Column() {
          Text('主要品牌占比')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
            .alignSelf(ItemAlign.Start)
          
          hmChart({
            Options: this.getBrandPieChartOptions(),
            myChart: this.brandChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }



  // 生成器材饼图配置
  getEquipmentPieChartOptions(): ChartOptions {
    const colors = ['#FF6B35', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57', '#FF9FF3'];
    return {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        left: 'left',
        data: this.equipmentData.map(item => item.label)
      },
      series: [{
        name: '器材品牌',
        type: 'pie',
        radius: ['50%', '70%'],
        center: ['60%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 16,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: this.equipmentData.map(item => item.value)
      }]
    };
  }

  // 生成价格范围柱状图配置
  getPriceRangeChartOptions(): ChartOptions {
    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: this.priceRangeData.map(item => item.label),
        axisLabel: {
          fontSize: 12
        }
      },
      yAxis: {
        type: 'value',
        axisLabel: {
          fontSize: 12
        }
      },
      series: [{
        name: '器材数量',
        type: 'bar',
        data: this.priceRangeData.map(item => item.value),
        itemStyle: {
          color: '#4ECDC4'
        },
        emphasis: {
          itemStyle: {
            color: '#4ECDC4'
          }
        }
      }]
    };
  }

  // 生成分类饼图配置
  getCategoryChartOptions(): ChartOptions {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57', '#FF9FF3'];
    return {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        left: 'left',
        data: this.categoryData.map(item => item.label)
      },
      series: [{
        name: '器材分类',
        type: 'pie',
        radius: ['0%', '70%'],
        data: this.categoryData.map(item => item.value)
      }]
    };
  }

  @Builder
  EquipmentChartsContent() {
    Scroll() {
      Column({ space: 20 }) {
        // 器材品牌分布
        if (this.equipmentData.length > 0) {
          Column() {
            Text('我的器材品牌分布')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_text_color'))
              .margin({ bottom: 16 })
              .alignSelf(ItemAlign.Start)
            
            hmChart({
              Options: this.getEquipmentPieChartOptions(),
              myChart: this.equipmentChart
            })
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        }
        
        // 价格范围分布
        if (this.priceRangeData.length > 0) {
          Column() {
            Text('器材价格范围分布')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_text_color'))
              .margin({ bottom: 16 })
              .alignSelf(ItemAlign.Start)
            
            hmChart({
              Options: this.getPriceRangeChartOptions(),
              myChart: this.priceChart
            })
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        }
        
        // 器材分类分布
        if (this.categoryData.length > 0) {
          Column() {
            Text('器材分类分布')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_text_color'))
              .margin({ bottom: 16 })
              .alignSelf(ItemAlign.Start)
            
            hmChart({
              Options: this.getCategoryChartOptions(),
              myChart: this.equipmentChart
            })
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
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
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }

  @Builder
  LearningChartsContent() {
    Scroll() {
      Column({ space: 20 }) {
        // 测验完成率
        Column() {
          Text('各难度测验完成率')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          hmChart({
            Options: this.getQuizBarChartOptions(),
            myChart: this.quizChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        
        // 测验总体统计
        Column() {
          Text('测验总体表现')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          hmChart({
            Options: this.getQuizOverallChartOptions(),
            myChart: this.quizOverallChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        
        // 学习路径进度
        Column() {
          Text('学习路径进度')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          hmChart({
            Options: this.getLearningProgressChartOptions(),
            myChart: this.learningChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        
        // 测验分类统计
        Column() {
          Text('测验题目分类分布')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          hmChart({
            Options: this.getQuizCategoryChartOptions(),
            myChart: this.quizCategoryChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        
        // 测验历史趋势
        Column() {
          Text('测验完成数量趋势')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          hmChart({
            Options: this.getQuizTrendChartOptions(),
            myChart: this.quizTrendChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
        
        // 学习活跃度
        Column() {
          Text('本周学习活跃度')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text_color'))
            .margin({ bottom: 16 })
          
          hmChart({
            Options: this.getLearningActivityChartOptions(),
            myChart: this.learningActivityChart
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface_color'))
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }
}