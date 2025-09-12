// 通用图表组件
import { drawing } from '@kit.ArkGraphics2D';

// 图表数据接口
export interface ChartData {
  label: string;
  value: number;
  color?: string;
}

// 图表配置接口
export interface ChartConfig {
  title?: string;
  width: number;
  height: number;
  backgroundColor?: string;
  showLegend?: boolean;
  showGrid?: boolean;
  colors?: string[];
}

// 图表类型枚举
export enum ChartType {
  BAR = 'bar',
  PIE = 'pie',
  LINE = 'line',
  DOUGHNUT = 'doughnut'
}

@Component
export struct ChartComponent {
  @Prop data: ChartData[];
  @Prop type: ChartType;
  @Prop config: ChartConfig;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  // 默认颜色配置
  private defaultColors: string[] = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57',
    '#FF9FF3', '#54A0FF', '#5F27CD', '#00D2D3', '#FF9F43'
  ];

  build() {
    Column() {
      if (this.config.title) {
        Text(this.config.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 16 })
      }
      
      Canvas(this.context)
        .width(this.config.width)
        .height(this.config.height)
        .backgroundColor(this.config.backgroundColor || '#FFFFFF')
        .onReady(() => {
          this.drawChart();
        })
      
      if (this.config.showLegend) {
        this.buildLegend()
      }
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  buildLegend() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.data, (item: ChartData, index: number) => {
        Row({ space: 8 }) {
          Rect()
            .width(12)
            .height(12)
            .fill(this.getColor(index))
            .borderRadius(2)
          
          Text(item.label)
            .fontSize(16)
            .fontColor('#666666')
        }
        .margin({ right: 16, bottom: 8 })
      })
    }
    .margin({ top: 16 })
  }

  private drawChart() {
    this.context.clearRect(0, 0, this.config.width, this.config.height);
    
    switch (this.type) {
      case ChartType.BAR:
        this.drawBarChart();
        break;
      case ChartType.PIE:
        this.drawPieChart();
        break;
      case ChartType.LINE:
        this.drawLineChart();
        break;
      case ChartType.DOUGHNUT:
        this.drawDoughnutChart();
        break;
    }
  }

  private drawBarChart() {
    const padding = 40;
    const chartWidth = this.config.width - 2 * padding;
    const chartHeight = this.config.height - 2 * padding;
    const barWidth = chartWidth / this.data.length * 0.8;
    const barSpacing = chartWidth / this.data.length * 0.2;
    
    const maxValue = Math.max(...this.data.map(d => d.value));
    
    // 绘制网格线
    if (this.config.showGrid) {
      this.drawGrid(padding, chartWidth, chartHeight, maxValue);
    }
    
    // 绘制柱状图
    this.data.forEach((item, index) => {
      const barHeight = (item.value / maxValue) * chartHeight;
      const x = padding + index * (barWidth + barSpacing) + barSpacing / 2;
      const y = this.config.height - padding - barHeight;
      
      this.context.fillStyle = this.getColor(index);
      this.context.fillRect(x, y, barWidth, barHeight);
      
      // 绘制数值标签
      this.context.fillStyle = '#333333';
      this.context.font = 'bold 18px sans-serif';
      this.context.textAlign = 'center';
      this.context.fillText(item.value.toString(), x + barWidth / 2, y - 8);
      
      // 绘制标签
      this.context.font = '16px sans-serif';
      this.context.fillText(item.label, x + barWidth / 2, this.config.height - padding + 25);
    });
  }

  private drawPieChart() {
    const centerX = this.config.width / 2;
    const centerY = this.config.height / 2;
    const radius = Math.min(centerX, centerY) - 20;
    
    const total = this.data.reduce((sum, item) => sum + item.value, 0);
    let currentAngle = -Math.PI / 2; // 从顶部开始
    
    this.data.forEach((item, index) => {
      const sliceAngle = (item.value / total) * 2 * Math.PI;
      
      this.context.beginPath();
      this.context.moveTo(centerX, centerY);
      this.context.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle);
      this.context.closePath();
      
      this.context.fillStyle = this.getColor(index);
      this.context.fill();
      
      // 绘制百分比标签
      const labelAngle = currentAngle + sliceAngle / 2;
      const labelX = centerX + Math.cos(labelAngle) * (radius * 0.7);
      const labelY = centerY + Math.sin(labelAngle) * (radius * 0.7);
      
      const percentage = ((item.value / total) * 100).toFixed(1);
      this.context.fillStyle = '#FFFFFF';
      this.context.font = 'bold 18px sans-serif';
      this.context.textAlign = 'center';
      this.context.fillText(`${percentage}%`, labelX, labelY);
      
      currentAngle += sliceAngle;
    });
  }

  private drawLineChart() {
    const padding = 40;
    const chartWidth = this.config.width - 2 * padding;
    const chartHeight = this.config.height - 2 * padding;
    
    const maxValue = Math.max(...this.data.map(d => d.value));
    const minValue = Math.min(...this.data.map(d => d.value));
    const valueRange = maxValue - minValue || 1;
    
    // 绘制网格线
    if (this.config.showGrid) {
      this.drawGrid(padding, chartWidth, chartHeight, maxValue);
    }
    
    // 绘制折线
    this.context.beginPath();
    this.context.strokeStyle = this.getColor(0);
    this.context.lineWidth = 2;
    
    this.data.forEach((item, index) => {
      const x = padding + (index / (this.data.length - 1)) * chartWidth;
      const y = this.config.height - padding - ((item.value - minValue) / valueRange) * chartHeight;
      
      if (index === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
      
      // 绘制数据点
      this.context.fillStyle = this.getColor(0);
      this.context.beginPath();
      this.context.arc(x, y, 4, 0, 2 * Math.PI);
      this.context.fill();
      
      // 绘制数值标签
      this.context.fillStyle = '#333333';
      this.context.font = 'bold 16px sans-serif';
      this.context.textAlign = 'center';
      this.context.fillText(item.value.toString(), x, y - 12);
      
      // 绘制X轴标签
      this.context.font = '14px sans-serif';
      this.context.fillText(item.label, x, this.config.height - padding + 25);
    });
    
    this.context.stroke();
  }

  private drawDoughnutChart() {
    const centerX = this.config.width / 2;
    const centerY = this.config.height / 2;
    const outerRadius = Math.min(centerX, centerY) - 20;
    const innerRadius = outerRadius * 0.6;
    
    const total = this.data.reduce((sum, item) => sum + item.value, 0);
    let currentAngle = -Math.PI / 2;
    
    this.data.forEach((item, index) => {
      const sliceAngle = (item.value / total) * 2 * Math.PI;
      
      this.context.beginPath();
      this.context.arc(centerX, centerY, outerRadius, currentAngle, currentAngle + sliceAngle);
      this.context.arc(centerX, centerY, innerRadius, currentAngle + sliceAngle, currentAngle, true);
      this.context.closePath();
      
      this.context.fillStyle = this.getColor(index);
      this.context.fill();
      
      currentAngle += sliceAngle;
    });
    
    // 绘制中心文字
    this.context.fillStyle = '#333333';
    this.context.font = 'bold 20px sans-serif';
    this.context.textAlign = 'center';
    this.context.fillText('总计', centerX, centerY - 8);
    this.context.font = 'bold 24px sans-serif';
    this.context.fillText(total.toString(), centerX, centerY + 20);
  }

  private drawGrid(padding: number, chartWidth: number, chartHeight: number, maxValue: number) {
    this.context.strokeStyle = '#E0E0E0';
    this.context.lineWidth = 1;
    
    // 绘制水平网格线
    for (let i = 0; i <= 5; i++) {
      const y = this.config.height - padding - (i / 5) * chartHeight;
      this.context.beginPath();
      this.context.moveTo(padding, y);
      this.context.lineTo(padding + chartWidth, y);
      this.context.stroke();
      
      // 绘制Y轴标签
      const value = (maxValue / 5) * i;
      this.context.fillStyle = '#666666';
      this.context.font = '14px sans-serif';
      this.context.textAlign = 'right';
      this.context.fillText(value.toFixed(0), padding - 15, y + 5);
    }
  }

  private getColor(index: number): string {
    const colors = this.config.colors || this.defaultColors;
    return colors[index % colors.length];
  }
}