import router from '@ohos.router';

@Entry
@Component
struct AboutUs {
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

        Text('关于我们')
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
          Column() {
            Row() {
              Text('📅')
                .fontSize(56)
              Text('⏰')
                .fontSize(56)
                .margin({ left: -8 })
            }
            .margin({ bottom: 20 })

            Text('Nexus Day')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary'))
              .margin({ bottom: 8 })

            Text('你的时间枢纽')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 6 })

            Text('每个倒计时是你时间线的连接点')
              .fontSize(14)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .padding({ top: 40, bottom: 32 })

          Column() {
            Text('关于应用')
              .fontSize(13)
              .fontColor($r('app.color.text_hint'))
              .width('100%')
              .margin({ bottom: 12 })

            Text('Nexus Day 是一款简洁优雅的倒计时管理工具，帮助你记录和管理生活中所有重要的时间节点。无论是考试、生日、旅行还是纪念日，都在这里汇聚成你的时间枢纽。')
              .fontSize(15)
              .fontColor($r('app.color.text_primary'))
              .lineHeight(26)
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ left: 16, right: 16 })

          Column() {
            Text('核心功能')
              .fontSize(13)
              .fontColor($r('app.color.text_hint'))
              .width('100%')
              .margin({ bottom: 12 })

            Row() {
              Text('✓')
                .fontSize(16)
                .fontColor($r('app.color.primary'))
                .margin({ right: 12 })

              Text('创建和管理倒计时项目')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .margin({ bottom: 10 })

            Row() {
              Text('✓')
                .fontSize(16)
                .fontColor($r('app.color.primary'))
                .margin({ right: 12 })

              Text('支持倒计时和正计时两种模式')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .margin({ bottom: 10 })

            Row() {
              Text('✓')
                .fontSize(16)
                .fontColor($r('app.color.primary'))
                .margin({ right: 12 })

              Text('按分类管理（生活/学习/工作/纪念日）')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .margin({ bottom: 10 })

            Row() {
              Text('✓')
                .fontSize(16)
                .fontColor($r('app.color.primary'))
                .margin({ right: 12 })

              Text('本地数据存储，无需联网')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .margin({ bottom: 10 })

            Row() {
              Text('✓')
                .fontSize(16)
                .fontColor($r('app.color.primary'))
                .margin({ right: 12 })

              Text('支持深色模式')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ left: 16, right: 16, top: 16 })

          Column() {
            Row() {
              Text('版本')
                .fontSize(15)
                .fontColor($r('app.color.text_secondary'))

              Blank()

              Text('v1.0.0')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding(16)

            Divider().color($r('app.color.divider'))

            Row() {
              Text('更新日期')
                .fontSize(15)
                .fontColor($r('app.color.text_secondary'))

              Blank()

              Text('2026年4月')
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ left: 16, right: 16, top: 16 })

          Column() {
            Text('© 2026 Nexus Day Team')
              .fontSize(13)
              .fontColor($r('app.color.text_hint'))

            Text('All Rights Reserved')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 4 })
          }
          .width('100%')
          .padding({ top: 32, bottom: 24 })
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
