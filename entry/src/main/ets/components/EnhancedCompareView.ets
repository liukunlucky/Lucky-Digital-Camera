import { MyEquipmentItem } from '../model/MyEquipmentModel';
import { CameraDataItem } from '../service/CameraDataJsonService';

// 对比权重配置接口
export interface CompareWeightConfig {
  megapixels: number;     // 像素权重
  iso: number;           // ISO权重
  video: number;         // 视频权重
  screen: number;        // 屏幕权重
  battery: number;       // 电池权重
  weight: number;        // 重量权重
  price: number;         // 价格权重
}

// 对比项目接口
export interface CompareItem {
  label: string;
  value1: string;
  value2: string;
  score1?: number;       // 评分1 (0-10)
  score2?: number;       // 评分2 (0-10)
  weight?: number;       // 权重 (0-1)
  category: string;      // 分类
  isDifferent: boolean;  // 是否不同
  isHighlight: boolean;  // 是否高亮
}

@Component
export struct EnhancedCompareView {
  @Prop equipment1: MyEquipmentItem | null;
  @Prop equipment2: MyEquipmentItem | null;
  @State showOnlyDifferent: boolean = false;
  @State showWeightConfig: boolean = false;
  @State selectedCategory: string = 'all'; // all, basic, camera, performance, price
  @State compareItems: CompareItem[] = [];
  @State totalScore1: number = 0;
  @State totalScore2: number = 0;
  
  // 默认权重配置
  @State weightConfig: CompareWeightConfig = {
    megapixels: 0.2,
    iso: 0.15,
    video: 0.15,
    screen: 0.1,
    battery: 0.1,
    weight: 0.1,
    price: 0.2
  };

  aboutToAppear() {
    this.generateCompareItems();
    this.calculateScores();
  }

  // 生成对比项目
  private generateCompareItems() {
    if (!this.equipment1 || !this.equipment2) {
      this.compareItems = [];
      return;
    }

    const items: CompareItem[] = [];
    
    // 基本信息
    items.push(this.createCompareItem('器材名称', this.equipment1.equipmentName, this.equipment2.equipmentName, 'basic'));
    items.push(this.createCompareItem('品牌', this.equipment1.brand, this.equipment2.brand, 'basic'));
    items.push(this.createCompareItem('型号', this.equipment1.model, this.equipment2.model, 'basic'));
    
    // 相机参数
    if (this.equipment1.cameraDataItem && this.equipment2.cameraDataItem) {
      const cam1 = this.equipment1.cameraDataItem;
      const cam2 = this.equipment2.cameraDataItem;
      
      items.push(this.createCompareItem('发布年份', cam1.Year || '未知', cam2.Year || '未知', 'camera'));
      
      // 像素对比（带评分）
      const mp1 = this.extractMegapixels(cam1.EffectiveMegapixels || cam1.Megapixels || '0');
      const mp2 = this.extractMegapixels(cam2.EffectiveMegapixels || cam2.Megapixels || '0');
      items.push(this.createCompareItemWithScore('有效像素', 
        cam1.EffectiveMegapixels || cam1.Megapixels || '未知',
        cam2.EffectiveMegapixels || cam2.Megapixels || '未知',
        this.scoreMegapixels(mp1), this.scoreMegapixels(mp2),
        this.weightConfig.megapixels, 'performance'));
      
      // ISO对比（带评分）
      items.push(this.createCompareItemWithScore('ISO范围',
        cam1.ISO || '未知', cam2.ISO || '未知',
        this.scoreISO(cam1.ISO || ''), this.scoreISO(cam2.ISO || ''),
        this.weightConfig.iso, 'performance'));
      
      items.push(this.createCompareItem('最大光圈', cam1.MaxAperture || '未知', cam2.MaxAperture || '未知', 'camera'));
      
      // 视频对比（带评分）
      items.push(this.createCompareItemWithScore('视频规格',
        cam1.MaxVideoResolution || '未知', cam2.MaxVideoResolution || '未知',
        this.scoreVideo(cam1.MaxVideoResolution || ''), this.scoreVideo(cam2.MaxVideoResolution || ''),
        this.weightConfig.video, 'performance'));
      
      items.push(this.createCompareItem('屏幕尺寸', cam1.ScreenSize || '未知', cam2.ScreenSize || '未知', 'camera'));
      items.push(this.createCompareItem('取景器', cam1.Viewfinder || '未知', cam2.Viewfinder || '未知', 'camera'));
      items.push(this.createCompareItem('电池', cam1.Battery || '未知', cam2.Battery || '未知', 'camera'));
      items.push(this.createCompareItem('重量', cam1.Weight || '未知', cam2.Weight || '未知', 'camera'));
      items.push(this.createCompareItem('尺寸', cam1.Dimensions || '未知', cam2.Dimensions || '未知', 'camera'));
    }
    
    // 价格信息
    if (this.equipment1.transactions.length > 0 && this.equipment2.transactions.length > 0) {
      const price1 = this.equipment1.transactions[0]?.price || 0;
      const price2 = this.equipment2.transactions[0]?.price || 0;
      items.push(this.createCompareItemWithScore('交易价格',
        price1 > 0 ? `¥${price1}` : '未填写',
        price2 > 0 ? `¥${price2}` : '未填写',
        this.scorePrice(price1), this.scorePrice(price2),
        this.weightConfig.price, 'price'));
    }
    
    this.compareItems = items;
  }

