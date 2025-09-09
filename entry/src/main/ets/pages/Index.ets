import { HomePage } from './HomePage';
import { SuggestionPage } from './SuggestionPage';
import { MyEquipmentPage } from './MyEquipmentPage';
import { SettingPage } from './SettingPage';
import { myEquipmentService } from '../service/MyEquipmentService';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;

  aboutToAppear() {
    // 初始化我的器材服务
    const context = getContext(this) as common.UIAbilityContext;
    myEquipmentService.init(context);
  }

  build() {
    Tabs({ index: this.currentTabIndex }) {
      // 首页Tab
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.icon_home')))

      // 建议Tab
      TabContent() {
        SuggestionPage()
      }
      .tabBar(this.TabBuilder('购买建议', 1, $r('app.media.ic_suggestion')))

      // 我的器材Tab
      TabContent() {
        MyEquipmentPage()
      }
      .tabBar(this.TabBuilder('我的器材', 2, $r('app.media.ic_mine')))

      // 设置Tab
      TabContent() {
        SettingPage()
      }
      .tabBar(this.TabBuilder('设置', 3, $r('app.media.icon_settings')))
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
        .fillColor(this.currentTabIndex === index ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }
}