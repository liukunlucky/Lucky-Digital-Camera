import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

// 拍摄参数接口
interface ShootingParameters {
  aperture: number;        // 光圈值 (f/1.4, f/2.8, etc.)
  shutterSpeed: number;    // 快门速度 (1/60, 1/125, etc.)
  iso: number;            // ISO感光度
  focalLength: number;    // 焦距 (mm)
  distance: number;       // 拍摄距离 (m)
}

// 模拟效果接口
interface SimulationEffect {
  exposure: number;       // 曝光补偿
  depthOfField: number;   // 景深效果
  motionBlur: number;     // 运动模糊
  noise: number;          // 噪点程度
  sharpness: number;      // 锐度
}

// 预设项接口
interface PresetItem {
  name: string;
  params: ShootingParameters;
}

@Entry
@Component
struct ShootingSimulatorPage {
  @State parameters: ShootingParameters = {
    aperture: 2.8,
    shutterSpeed: 125,
    iso: 400,
    focalLength: 50,
    distance: 3
  };
  
  @State effect: SimulationEffect = {
    exposure: 0,
    depthOfField: 0.5,
    motionBlur: 0,
    noise: 0.2,
    sharpness: 0.8
  };
  
  @State selectedPreset: string = '自定义';
  @State presets: Array<PresetItem> = [
    {
      name: '人像模式',
      params: { aperture: 1.8, shutterSpeed: 125, iso: 200, focalLength: 85, distance: 2 }
    },
    {
      name: '风景模式', 
      params: { aperture: 8, shutterSpeed: 60, iso: 100, focalLength: 24, distance: 50 }
    },
    {
      name: '运动模式',
      params: { aperture: 4, shutterSpeed: 500, iso: 800, focalLength: 200, distance: 10 }
    },
    {
      name: '夜景模式',
      params: { aperture: 2.8, shutterSpeed: 4, iso: 1600, focalLength: 35, distance: 20 }
    },
    {
      name: '微距模式',
      params: { aperture: 5.6, shutterSpeed: 250, iso: 400, focalLength: 100, distance: 0.3 }
    }
  ];
  
  aboutToAppear() {
    this.updateEffect();
  }
  
  // 更新模拟效果
  private updateEffect() {
    // 根据参数计算模拟效果
    this.effect.exposure = this.calculateExposure();
    this.effect.depthOfField = this.calculateDepthOfField();
    this.effect.motionBlur = this.calculateMotionBlur();
    this.effect.noise = this.calculateNoise();
    this.effect.sharpness = this.calculateSharpness();
  }
  
  // 计算曝光
  private calculateExposure(): number {
    const ev = Math.log2((this.parameters.aperture * this.parameters.aperture) / (this.parameters.shutterSpeed / 1000)) - Math.log2(this.parameters.iso / 100);
    return Math.max(-3, Math.min(3, ev));
  }
  
  // 计算景深
  private calculateDepthOfField(): number {
    const hyperfocal = (this.parameters.focalLength * this.parameters.focalLength) / (this.parameters.aperture * 0.03);
    const nearLimit = (hyperfocal * this.parameters.distance) / (hyperfocal + this.parameters.distance);
    const farLimit = (hyperfocal * this.parameters.distance) / (hyperfocal - this.parameters.distance);
    const dof = Math.abs(farLimit - nearLimit);
    return Math.min(1, dof / 10);
  }
  
  // 计算运动模糊
  private calculateMotionBlur(): number {
    const motionSpeed = 5; // 假设运动速度 m/s
    const blur = motionSpeed / this.parameters.shutterSpeed;
    return Math.min(1, blur / 10);
  }
  
  // 计算噪点
  private calculateNoise(): number {
    return Math.min(1, (this.parameters.iso - 100) / 6300);
  }
  
  // 计算锐度
  private calculateSharpness(): number {
    const optimalAperture = 8;
    const apertureDiff = Math.abs(this.parameters.aperture - optimalAperture);
    return Math.max(0.3, 1 - apertureDiff / 10);
  }
  
  // 应用预设
  private applyPreset(preset: PresetItem) {
    this.parameters = {
      aperture: preset.params.aperture,
      shutterSpeed: preset.params.shutterSpeed,
      iso: preset.params.iso,
      focalLength: preset.params.focalLength,
      distance: preset.params.distance
    };
    this.selectedPreset = preset.name;
    this.updateEffect();
  }
  
  // 重置参数
  private resetParameters() {
    this.parameters = {
      aperture: 2.8,
      shutterSpeed: 125,
      iso: 400,
      focalLength: 50,
      distance: 3
    };
    this.selectedPreset = '自定义';
    this.updateEffect();
  }
  
