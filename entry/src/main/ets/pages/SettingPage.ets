import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import { setDarkColorMode, setLightColorMode, setAutoColorMode } from '../viewmodel/ColorModeChangeFunctions';
import { common } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

@Component
export struct SettingPage {
  @State showAboutSheet: boolean = false;
  @State showFeedbackSheet: boolean = false;
  @State feedbackText: string = '';
  @State versionName: string = '';
  @State userName: string = '';
  @State userLevel: string = 'LV1';
  private context = getContext(this) as common.UIAbilityContext;
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false;
  @State isFollowSystemSetting: boolean = false;
  @StorageProp('currentColorMode') currentColorMode: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 36;

  async aboutToAppear() {
    // 生成随机用户名
    const randomNum = Math.floor(Math.random() * 9000) + 1000; // 生成1000-9999的随机数
    this.userName = `数码爱好者${randomNum}`;

    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
    }).catch((error: BusinessError) => {
      console.error("get bundleInfo failed,error is " + error)
    })
  }

  aboutToDisappear(): void {
    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
    // 跟随系统设置不持久化，每次启动都重置为false
  }

  // 跳转到我的收藏页面
  private navigateToFavorites() {
    router.pushUrl({
      url: 'pages/FavoritePage'
    }).catch((error: Error) => {
      console.error('跳转到收藏页面失败:', error.message);
      promptAction.showToast({
        message: '跳转失败，请重试',
        duration: 2000
      });
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.surface_color'))
      .shadow({
        radius: 2,
        color: $r('app.color.shadow_color'),
        offsetX: 0,
        offsetY: 1
      })

      // 可滚动内容区域
      Scroll() {
        Column() {
          // 用户登录状态
          Row() {
            // 头像
            Image($r('app.media.ic_mine'))
              .width(50)
              .height(50)
              .borderRadius(25)
              .margin({ right: 16 })
              .backgroundColor('#FFFFFF')
              .padding(10)
              .shadow({
                radius: 4,
                color: 'rgba(0,0,0,0.1)',
                offsetX: 0,
                offsetY: 2
              })

            // 用户信息
            Column() {
              Text(this.userName)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ bottom: 6 })

              Text('数码摄影爱好者')
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.8)')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 等级标识
            Text(this.userLevel)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_color'))
              .backgroundColor('#FFFFFF')
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6
              })
              .borderRadius(12)
              .shadow({
                radius: 2,
                color: 'rgba(0,0,0,0.1)',
                offsetX: 0,
                offsetY: 1
              })
          }
          .padding({
            left: 20,
            right: 20,
            top: 20,
            bottom: 20
          })
          .linearGradient({
            angle: 135,
            colors: [[$r('app.color.brand_color'), 0.0], ['#F36D40', 1.0]]
          })
          .borderRadius(16)
          .margin({ top: 20, left: 24, right: 24, bottom: 20 })
          .shadow({
            radius: 8,
            color: 'rgba(102, 126, 234, 0.3)',
            offsetX: 0,
            offsetY: 4
          })

          // 设置内容
          Column() {
            // 主题分组
            Column() {
              // 主题设置卡片（包含标题）
              Column() {
                // 分组标题
                Text('主题')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: 16, top: 16, bottom: 8 })

                // 深色模式设置
                Row() {
                  Image($r('app.media.ic_dark_mode'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('深色模式')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('保护眼睛，节省电量')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Toggle({ type: ToggleType.Switch, isOn: this.enableDarkMode })
                    .selectedColor($r('app.color.brand_color'))
                    .switchPointColor('#FFFFFF')
                    .enabled(!this.isFollowSystemSetting)
                    .onChange(async (isOn: boolean) => {
                      // 关闭所有弹窗，防止模式切换时状态异常
                      this.showAboutSheet = false;
                      this.showFeedbackSheet = false;

                      if (isOn) {
                        setDarkColorMode(this.context);
                      } else {
                        setLightColorMode(this.context);
                      }
                      AppStorage.setOrCreate('enableDarkMode', isOn);
                    })
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })

                // 分隔线
                Divider()
                  .color($r('app.color.divider_color'))
                  .strokeWidth(0.5)
                  .margin({ left: 48, right: 16 })

                // 跟随系统设置
                Row() {
                  Image($r('app.media.ic_follow_system'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('跟随系统')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('自动适配系统主题设置')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Toggle({ type: ToggleType.Switch, isOn: this.isFollowSystemSetting })
                    .selectedColor($r('app.color.brand_color'))
                    .switchPointColor('#FFFFFF')
                    .enabled(!this.enableDarkMode)
                    .onChange((isOn: boolean) => {
                      this.isFollowSystemSetting = isOn;
                      if (isOn) {
                        // 启用跟随系统时，禁用深色模式手动控制
                        AppStorage.setOrCreate('enableDarkMode', false);
                        setAutoColorMode(this.context);
                      } else {
                        // 关闭跟随系统时，根据当前深色模式状态设置
                        if (this.enableDarkMode) {
                          setDarkColorMode(this.context);
                        } else {
                          setLightColorMode(this.context);
                        }
                      }
                    })
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .shadow({
                radius: 2,
                color: $r('app.color.shadow_color'),
                offsetX: 0,
                offsetY: 1
              })
            }
            .width('100%')
            .margin({ top: 24 })

            // 其他分组
            Column() {
              // 其他设置卡片（包含标题）
              Column() {
                // 分组标题
                Text('其他')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: 16, top: 16, bottom: 8 })

                // 检查更新
                Row() {
                  Image($r('app.media.ic_update'))
                    .width(24)
                    .height(24)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('检查更新')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('获取最新功能和修复')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Image($r('app.media.ic_arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.tertiary_text_color'))
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })
                .onClick(() => {
                  AlertDialog.show({
                    title: '检查更新',
                    message: '当前已是最新版本',
                    primaryButton: {
                      value: '确定',
                      action: () => {
                      }
                    }
                  });
                })

                // 分隔线
                Divider()
                  .color($r('app.color.divider_color'))
                  .strokeWidth(0.5)
                  .margin({ left: 52, right: 16 })

                // 官方QQ群
                Row() {
                  Image($r('app.media.ic_qq'))
                    .width(24)
                    .height(24)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('官方QQ群')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('加入社区，交流摄影心得')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Image($r('app.media.ic_arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.tertiary_text_color'))
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })
                .onClick(() => {
                  let groupNum = '1074915128'
                  this.context.openLink('mqqapi://card/show_pslcard?src_type=internal&version=1&uin=' + groupNum +
                    '&card_type=group&source=qrcode')
                })

                // 分隔线
                Divider()
                  .color($r('app.color.divider_color'))
                  .strokeWidth(0.5)
                  .margin({ left: 52, right: 16 })

                // 问题反馈
                Row() {
                  Image($r('app.media.ic_feedback'))
                    .width(24)
                    .height(24)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('问题反馈')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('遇到问题？告诉我们')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Image($r('app.media.ic_arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.tertiary_text_color'))
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })
                .onClick(() => {
                  this.showFeedbackSheet = true;
                })
                .bindSheet($$this.showFeedbackSheet, this.FeedbackSheet(), {
                  height: 350,
                  dragBar: true,
                  showClose: false,
                  backgroundColor: $r('app.color.surface_color'),
                  onDisappear: () => {
                    // 移除状态重置，避免与深色模式切换冲突
                  }
                })

                // 分隔线
                Divider()
                  .color($r('app.color.divider_color'))
                  .strokeWidth(0.5)
                  .margin({ left: 52, right: 16 })

                // 给个好评
                Row() {
                  Image($r('app.media.ic_star'))
                    .width(24)
                    .height(24)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('给个好评')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('您的支持是我们的动力')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Image($r('app.media.ic_arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.tertiary_text_color'))
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })
                .onClick(() => {
                  promptAction.showToast({
                    message: '感谢您的支持！',
                    duration: 2000
                  });
                })

                // 分隔线
                Divider()
                  .color($r('app.color.divider_color'))
                  .strokeWidth(0.5)
                  .margin({ left: 52, right: 16 })

                // 关于应用
                Row() {
                  Image($r('app.media.ic_info'))
                    .width(24)
                    .height(24)
                    .fillColor($r('app.color.primary_text_color'))
                    .margin({ right: 12 })

                  Column() {
                    Text('关于应用')
                      .fontSize(16)
                      .fontColor($r('app.color.primary_text_color'))
                      .fontWeight(FontWeight.Medium)

                    Text('版本信息和开发团队')
                      .fontSize(14)
                      .fontColor($r('app.color.secondary_text_color'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Image($r('app.media.ic_arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor($r('app.color.tertiary_text_color'))
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })
                .onClick(() => {
                  this.showAboutSheet = true;
                })
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .shadow({
                radius: 2,
                color: $r('app.color.shadow_color'),
                offsetX: 0,
                offsetY: 1
              })
            }
            .width('100%')
            .margin({ top: 24 })

          }
          .width('100%')
          .padding({ left: 24, right: 24 })
        }
        .padding({ bottom: 100 }) // 避免底部tab遮挡
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
    .bindSheet($$this.showAboutSheet, this.AboutSheet(), {
      height: 400,
      dragBar: true,
      showClose: false,
      backgroundColor: $r('app.color.surface_color'),
      onDisappear: () => {
        // 移除状态重置，避免与深色模式切换冲突
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
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 应用图标
      Image($r('app.media.startIcon'))
        .width(80)
        .height(80)
        .borderRadius(16)
        .margin({ bottom: 16 })

      // 应用信息
      Column() {
        Text('数码回忆')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })

        Text($r('app.string.version', '版本号', this.versionName))
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ bottom: 8 })

        Text('一款专为数码相机爱好者打造的应用')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

        Text('记录每一台相机的故事，珍藏数码时代的美好回忆')
          .fontSize(12)
          .fontColor($r('app.color.secondary_text_color'))
          .textAlign(TextAlign.Center)
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()

      // 版权信息
      Text('© 2025 数码回忆团队')
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  FeedbackSheet() {
    Column() {
      // Sheet标题
      Text('问题反馈')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 输入提示
      Text('请描述您遇到的问题或建议')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 16 })
        .alignSelf(ItemAlign.Start)

      // 输入框
      TextArea({
        placeholder: '请输入您的问题或建议...',
        text: this.feedbackText
      })
        .width('100%')
        .height(120)
        .fontSize(14)
        .fontColor($r('app.color.primary_text_color'))
        .backgroundColor($r('app.color.input_background_color'))
        .borderRadius(8)
        .padding(12)
        .maxLength(100)
        .onChange((value: string) => {
          this.feedbackText = value;
        })
        .margin({ bottom: 8 })

      // 字数统计
      Text(`${this.feedbackText.length}/100`)
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .alignSelf(ItemAlign.End)
        .margin({ bottom: 24 })

      // 提交按钮
      Button('提交反馈')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(8)
        .enabled(this.feedbackText.trim().length > 0)
        .opacity(this.feedbackText.trim().length > 0 ? 1 : 0.5)
        .onClick(() => {
          if (this.feedbackText.trim().length > 0) {
            promptAction.showToast({
              message: '已提交',
              duration: 2000
            });
            this.feedbackText = '';
            this.showFeedbackSheet = false;
          }
        })

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}