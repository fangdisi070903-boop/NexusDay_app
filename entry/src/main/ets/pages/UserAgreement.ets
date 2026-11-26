import router from '@ohos.router';

@Entry
@Component
struct UserAgreement {
  build() {
    Column() {
      Row() {
        Button() {
          Text('‹')
            .fontSize(24)
            .fontColor($r('app.color.text_primary'))
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text($r('app.string.user_agreement'))
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40)
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 12, bottom: 12 })

      Scroll() {
        Column() {
          Text('Nexus Day 用户协议')
            .fontSize($r('app.float.subtitle_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .margin({ bottom: 16 })

          Text('更新日期：2024年1月1日')
            .fontSize($r('app.float.caption_font_size'))
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ bottom: 24 })

          this.section('一、协议说明')
          this.paragraph('欢迎使用 Nexus Day！本用户协议（以下简称"本协议"）是您与 Nexus Day 应用（以下简称"本应用"）之间的法律协议。请您在使用本应用前仔细阅读本协议。')
          this.paragraph('使用本应用即表示您同意本协议的所有条款。如果您不同意本协议的任何内容，请立即停止使用本应用。')

          this.section('二、服务说明')
          this.paragraph('Nexus Day 是一款倒计时管理工具，帮助用户记录和管理生活中的重要时间节点。')
          this.paragraph('本应用提供以下功能：')
          this.bulletPoint('创建、编辑、删除倒计时项目')
          this.bulletPoint('支持倒计时和正计时两种模式')
          this.bulletPoint('按分类管理倒计时（生活、学习、工作、纪念日）')
          this.bulletPoint('本地数据存储，无需联网')

          this.section('三、用户责任')
          this.paragraph('您同意遵守以下规定：')
          this.bulletPoint('合法使用本应用，不用于任何违法目的')
          this.bulletPoint('不尝试破解、反编译或修改本应用')
          this.bulletPoint('不利用本应用干扰或破坏网络服务')
          this.bulletPoint('自行备份重要数据，本应用不对数据丢失负责')

          this.section('四、知识产权')
          this.paragraph('本应用的所有内容，包括但不限于软件、界面设计、图标、文字等，均受知识产权法律保护。未经授权，您不得复制、修改、传播或用于商业目的。')

          this.section('五、免责声明')
          this.paragraph('在法律允许的范围内，本应用不承担以下责任：')
          this.bulletPoint('因设备故障、系统更新等导致的数据丢失')
          this.bulletPoint('因用户操作不当造成的任何损失')
          this.bulletPoint('因不可抗力导致的服务中断')

          this.section('六、服务变更')
          this.paragraph('我们保留随时修改或终止服务的权利，恕不另行通知。如有重大变更，我们会在应用内通知用户。')

          this.section('七、协议修改')
          this.paragraph('我们可能会不时更新本协议。继续使用本应用即表示您同意更新后的协议。')

          this.section('八、法律适用')
          this.paragraph('本协议受中华人民共和国法律管辖。如发生争议，双方应友好协商解决；协商不成的，可向本应用所在地人民法院提起诉讼。')

          this.section('九、联系我们')
          this.paragraph('如果您对本协议有任何疑问，请通过以下方式联系我们：')
          this.paragraph('邮箱：support@nexusday.app')

          Text('')
            .height(32)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  section(title: string) {
    Text(title)
      .fontSize($r('app.float.body_font_size'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
      .margin({ top: 20, bottom: 8 })
  }

  @Builder
  paragraph(text: string) {
    Text(text)
      .fontSize($r('app.float.body_font_size'))
      .fontColor($r('app.color.text_secondary'))
      .lineHeight(24)
      .width('100%')
      .margin({ bottom: 8 })
  }

  @Builder
  bulletPoint(text: string) {
    Row() {
      Text('•')
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ right: 8 })

      Text(text)
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(24)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: 4 })
  }
}