  build() {
    Column() {
      // 顶部导航栏
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
        
        Column() {
          Text('拍摄模拟器')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
          Text('调整参数，实时预览拍摄效果')
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Button('重置')
          .fontSize(14)
          .fontColor($r('app.color.brand_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.resetParameters())
      }
      .width('100%')
      .height(66)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface_color'))
      .border({ width: { bottom: 1 }, color: $r('app.color.divider_color') })
      
      Scroll() {
        Column() {
          // 预设模式选择
          Column() {
            Text('拍摄模式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.primary_text_color'))
              .width('100%')
              .margin({ bottom: 12 })
            
            Scroll() {
              Row() {
                ForEach(this.presets, (preset: PresetItem) => {
                  Button(preset.name)
                    .fontSize(14)
                    .fontColor(this.selectedPreset === preset.name ? '#FFFFFF' : $r('app.color.brand_color'))
                    .backgroundColor(this.selectedPreset === preset.name ? $r('app.color.brand_color') : $r('app.color.background_color'))
                    .borderRadius(20)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .margin({ right: 12 })
                    .onClick(() => this.applyPreset(preset))
                })
                
                Button('自定义')
                  .fontSize(14)
                  .fontColor(this.selectedPreset === '自定义' ? '#FFFFFF' : $r('app.color.brand_color'))
                  .backgroundColor(this.selectedPreset === '自定义' ? $r('app.color.brand_color') : $r('app.color.background_color'))
                  .borderRadius(20)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .onClick(() => {
                    this.selectedPreset = '自定义';
                  })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(12)
          .margin({ bottom: 16 })
          
          // 模拟效果预览
          Column() {
            Row() {
              Text('效果预览')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.primary_text_color'))
                .layoutWeight(1)
              
              Button('💡 查看建议')
                .fontSize(12)
                .fontColor($r('app.color.brand_color'))
                .backgroundColor(Color.Transparent)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .onClick(() => {
                  promptAction.showToast({
                    message: this.getShootingAdvice(),
                    duration: 3000
                  });
                })
            }
            .width('100%')
            .margin({ bottom: 12 })
            
            // 模拟图像区域
            Stack() {
              // 背景图像
              Image($r('app.media.foreground'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
              
              // 效果叠加层
              Column()
                .width('100%')
                .height(200)
                .backgroundColor(`rgba(0,0,0,${this.effect.exposure < 0 ? Math.abs(this.effect.exposure) * 0.3 : 0})`)
                .borderRadius(8)
                .blur(this.effect.motionBlur * 10)
              
              // 参数信息覆盖层
              Column() {
                Text(`f/${this.parameters.aperture} • 1/${this.parameters.shutterSpeed}s • ISO${this.parameters.iso}`)
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor('rgba(0,0,0,0.6)')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.End)
              .alignItems(HorizontalAlign.Start)
              .padding(12)
            }
            .width('100%')
            .height(200)
            
            // 效果参数显示
            Grid() {
              GridItem() {
                this.EffectCard('曝光', this.effect.exposure.toFixed(1), this.effect.exposure > 0 ? '#FF6B6B' : '#4ECDC4')
              }
              GridItem() {
                this.EffectCard('景深', (this.effect.depthOfField * 100).toFixed(0) + '%', '#45B7D1')
              }
              GridItem() {
                this.EffectCard('运动模糊', (this.effect.motionBlur * 100).toFixed(0) + '%', '#96CEB4')
              }
              GridItem() {
                this.EffectCard('噪点', (this.effect.noise * 100).toFixed(0) + '%', '#FECA57')
              }
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
            .margin({ top: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface_color'))
          .borderRadius(12)
          .margin({ bottom: 16 })
          
          // 参数调节区域
          Column() {
            Text('参数调节')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.primary_text_color'))
              .width('100%')
              .margin({ bottom: 16 })
            
            // 光圈
            Column() {
              Row() {
                Text('光圈 (控制景深)')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
                Text(`f/${this.parameters.aperture.toFixed(1)}`)
                  .fontSize(14)
                  .fontColor($r('app.color.brand_color'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ bottom: 4 })
              
              Text('数值越小光圈越大，背景虚化越强')
                .fontSize(12)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Slider({
                value: this.parameters.aperture,
                min: 1.4,
                max: 22,
                step: 0.1
              })
                .width('100%')
                .trackColor($r('app.color.background_color'))
                .selectedColor($r('app.color.brand_color'))
                .blockColor($r('app.color.brand_color'))
                .onChange((value: number) => {
                  this.parameters.aperture = value;
                  this.selectedPreset = '自定义';
                  this.updateEffect();
                })
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            // 快门速度
            Column() {
              Row() {
                Text('快门速度 (控制运动模糊)')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
                Text(`1/${this.parameters.shutterSpeed.toFixed(0)}s`)
                  .fontSize(14)
                  .fontColor($r('app.color.brand_color'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ bottom: 4 })
              
              Text('数值越大快门越快，能冻结运动')
                .fontSize(12)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Slider({
                value: this.parameters.shutterSpeed,
                min: 1,
                max: 4000,
                step: 1
              })
                .width('100%')
                .trackColor($r('app.color.background_color'))
                .selectedColor($r('app.color.brand_color'))
                .blockColor($r('app.color.brand_color'))
                .onChange((value: number) => {
                  this.parameters.shutterSpeed = value;
                  this.selectedPreset = '自定义';
                  this.updateEffect();
                })
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            // ISO
            Column() {
              Row() {
                Text('ISO感光度 (控制亮度和噪点)')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
                Text(`ISO ${this.parameters.iso.toFixed(0)}`)
                  .fontSize(14)
                  .fontColor($r('app.color.brand_color'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ bottom: 4 })
              
              Text('数值越高越亮但噪点越多')
                .fontSize(12)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Slider({
                value: this.parameters.iso,
                min: 100,
                max: 6400,
                step: 100
              })
                .width('100%')
                .trackColor($r('app.color.background_color'))
                .selectedColor($r('app.color.brand_color'))
                .blockColor($r('app.color.brand_color'))
                .onChange((value: number) => {
                  this.parameters.iso = value;
                  this.selectedPreset = '自定义';
                  this.updateEffect();
                })
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            // 焦距
            Column() {
              Row() {
                Text('焦距 (控制视角)')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
                Text(`${this.parameters.focalLength.toFixed(0)}mm`)
                  .fontSize(14)
                  .fontColor($r('app.color.brand_color'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ bottom: 4 })
              
              Text('数值越大视角越窄，放大效果越强')
                .fontSize(12)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Slider({
                value: this.parameters.focalLength,
                min: 14,
                max: 200,
                step: 1
              })
                .width('100%')
                .trackColor($r('app.color.background_color'))
                .selectedColor($r('app.color.brand_color'))
                .blockColor($r('app.color.brand_color'))
                .onChange((value: number) => {
                  this.parameters.focalLength = value;
                  this.selectedPreset = '自定义';
                  this.updateEffect();
                })
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            // 拍摄距离
            Column() {
              Row() {
                Text('拍摄距离 (影响景深)')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
                Text(`${this.parameters.distance.toFixed(1)}m`)
                  .fontSize(14)
                  .fontColor($r('app.color.brand_color'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ bottom: 4 })
              
              Text('距离越近背景虚化越强')
                .fontSize(12)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ bottom: 8 })
              
              Slider({
                value: this.parameters.distance,
                min: 0.1,
                max: 100,
                step: 0.1
              })
                .width('100%')
                .trackColor($r('app.color.background_color'))
                .selectedColor($r('app.color.brand_color'))
                .blockColor($r('app.color.brand_color'))
                .onChange((value: number) => {
                  this.parameters.distance = value;
                  this.selectedPreset = '自定义';
                  this.updateEffect();
                })
            }
            .width('100%')
            .margin({ bottom: 20 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })
          
          // 拍摄建议
          Column() {
            Text('拍摄建议')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 12 })
            
            Text(this.getShootingAdvice())
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(20)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })
        }
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .height('100%')
  }
  
  // 效果卡片
  @Builder
  EffectCard(title: string, value: string, color: string) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 4 })
      
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
  }
  
  // 参数滑块
  @Builder
  ParameterSlider(
    title: string,
    value: string,
    currentValue: number,
    min: number,
    max: number,
    step: number,
    onChange: (value: number) => void
  ) {
    Column() {
      Row() {
        Text(title)
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .layoutWeight(1)
        
        Text(value)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.brand_color'))
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      Slider({
        value: currentValue,
        min: min,
        max: max,
        step: step
      })
        .width('100%')
        .trackColor('#E5E5E5')
        .selectedColor('#007AFF')
        .blockColor('#007AFF')
        .onChange((value: number) => {
          onChange(value);
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }
  
  // 生成拍摄建议
  private getShootingAdvice(): string {
    let advice: string[] = [];
    
    // 根据光圈给出建议
    if (this.parameters.aperture < 2.8) {
      advice.push('大光圈设置，背景虚化强烈，适合人像拍摄');
    } else if (this.parameters.aperture > 8) {
      advice.push('小光圈设置，景深较深，适合风景拍摄');
    } else {
      advice.push('中等光圈，平衡景深和锐度');
    }
    
    // 根据快门速度给出建议
    if (this.parameters.shutterSpeed < 60) {
      advice.push('快门较慢，建议使用三脚架防抖');
    } else if (this.parameters.shutterSpeed > 500) {
      advice.push('快门很快，能冻结快速运动');
    }
    
    // 根据ISO给出建议
    if (this.parameters.iso < 200) {
      advice.push('ISO较低，画质最佳，适合光线充足环境');
    } else if (this.parameters.iso > 1600) {
      advice.push('ISO较高，注意噪点控制');
    }
    
    // 根据焦距给出建议
    if (this.parameters.focalLength < 35) {
      advice.push('广角镜头，适合风景和建筑摄影');
    } else if (this.parameters.focalLength > 85) {
      advice.push('长焦镜头，适合人像和远距离拍摄');
    }
    
    // 根据拍摄距离给出建议
    if (this.parameters.distance < 1) {
      advice.push('近距离拍摄，注意对焦精度');
    }
    
    return advice.length > 0 ? advice.join('；') : '当前参数设置合理';
  }
}