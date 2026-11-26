import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Category, CountdownType, CategoryLabels, CategoryColors } from '../models/CountdownModel';
import dataStore from '../services/DataStore';

@Entry
@Component
struct AddCountdown {
  @State title: string = '';
  @State selectedDate: string = '';
  @State note: string = '';
  @State selectedCategory: Category = Category.LIFE;
  @State selectedType: CountdownType = CountdownType.COUNTDOWN;

  private categories: Category[] = [Category.LIFE, Category.STUDY, Category.WORK, Category.ANNIVERSARY];

  // 将 'YYYY-MM-DD' 解析为本地时区的 Date，避免被当作 UTC 午夜解析导致日期偏移
  parseLocalDate(dateStr: string): Date {
    if (!dateStr) {
      return new Date();
    }
    const parts = dateStr.split('-');
    if (parts.length === 3) {
      const year = parseInt(parts[0], 10);
      const month = parseInt(parts[1], 10) - 1;
      const day = parseInt(parts[2], 10);
      return new Date(year, month, day);
    }
    return new Date(dateStr);
  }

  formatDateDisplay(dateStr: string): string {
    if (!dateStr) return '请选择日期';
    const date = this.parseLocalDate(dateStr);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}年${month}月${day}日`;
  }

  openDatePicker(): void {
    DatePickerDialog.show({
      selected: this.selectedDate ? this.parseLocalDate(this.selectedDate) : new Date(),
      onDateAccept: (value: Date) => {
        const year = value.getFullYear();
        const month = String(value.getMonth() + 1).padStart(2, '0');
        const day = String(value.getDate()).padStart(2, '0');
        this.selectedDate = `${year}-${month}-${day}`;
      }
    });
  }

  async handleSave(): Promise<void> {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入标题' });
      return;
    }
    if (!this.selectedDate) {
      promptAction.showToast({ message: '请选择日期' });
      return;
    }

    await dataStore.addCountdown(
      this.title.trim(),
      this.selectedDate,
      this.note.trim(),
      this.selectedCategory,
      this.selectedType
    );

    promptAction.showToast({ message: '添加成功' });
    router.back();
  }

  @Builder
  formSection(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor($r('app.color.text_hint'))
      .width('100%')
      .margin({ bottom: 10 })
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('取消')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
        }
        .backgroundColor(Color.Transparent)
        .height(44)
        .onClick(() => router.back())

        Text('添加倒计时')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Text('保存')
            .fontSize(16)
            .fontColor($r('app.color.primary'))
            .fontWeight(FontWeight.Medium)
        }
        .backgroundColor(Color.Transparent)
        .height(44)
        .onClick(() => this.handleSave())
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.card_background'))

      Scroll() {
        Column() {
          Column() {
            this.formSection('标题')

            TextInput({ placeholder: '输入倒计时标题', text: this.title })
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .placeholderColor($r('app.color.text_hint'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(12)
              .padding({ left: 16, right: 16, top: 14, bottom: 14 })
              .width('100%')
              .onChange((value: string) => {
                this.title = value;
              })
          }
          .width('100%')
          .margin({ bottom: 24 })

          Column() {
            this.formSection('目标日期')

            Row() {
              Text(this.formatDateDisplay(this.selectedDate))
                .fontSize(16)
                .fontColor(this.selectedDate ? $r('app.color.text_primary') : $r('app.color.text_hint'))
                .layoutWeight(1)

              Text('📅')
                .fontSize(22)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor($r('app.color.background'))
            .borderRadius(12)
            .onClick(() => {
              this.openDatePicker();
            })
          }
          .width('100%')
          .margin({ bottom: 24 })

          Column() {
            this.formSection('类型')

            Row() {
              Button('⏱️ 倒计时')
                .fontSize(15)
                .fontColor(this.selectedType === CountdownType.COUNTDOWN ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.selectedType === CountdownType.COUNTDOWN ?
                  $r('app.color.primary') : $r('app.color.background'))
                .borderRadius(12)
                .height(48)
                .layoutWeight(1)
                .onClick(() => {
                  this.selectedType = CountdownType.COUNTDOWN;
                })

              Blank().width(12)

              Button('📈 正计时')
                .fontSize(15)
                .fontColor(this.selectedType === CountdownType.COUNTUP ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.selectedType === CountdownType.COUNTUP ?
                  $r('app.color.primary') : $r('app.color.background'))
                .borderRadius(12)
                .height(48)
                .layoutWeight(1)
                .onClick(() => {
                  this.selectedType = CountdownType.COUNTUP;
                })
            }
            .width('100%')
          }
          .width('100%')
          .margin({ bottom: 24 })

          Column() {
            this.formSection('分类')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categories, (category: Category) => {
                Button(CategoryLabels[category])
                  .fontSize(14)
                  .fontColor(this.selectedCategory === category ? Color.White : $r('app.color.text_primary'))
                  .backgroundColor(this.selectedCategory === category ?
                    CategoryColors[category] : $r('app.color.background'))
                  .borderRadius(20)
                  .height(40)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.selectedCategory = category;
                  })
              })
            }
            .width('100%')
          }
          .width('100%')
          .margin({ bottom: 24 })

          Column() {
            this.formSection('备注（可选）')

            TextArea({ placeholder: '添加备注信息...', text: this.note })
              .fontSize(15)
              .fontColor($r('app.color.text_primary'))
              .placeholderColor($r('app.color.text_hint'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(12)
              .padding(16)
              .width('100%')
              .height(100)
              .onChange((value: string) => {
                this.note = value;
              })
          }
          .width('100%')
          .margin({ bottom: 24 })

          Button('保存倒计时')
            .width('100%')
            .height(52)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius(16)
            .onClick(() => this.handleSave())
        }
        .width('100%')
        .padding(20)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
