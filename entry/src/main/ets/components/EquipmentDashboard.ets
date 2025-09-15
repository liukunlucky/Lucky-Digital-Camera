// 器材统计仪表盘组件
import { MyEquipmentItem, EquipmentTransaction } from '../model/MyEquipmentModel';
import { myEquipmentService } from '../service/MyEquipmentService';
import { promptAction } from '@kit.ArkUI';

// 统计数据接口
export interface EquipmentStats {
  totalEquipment: number;
  totalValue: number;
  totalBought: number;
  totalSold: number;
  profitLoss: number;
  brandCount: number;
  averagePrice: number;
  mostExpensive: MyEquipmentItem | null;
  oldestEquipment: MyEquipmentItem | null;
  newestEquipment: MyEquipmentItem | null;
}

// 成就数据接口
export interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  isUnlocked: boolean;
  progress: number;
  maxProgress: number;
  unlockDate?: string;
}

@Component
export struct EquipmentDashboard {
  @State stats: EquipmentStats = {
    totalEquipment: 0,
    totalValue: 0,
    totalBought: 0,
    totalSold: 0,
    profitLoss: 0,
    brandCount: 0,
    averagePrice: 0,
    mostExpensive: null,
    oldestEquipment: null,
    newestEquipment: null
  };
  @State achievements: Achievement[] = [];
  @State selectedTab: number = 0; // 0: 统计, 1: 成就

  aboutToAppear() {
    this.calculateStats();
    this.calculateAchievements();
  }

  // 计算统计数据
  private calculateStats() {
    const equipmentList = myEquipmentService.getAllEquipment();
    
    if (equipmentList.length === 0) {
      return;
    }

    // 基础统计
    this.stats.totalEquipment = equipmentList.length;
    
    // 品牌统计
    const brands = new Set(equipmentList.map(item => item.brand));
    this.stats.brandCount = brands.size;

    // 交易统计
    let totalBoughtValue = 0;
    let totalSoldValue = 0;
    let boughtCount = 0;
    let soldCount = 0;
    let allPrices: number[] = [];

    equipmentList.forEach(item => {
      item.transactions.forEach(transaction => {
        if (transaction.price && transaction.price > 0) {
          allPrices.push(transaction.price);
          if (transaction.type === 'buy') {
            totalBoughtValue += transaction.price;
            boughtCount++;
          } else if (transaction.type === 'sell') {
            totalSoldValue += transaction.price;
            soldCount++;
          }
        }
      });
    });

    this.stats.totalBought = boughtCount;
    this.stats.totalSold = soldCount;
    this.stats.totalValue = totalBoughtValue;
    this.stats.profitLoss = totalSoldValue - totalBoughtValue;
    this.stats.averagePrice = allPrices.length > 0 ? allPrices.reduce((a, b) => a + b, 0) / allPrices.length : 0;

    // 最贵器材
    let mostExpensive: MyEquipmentItem | null = null;
    let maxPrice = 0;
    equipmentList.forEach(item => {
      item.transactions.forEach(transaction => {
        if (transaction.price && transaction.price > maxPrice) {
          maxPrice = transaction.price;
          mostExpensive = item;
        }
      });
    });
    this.stats.mostExpensive = mostExpensive;

    // 最老和最新器材
    const sortedByDate = [...equipmentList].sort((a, b) => 
      new Date(a.addTime).getTime() - new Date(b.addTime).getTime()
    );
    this.stats.oldestEquipment = sortedByDate[0] || null;
    this.stats.newestEquipment = sortedByDate[sortedByDate.length - 1] || null;
  }

