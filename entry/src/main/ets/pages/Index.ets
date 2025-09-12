import { WelcomePage } from './WelcomePage';
import { SuggestionPage } from './SuggestionPage';
import { MyEquipmentPage } from './MyEquipmentPage';
import { ComparePage } from './ComparePage';
import { myEquipmentService } from '../service/MyEquipmentService';
import { favoriteService } from '../service/FavoriteService';
import { common } from '@kit.AbilityKit';
import app from '@system.app';
import { promptAction } from '@kit.ArkUI';
import { SampleGalleryPage } from './SampleGalleryPage';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @StorageProp('switchToTab') @Watch('onSwitchToTab') switchToTab: number = -1;
  private tabsController: TabsController = new TabsController();
  private lastExitTime: number = -1;               // 记录点击时间

  aboutToAppear() {
    // 初始化服务
    const context = getContext(this) as common.UIAbilityContext;
    myEquipmentService.init(context);
    favoriteService.init(context);
  }

  // 监听tab切换
  onSwitchToTab() {
    if (this.switchToTab >= 0 && this.switchToTab <= 4) {
      this.currentTabIndex = this.switchToTab;
      this.tabsController.changeIndex(this.switchToTab);
      // 重置switchToTab值
      AppStorage.setOrCreate('switchToTab', -1);
    }
  }

  build() {
    Tabs({ index: this.currentTabIndex, controller: this.tabsController }) {
      // 首页Tab
      TabContent() {
        WelcomePage()
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.icon_home')))

      // 知识库Tab
      TabContent() {
        SuggestionPage()
      }
      .tabBar(this.TabBuilder('知识库', 1, $r('app.media.icon_knowledge')))

      // 器材对比Tab
      TabContent() {
        ComparePage()
      }
      .tabBar(this.TabBuilder('器材对比', 2, $r('app.media.icon_compare')))

      // 样张Tab
      TabContent() {
        SampleGalleryPage()
      }
      .tabBar(this.TabBuilder('样张库', 3, $r('app.media.icon_sample')))

      // 我的器材Tab
      TabContent() {
        MyEquipmentPage()
      }
      .tabBar(this.TabBuilder('我的', 4, $r('app.media.ic_mine')))
    }
    .width('100%')
    .height('100%')
    .scrollable(false)
    .barBackgroundColor($r('app.color.tab_bar_bg'))
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentTabIndex = index;
      console.log('current tab is :' + index)
      if (index == 0) {
        // 当首页tab显示时，刷新收藏状态
        AppStorage.setOrCreate('refreshHomeFavorites', Date.now());
      }
    })

  }

  @Builder
  TabBuilder(title: string, index: number, icon: Resource) {
    Column() {
      // Icon区域，向上扩展
      Column() {
        Image(icon)
          .width(index == 2 ? 36 : 24)
          .height(index == 2 ? 36 : 24)
          .fillColor(this.currentTabIndex === index ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      
      // 文字区域，固定在底部
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
        .margin({ top: 4, bottom: 8 })
    }
    .width('100%')
    .height(56)
    .alignItems(HorizontalAlign.Center)
  }

  onBackPress(): boolean | void {
    if (-1 == this.lastExitTime) {
      this.lastExitTime = new Date().getTime();
      promptAction.showToast({
        message: "再按一次退出",
        alignment: Alignment.Center
      })
      return true;
    } else {
      let currentTime = new Date().getTime();
      if(currentTime - this.lastExitTime > 2000) {
        promptAction.showToast({
          message: "再按一次退出",
          alignment: Alignment.Center
        })
        this.lastExitTime = currentTime;
        return true;
      } else {
        app.terminate();
      }
    }
    return false;
  }
}