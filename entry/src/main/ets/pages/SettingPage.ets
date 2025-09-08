@Component
export struct SettingPage {
  @State isDarkMode: boolean = false;
  @State showAboutSheet: boolean = false;

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })

      // 设置内容
      Column() {
        // 深色模式设置
        Row() {
          Column() {
            Text('深色模式')
              .fontSize(16)
              .fontColor('#2C3E50')
              .fontWeight(FontWeight.Medium)
            Text('切换应用主题外观')
              .fontSize(14)
              .fontColor('#7F8C8D')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
            .selectedColor('#3498DB')
            .switchPointColor('#FFFFFF')
            .onChange((isOn: boolean) => {
              this.isDarkMode = isOn;
              // TODO: 实现深色模式切换逻辑
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 16 })
        .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 })

        // 关于应用
        Row() {
          Column() {
            Text('关于应用')
              .fontSize(16)
              .fontColor('#2C3E50')
              .fontWeight(FontWeight.Medium)
            Text('查看应用信息和版本')
              .fontSize(14)
              .fontColor('#7F8C8D')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor('#BDC3C7')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 12 })
        .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 })
        .onClick(() => {
          this.showAboutSheet = true;
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showAboutSheet, this.AboutSheet(), {
      height: 400,
      dragBar: true,
      backgroundColor: '#FFFFFF',
      onDisappear: () => {
        this.showAboutSheet = false;
      }
    })
  }

  @Builder
  AboutSheet() {
    Column() {
      // Sheet标题
      Text('关于数码回忆')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')
        .margin({ top: 20, bottom: 20 })

      // 应用图标
      Image($r('app.media.foreground'))
        .width(80)
        .height(80)
        .borderRadius(16)
        .margin({ bottom: 16 })

      // 应用信息
      Column() {
        Text('数码回忆')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')
          .margin({ bottom: 8 })

        Text('版本 1.1.0')
          .fontSize(14)
          .fontColor('#7F8C8D')
          .margin({ bottom: 8 })

        Text('一款专为数码相机爱好者打造的应用')
          .fontSize(14)
          .fontColor('#34495E')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

        Text('记录每一台相机的故事，珍藏数码时代的美好回忆')
          .fontSize(12)
          .fontColor('#7F8C8D')
          .textAlign(TextAlign.Center)
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()

      // 版权信息
      Text('© 2024 数码回忆团队')
        .fontSize(12)
        .fontColor('#BDC3C7')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}