  // 计算成就
  private calculateAchievements() {
    const equipmentList = myEquipmentService.getAllEquipment();
    const achievements: Achievement[] = [];

    // 收藏家成就
    achievements.push({
      id: 'collector_1',
      title: '初级收藏家',
      description: '拥有第一台相机',
      icon: '📷',
      isUnlocked: equipmentList.length >= 1,
      progress: Math.min(equipmentList.length, 1),
      maxProgress: 1,
      unlockDate: equipmentList.length >= 1 ? equipmentList[0]?.addTime : undefined
    });

    achievements.push({
      id: 'collector_5',
      title: '资深收藏家',
      description: '拥有5台相机',
      icon: '🎯',
      isUnlocked: equipmentList.length >= 5,
      progress: Math.min(equipmentList.length, 5),
      maxProgress: 5,
      unlockDate: equipmentList.length >= 5 ? equipmentList[4]?.addTime : undefined
    });

    achievements.push({
      id: 'collector_10',
      title: '专业收藏家',
      description: '拥有10台相机',
      icon: '🏆',
      isUnlocked: equipmentList.length >= 10,
      progress: Math.min(equipmentList.length, 10),
      maxProgress: 10,
      unlockDate: equipmentList.length >= 10 ? equipmentList[9]?.addTime : undefined
    });

    // 品牌成就
    const brandCount = this.stats.brandCount;
    achievements.push({
      id: 'brand_explorer',
      title: '品牌探索者',
      description: '拥有3个不同品牌的相机',
      icon: '🌟',
      isUnlocked: brandCount >= 3,
      progress: Math.min(brandCount, 3),
      maxProgress: 3
    });

    // 交易成就
    const totalTransactions = equipmentList.reduce((sum, item) => sum + item.transactions.length, 0);
    achievements.push({
      id: 'trader',
      title: '活跃交易者',
      description: '完成10次交易',
      icon: '💰',
      isUnlocked: totalTransactions >= 10,
      progress: Math.min(totalTransactions, 10),
      maxProgress: 10
    });

    // 价值成就
    achievements.push({
      id: 'high_value',
      title: '高价值收藏',
      description: '拥有价值超过10000元的器材',
      icon: '💎',
      isUnlocked: this.stats.totalValue >= 10000,
      progress: Math.min(this.stats.totalValue, 10000),
      maxProgress: 10000
    });

    this.achievements = achievements;
  }

  // 格式化货币
  private formatCurrency(amount: number): string {
    return `¥${amount.toLocaleString()}`;
  }

