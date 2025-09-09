import router from '@ohos.router';

@Entry
@Component
struct SuggestionDetail {
  @State suggestion: SuggestionItem | null = null;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.suggestion) {
      this.suggestion = params.suggestion as SuggestionItem;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor($r('app.color.primary_text_color'))
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })
        .margin({ left: 8 })

        Text('购买建议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor($r('app.color.surface_color'))
      .alignItems(VerticalAlign.Center)

      if (this.suggestion) {
        Scroll() {
          Column() {
            // 标题
            Text(this.suggestion.title)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_text_color'))
              .width('100%')
              .margin({ bottom: 16 })

            // 发布信息
            Row() {
              Text(`${this.suggestion.readCount} 次阅读`)
                .fontSize(14)
                .fontColor($r('app.color.tertiary_text_color'))

              Blank()

              Text(this.suggestion.publishTime)
                .fontSize(14)
                .fontColor($r('app.color.tertiary_text_color'))
            }
            .width('100%')
            .margin({ bottom: 24 })

            // 内容
            Text(this.suggestion.content)
              .fontSize(16)
              .fontColor($r('app.color.primary_text_color'))
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20, bottom: 20 })
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.background_color'))
      } else {
        Column() {
          Text('内容加载失败')
            .fontSize(18)
            .fontColor($r('app.color.secondary_text_color'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color'))
      }
    }
    .width('100%')
    .height('100%')
  }
}

interface SuggestionItem {
  id: number;
  title: string;
  summary: string;
  content: string;
  readCount: number;
  publishTime: string;
}