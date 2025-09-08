import { HomePage } from './HomePage';
import { SettingPage } from './SettingPage';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;

  build() {
    Tabs({ index: this.currentTabIndex }) {
      // 首页Tab
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_home')))

      // 设置Tab
      TabContent() {
        SettingPage()
      }
      .tabBar(this.TabBuilder('设置', 1, $r('app.media.ic_settings')))
    }
    .width('100%')
    .height('100%')
    .barBackgroundColor($r('app.color.tab_bar_bg'))
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })

  }

  @Builder
  TabBuilder(title: string, index: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? '#3498DB' : '#7F8C8D')
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? '#3498DB' : '#7F8C8D')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }
}