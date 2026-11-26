import router from '@ohos.router';

@Entry
@Component
struct PrivacyPolicy {
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

        Text($r('app.string.privacy_policy'))
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
          Text('Nexus Day 隐私政策')
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

          this.section('一、引言')
          this.paragraph('Nexus Day（以下简称"我们"）非常重视用户的隐私保护。本隐私政策旨在向您说明我们如何收集、使用、存储和保护您的个人信息。请您在使用本应用前仔细阅读本隐私政策。')

          this.section('二、信息收集')
          this.paragraph('本应用是一款本地倒计时管理工具，所有数据均存储在您的设备本地，我们不会收集、上传或存储您的任何个人信息到远程服务器。')
          this.paragraph('具体来说，本应用会在本地存储以下信息：')
          this.bulletPoint('您创建的倒计时项目（标题、日期、备注、分类）')
          this.bulletPoint('应用设置偏好')

          this.section('三、权限说明')
          this.paragraph('本应用仅申请必要的最小权限：')
          this.bulletPoint('存储权限：用于在本地保存您的倒计时数据')
          this.paragraph('本应用不会申请或使用以下敏感权限：定位、短信、通讯录、电话、相机等。')

          this.section('四、数据安全')
          this.paragraph('您的所有数据仅存储在您的设备本地，不会上传至任何服务器。我们采用系统级的数据加密存储机制，确保您的数据安全。')
          this.paragraph('如果您卸载本应用，所有本地数据将被删除且无法恢复。')

          this.section('五、数据共享')
          this.paragraph('我们不会与任何第三方共享您的个人信息。本应用不包含任何第三方SDK，不进行任何数据收集或分析。')

          this.section('六、用户权利')
          this.paragraph('您对自己的数据拥有完全控制权：')
          this.bulletPoint('您可以随时查看、编辑或删除您创建的倒计时')
          this.bulletPoint('您可以在设置中清空所有数据')
          this.bulletPoint('您可以随时卸载本应用以删除所有本地数据')

          this.section('七、未成年人保护')
          this.paragraph('本应用不针对13岁以下未成年人提供服务。如果您是未成年人的监护人，请监督其使用本应用。')

          this.section('八、隐私政策更新')
          this.paragraph('我们可能会不时更新本隐私政策。如有重大变更，我们会在应用内通知您。继续使用本应用即表示您同意更新后的隐私政策。')

          this.section('九、联系我们')
          this.paragraph('如果您对本隐私政策有任何疑问，请通过以下方式联系我们：')
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