  // 格式化日期
  private formatDate(dateString: string): string {
    const date = new Date(dateString);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('器材仪表盘')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .justifyContent(FlexAlign.Center)

      // Tab切换
      Row() {
        Button('统计数据')
          .fontSize(16)
          .fontColor(this.selectedTab === 0 ? '#FFFFFF' : $r('app.color.secondary_text_color'))
          .backgroundColor(this.selectedTab === 0 ? $r('app.color.brand_color') : 'transparent')
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => {
            this.selectedTab = 0;
          })

        Button('成就系统')
          .fontSize(16)
          .fontColor(this.selectedTab === 1 ? '#FFFFFF' : $r('app.color.secondary_text_color'))
          .backgroundColor(this.selectedTab === 1 ? $r('app.color.brand_color') : 'transparent')
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .margin({ left: 12 })
          .onClick(() => {
            this.selectedTab = 1;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Start)

      // 内容区域
      if (this.selectedTab === 0) {
        this.StatisticsContent()
      } else {
        this.AchievementsContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  @Builder
  StatisticsContent() {
    Scroll() {
      Column({ space: 16 }) {
        // 概览卡片
        this.OverviewCards()

        // 详细统计
        this.DetailedStats()

        // 器材亮点
        this.EquipmentHighlights()
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }

  @Builder
  OverviewCards() {
    Column() {
      Text('概览')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Grid() {
        GridItem() {
          this.StatCard('总器材', this.stats.totalEquipment.toString(), '台', '#FF6B6B')
        }
        GridItem() {
          this.StatCard('总价值', this.formatCurrency(this.stats.totalValue), '', '#4ECDC4')
        }
        GridItem() {
          this.StatCard('品牌数', this.stats.brandCount.toString(), '个', '#45B7D1')
        }
        GridItem() {
          this.StatCard('平均价格', this.formatCurrency(this.stats.averagePrice), '', '#96CEB4')
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(160)
    }
  }

  @Builder
  StatCard(title: string, value: string, unit: string, color: string) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 8 })

      Row() {
        Text(value)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
        if (unit) {
          Text(unit)
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 4 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor($r('app.color.surface_color'))
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DetailedStats() {
    Column() {
      Text('交易统计')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Column({ space: 12 }) {
        this.DetailStatRow('买入次数', this.stats.totalBought.toString() + ' 次')
        this.DetailStatRow('卖出次数', this.stats.totalSold.toString() + ' 次')
        this.DetailStatRow('盈亏情况', 
          this.stats.profitLoss >= 0 ? 
            '+' + this.formatCurrency(this.stats.profitLoss) : 
            this.formatCurrency(this.stats.profitLoss),
          this.stats.profitLoss >= 0 ? '#27AE60' : '#E74C3C'
        )
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.surface_color'))
      .borderRadius(12)
    }
  }

  @Builder
  DetailStatRow(label: string, value: string, valueColor?: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor($r('app.color.primary_text_color'))
      
      Blank()
      
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(valueColor || $r('app.color.primary_text_color'))
    }
    .width('100%')
  }

  @Builder
  EquipmentHighlights() {
    Column() {
      Text('器材亮点')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Column({ space: 12 }) {
        if (this.stats.mostExpensive) {
          this.HighlightCard(
            '最贵器材',
            `${this.stats.mostExpensive.brand} ${this.stats.mostExpensive.model}`,
            '💎'
          )
        }
        
        if (this.stats.oldestEquipment) {
          this.HighlightCard(
            '最早添加',
            `${this.stats.oldestEquipment.brand} ${this.stats.oldestEquipment.model}`,
            '⏰'
          )
        }
        
        if (this.stats.newestEquipment) {
          this.HighlightCard(
            '最新添加',
            `${this.stats.newestEquipment.brand} ${this.stats.newestEquipment.model}`,
            '✨'
          )
        }
      }
    }
  }

  @Builder
  HighlightCard(title: string, content: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })
      
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .alignSelf(ItemAlign.Start)
        
        Text(content)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_color'))
    .borderRadius(12)
  }

  @Builder
  AchievementsContent() {
    Scroll() {
      Column({ space: 12 }) {
        Text('成就系统')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        ForEach(this.achievements, (achievement: Achievement) => {
          this.AchievementCard(achievement)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
  }

  @Builder
  AchievementCard(achievement: Achievement) {
    Row() {
      // 成就图标
      Text(achievement.icon)
        .fontSize(32)
        .margin({ right: 16 })
        .opacity(achievement.isUnlocked ? 1 : 0.3)
      
      // 成就信息
      Column() {
        Row() {
          Text(achievement.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(achievement.isUnlocked ? $r('app.color.primary_text_color') : $r('app.color.secondary_text_color'))
          
          if (achievement.isUnlocked) {
            Text('✓')
              .fontSize(16)
              .fontColor('#27AE60')
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        
        Text(achievement.description)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ top: 4, bottom: 8 })
          .alignSelf(ItemAlign.Start)
        
        // 进度条
        Row() {
          Progress({
            value: achievement.progress,
            total: achievement.maxProgress,
            type: ProgressType.Linear
          })
          .width('70%')
          .height(6)
          .color(achievement.isUnlocked ? '#27AE60' : $r('app.color.brand_color'))
          .backgroundColor('#E0E0E0')
          
          Text(`${achievement.progress}/${achievement.maxProgress}`)
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ left: 8 })
        }
        .width('100%')
        
        if (achievement.unlockDate) {
          Text(`解锁时间: ${this.formatDate(achievement.unlockDate)}`)
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 4 })
            .alignSelf(ItemAlign.Start)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_color'))
    .borderRadius(12)
    .opacity(achievement.isUnlocked ? 1 : 0.7)
  }
}