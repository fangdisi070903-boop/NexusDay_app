import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ConfigurationConstant } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import dataStore from '../services/DataStore';

@Entry
@Component
struct Settings {
  @State showClearDialog: boolean = false;
  @State countdownCount: number = 0;
  @State isDarkMode: boolean = false;
  @State switchScale: number = 1;
  private context: common.UIAbilityContext | null = null;

  aboutToAppear(): void {
    this.countdownCount = dataStore.getCountdowns().length;
    this.context = getContext(this) as common.UIAbilityContext;
    this.checkColorMode();
  }

  checkColorMode(): void {
    try {
      const config = this.context?.config;
      if (config) {
        this.isDarkMode = config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      }
    } catch (error) {
      console.error('Check color mode failed:', error);
    }
  }

  toggleDarkMode(): void {
    this.switchScale = 0.9;
    setTimeout(() => {
      this.switchScale = 1;
    }, 100);

    try {
      const applicationContext = this.context?.getApplicationContext();
      if (applicationContext) {
        const newMode = this.isDarkMode ?
          ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT :
          ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        applicationContext.setColorMode(newMode);
        this.isDarkMode = !this.isDarkMode;
        promptAction.showToast({
          message: this.isDarkMode ? '已切换到深色模式' : '已切换到浅色模式'
        });
      }
    } catch (error) {
      console.error('Toggle dark mode failed:', error);
      promptAction.showToast({ message: '切换主题失败' });
    }
  }

  async handleClearData(): Promise<void> {
    await dataStore.clearAllData();
    this.countdownCount = 0;
    promptAction.showToast({ message: '数据已清空' });
    this.showClearDialog = false;
  }

  @Builder
  sectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor($r('app.color.text_hint'))
      .width('100%')
      .padding({ left: 4, top: 20, bottom: 10 })
  }

  @Builder
  settingItem(icon: string, title: string, subtitle: string, showArrow: boolean, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(22)
        .margin({ right: 14 })

      Column() {
        Text(title)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        if (subtitle) {
          Text(subtitle)
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .width('100%')
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (showArrow) {
        Text('›')
          .fontSize(20)
          .fontColor($r('app.color.text_hint'))
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor($r('app.color.card_background'))
    .onClick(onClick)
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('‹')
            .fontSize(28)
            .fontColor($r('app.color.text_primary'))
        }
        .backgroundColor(Color.Transparent)
        .width(44)
        .height(44)
        .onClick(() => router.back())

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(44)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.card_background'))

      Scroll() {
        Column() {
          this.sectionHeader('外观设置')

          Column() {
            Row() {
              Text('🌙')
                .fontSize(22)
                .margin({ right: 14 })

              Column() {
                Text('深色模式')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')

                Text(this.isDarkMode ? '已开启' : '已关闭')
                  .fontSize(12)
                  .fontColor($r('app.color.text_hint'))
                  .width('100%')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
                .selectedColor($r('app.color.primary'))
                .scale({ x: this.switchScale, y: this.switchScale })
                .animation({
                  duration: 100,
                  curve: Curve.EaseOut
                })
                .onChange((isOn: boolean) => {
                  this.toggleDarkMode();
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)
          }
          .width('100%')

          this.sectionHeader('关于')

          Column() {
            this.settingItem('📱', '关于我们', '了解 Nexus Day', true, () => {
              router.pushUrl({ url: 'pages/AboutUs' });
            })

            Divider().color($r('app.color.divider')).margin({ left: 52 })

            this.settingItem('📋', '隐私政策', '保护您的个人信息', true, () => {
              router.pushUrl({ url: 'pages/PrivacyPolicy' });
            })

            Divider().color($r('app.color.divider')).margin({ left: 52 })

            this.settingItem('📄', '用户协议', '使用条款与条件', true, () => {
              router.pushUrl({ url: 'pages/UserAgreement' });
            })

            Divider().color($r('app.color.divider')).margin({ left: 52 })

            this.settingItem('🏷️', '版本信息', 'v1.0.0', false, () => {})
          }
          .width('100%')
          .borderRadius(16)
          .clip(true)
          .backgroundColor($r('app.color.card_background'))

          this.sectionHeader('数据管理')

          Column() {
            Row() {
              Text('🗑️')
                .fontSize(22)
                .margin({ right: 14 })

              Column() {
                Text('清空所有数据')
                  .fontSize(16)
                  .fontColor('#EF4444')
                  .width('100%')

                Text(`当前有 ${this.countdownCount} 个倒计时`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_hint'))
                  .width('100%')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)
            .onClick(() => {
              this.showClearDialog = true;
            })
          }
          .width('100%')

          Column() {
            Text('Nexus Day')
              .fontSize(14)
              .fontColor($r('app.color.text_hint'))

            Text('你的时间枢纽')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 4 })

            Text('© 2026 Nexus Day Team')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 32, bottom: 24 })
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      Row() {
        Column() {
          Text('🏠')
            .fontSize(24)
          Text('首页')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          router.back();
        })

        Column() {
          Text('📜')
            .fontSize(24)
          Text('历史')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/HistoryToday' });
        })

        Column() {
          Text('⚙️')
            .fontSize(24)
          Text('设置')
            .fontSize(12)
            .fontColor($r('app.color.primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .height(68)
      .backgroundColor($r('app.color.card_background'))
      .border({ width: { top: 1 }, color: $r('app.color.divider') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .bindSheet($$this.showClearDialog, this.clearDialogBuilder(), {
      height: 200,
      backgroundColor: $r('app.color.card_background'),
      dragBar: false
    })
  }

  @Builder
  clearDialogBuilder() {
    Column() {
      Text('⚠️')
        .fontSize(40)
        .margin({ top: 20, bottom: 12 })

      Text('确定要清空所有数据吗？')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 8 })

      Text('此操作不可恢复，所有倒计时将被删除')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 20 })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r('app.color.background'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(12)
          .onClick(() => {
            this.showClearDialog = false;
          })

        Blank().width(12)

        Button('确认清空')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#EF4444')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.handleClearData();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
  }
}