  // 创建对比项目
  private createCompareItem(label: string, value1: string, value2: string, category: string): CompareItem {
    return {
      label,
      value1,
      value2,
      category,
      isDifferent: value1 !== value2,
      isHighlight: value1 !== value2
    };
  }

  // 创建带评分的对比项目
  private createCompareItemWithScore(label: string, value1: string, value2: string, 
                                   score1: number, score2: number, weight: number, category: string): CompareItem {
    return {
      label,
      value1,
      value2,
      score1,
      score2,
      weight,
      category,
      isDifferent: value1 !== value2,
      isHighlight: Math.abs(score1 - score2) > 2 // 评分差异大于2分时高亮
    };
  }

  // 提取像素数值
  private extractMegapixels(mpStr: string): number {
    const match = mpStr.match(/([\d.]+)/);
    return match ? parseFloat(match[1]) : 0;
  }

  // 像素评分 (0-10)
  private scoreMegapixels(mp: number): number {
    if (mp >= 50) return 10;
    if (mp >= 40) return 9;
    if (mp >= 30) return 8;
    if (mp >= 24) return 7;
    if (mp >= 20) return 6;
    if (mp >= 16) return 5;
    if (mp >= 12) return 4;
    if (mp >= 8) return 3;
    if (mp >= 4) return 2;
    return mp > 0 ? 1 : 0;
  }

  // ISO评分
  private scoreISO(isoStr: string): number {
    const maxMatch = isoStr.match(/([\d,]+)$/);
    if (!maxMatch) return 0;
    const maxISO = parseInt(maxMatch[1].replace(/,/g, ''));
    
    if (maxISO >= 102400) return 10;
    if (maxISO >= 51200) return 9;
    if (maxISO >= 25600) return 8;
    if (maxISO >= 12800) return 7;
    if (maxISO >= 6400) return 6;
    if (maxISO >= 3200) return 5;
    if (maxISO >= 1600) return 4;
    if (maxISO >= 800) return 3;
    if (maxISO >= 400) return 2;
    return maxISO > 0 ? 1 : 0;
  }

  // 视频评分
  private scoreVideo(videoStr: string): number {
    if (videoStr.includes('8K')) return 10;
    if (videoStr.includes('4K') && videoStr.includes('120')) return 9;
    if (videoStr.includes('4K') && videoStr.includes('60')) return 8;
    if (videoStr.includes('4K')) return 7;
    if (videoStr.includes('1080') && videoStr.includes('120')) return 6;
    if (videoStr.includes('1080') && videoStr.includes('60')) return 5;
    if (videoStr.includes('1080')) return 4;
    if (videoStr.includes('720')) return 3;
    return videoStr !== '未知' ? 2 : 0;
  }

  // 价格评分（价格越低评分越高）
  private scorePrice(price: number): number {
    if (price <= 0) return 0;
    if (price <= 2000) return 10;
    if (price <= 5000) return 9;
    if (price <= 8000) return 8;
    if (price <= 12000) return 7;
    if (price <= 18000) return 6;
    if (price <= 25000) return 5;
    if (price <= 35000) return 4;
    if (price <= 50000) return 3;
    if (price <= 80000) return 2;
    return 1;
  }

  // 计算总评分
  private calculateScores() {
    let score1 = 0;
    let score2 = 0;
    let totalWeight = 0;
    
    this.compareItems.forEach(item => {
      if (item.score1 !== undefined && item.score2 !== undefined && item.weight !== undefined) {
        score1 += item.score1 * item.weight;
        score2 += item.score2 * item.weight;
        totalWeight += item.weight;
      }
    });
    
    this.totalScore1 = totalWeight > 0 ? (score1 / totalWeight) : 0;
    this.totalScore2 = totalWeight > 0 ? (score2 / totalWeight) : 0;
  }

  // 获取过滤后的对比项目
  private getFilteredItems(): CompareItem[] {
    let filtered = this.compareItems;
    
    // 按分类过滤
    if (this.selectedCategory !== 'all') {
      filtered = filtered.filter(item => item.category === this.selectedCategory);
    }
    
    // 仅显示不同
    if (this.showOnlyDifferent) {
      filtered = filtered.filter(item => item.isDifferent);
    }
    
    return filtered;
  }

  build() {
    Column() {
      // 控制栏
      Row() {
        // 分类筛选
        Row() {
          Text('分类:')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ right: 8 })
          
          Button(this.selectedCategory === 'all' ? '全部' : 
                this.selectedCategory === 'basic' ? '基本' :
                this.selectedCategory === 'camera' ? '相机' :
                this.selectedCategory === 'performance' ? '性能' : '价格')
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
            .backgroundColor('transparent')
            .border({ width: 1, color: $r('app.color.brand_color') })
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              // 循环切换分类
              const categories = ['all', 'basic', 'camera', 'performance', 'price'];
              const currentIndex = categories.indexOf(this.selectedCategory);
              this.selectedCategory = categories[(currentIndex + 1) % categories.length];
            })
        }
        
        Blank()
        
        // 仅显示不同开关
        Row() {
          Text('仅显示不同')
            .fontSize(12)
            .fontColor($r('app.color.primary_text_color'))
          
          Toggle({ type: ToggleType.Switch, isOn: this.showOnlyDifferent })
            .selectedColor($r('app.color.brand_color'))
            .switchPointColor('#FFFFFF')
            .onChange((isOn: boolean) => {
              this.showOnlyDifferent = isOn;
            })
        }
        .margin({ left: 16 })
        
        // 权重配置按钮
        Button('权重')
          .fontSize(12)
          .fontColor($r('app.color.brand_color'))
          .backgroundColor('transparent')
          .border({ width: 1, color: $r('app.color.brand_color') })
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ left: 8 })
          .onClick(() => {
            this.showWeightConfig = true;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor($r('app.color.surface_color'))
      
      // 总评分对比
      if (this.totalScore1 > 0 || this.totalScore2 > 0) {
        Row() {
          Column() {
            Text('综合评分')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ bottom: 4 })
            
            Text(this.totalScore1.toFixed(1))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.totalScore1 > this.totalScore2 ? $r('app.color.success_color') : $r('app.color.primary_text_color'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          
          Text('VS')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_color'))
            .margin({ left: 16, right: 16 })
          
          Column() {
            Text('综合评分')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ bottom: 4 })
            
            Text(this.totalScore2.toFixed(1))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.totalScore2 > this.totalScore1 ? $r('app.color.success_color') : $r('app.color.primary_text_color'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
        .margin({ bottom: 16 })
      }
      
      // 对比列表
      List() {
        ForEach(this.getFilteredItems(), (item: CompareItem) => {
          ListItem() {
            this.CompareItemCard(item)
          }
          .margin({ bottom: 8 })
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showWeightConfig, this.WeightConfigSheet(), {
      height: '70%',
      showClose: false,
      dragBar: true
    })
  }

  @Builder
  CompareItemCard(item: CompareItem) {
    Column() {
      Row() {
        Text(item.label)
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .width(80)
        
        Column() {
          Text(item.value1)
            .fontSize(14)
            .fontColor(item.isHighlight ? $r('app.color.brand_color') : $r('app.color.primary_text_color'))
            .fontWeight(item.isHighlight ? FontWeight.Medium : FontWeight.Normal)
            .textAlign(TextAlign.Center)
          
          if (item.score1 !== undefined) {
            Text(`评分: ${item.score1.toFixed(1)}`)
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
              .margin({ top: 2 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text(item.value2)
            .fontSize(14)
            .fontColor(item.isHighlight ? $r('app.color.brand_color') : $r('app.color.primary_text_color'))
            .fontWeight(item.isHighlight ? FontWeight.Medium : FontWeight.Normal)
            .textAlign(TextAlign.Center)
          
          if (item.score2 !== undefined) {
            Text(`评分: ${item.score2.toFixed(1)}`)
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
              .margin({ top: 2 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      
      // 权重指示器
      if (item.weight !== undefined) {
        Row() {
          Text(`权重: ${(item.weight * 100).toFixed(0)}%`)
            .fontSize(10)
            .fontColor($r('app.color.tertiary_text_color'))
          
          Blank()
          
          // 评分对比条
          if (item.score1 !== undefined && item.score2 !== undefined) {
            Row() {
              Progress({ value: item.score1, total: 10, type: ProgressType.Linear })
                .width(40)
                .height(4)
                .color($r('app.color.brand_color'))
                .backgroundColor($r('app.color.divider_color'))
              
              Text('vs')
                .fontSize(10)
                .fontColor($r('app.color.tertiary_text_color'))
                .margin({ left: 4, right: 4 })
              
              Progress({ value: item.score2, total: 10, type: ProgressType.Linear })
                .width(40)
                .height(4)
                .color($r('app.color.success_color'))
                .backgroundColor($r('app.color.divider_color'))
            }
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(item.isHighlight ? $r('app.color.highlight_background') : $r('app.color.card_background_color'))
    .borderRadius(8)
    .border({ 
      width: item.isHighlight ? 2 : 1, 
      color: item.isHighlight ? $r('app.color.brand_color') : $r('app.color.divider_color') 
    })
  }

  @Builder
  WeightConfigSheet() {
    Column() {
      Text('权重配置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })
      
      Text('调整各项参数的重要性权重')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 20 })
      
      Column() {
        this.WeightSlider('像素', 'megapixels', this.weightConfig.megapixels)
        this.WeightSlider('ISO', 'iso', this.weightConfig.iso)
        this.WeightSlider('视频', 'video', this.weightConfig.video)
        this.WeightSlider('屏幕', 'screen', this.weightConfig.screen)
        this.WeightSlider('电池', 'battery', this.weightConfig.battery)
        this.WeightSlider('重量', 'weight', this.weightConfig.weight)
        this.WeightSlider('价格', 'price', this.weightConfig.price)
      }
      .layoutWeight(1)
      
      Row() {
        Button('重置默认')
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .backgroundColor('transparent')
          .border({ width: 1, color: $r('app.color.divider_color') })
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.weightConfig = {
              megapixels: 0.2,
              iso: 0.15,
              video: 0.15,
              screen: 0.1,
              battery: 0.1,
              weight: 0.1,
              price: 0.2
            };
            this.generateCompareItems();
            this.calculateScores();
          })
        
        Button('应用')
          .fontSize(14)
          .fontColor($r('app.color.surface_color'))
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.generateCompareItems();
            this.calculateScores();
            this.showWeightConfig = false;
          })
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  @Builder
  WeightSlider(label: string, key: string, value: number) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.primary_text_color'))
        .width(60)
      
      Slider({
        value: value * 100,
        min: 0,
        max: 50,
        step: 5
      })
        .blockColor($r('app.color.brand_color'))
        .trackColor($r('app.color.divider_color'))
        .selectedColor($r('app.color.brand_color'))
        .layoutWeight(1)
        .margin({ left: 16, right: 16 })
        .onChange((value: number) => {
          const newValue = value / 100;
          switch (key) {
            case 'megapixels':
              this.weightConfig.megapixels = newValue;
              break;
            case 'iso':
              this.weightConfig.iso = newValue;
              break;
            case 'video':
              this.weightConfig.video = newValue;
              break;
            case 'screen':
              this.weightConfig.screen = newValue;
              break;
            case 'battery':
              this.weightConfig.battery = newValue;
              break;
            case 'weight':
              this.weightConfig.weight = newValue;
              break;
            case 'price':
              this.weightConfig.price = newValue;
              break;
          }
        })
      
      Text(`${(value * 100).toFixed(0)}%`)
        .fontSize(12)
        .fontColor($r('app.color.secondary_text_color'))
        .width(40)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}