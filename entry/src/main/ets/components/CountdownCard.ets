import router from '@ohos.router';
import { CountdownItem, Category, CountdownType, CountdownTime, calculateCountdown, calculateDaysForItem, formatDate, CategoryLabels, CategoryColors } from '../models/CountdownModel';

@Component
export struct CountdownCard {
  item: CountdownItem | null = null;
  @State countdown: CountdownTime = { days: 0, hours: 0, minutes: 0, seconds: 0, isPast: false };
  @State opacityValue: number = 0;
  @State scaleValue: number = 0.95;
  @State daysScale: number = 1;
  private timer: number = -1;
  private prevDays: number = -1;
  onTogglePin?: () => void;

  aboutAppear(): void {
    if (this.item) {
      this.updateCountdown();
      this.timer = setInterval(() => {
        this.updateCountdown();
      }, 1000);
    }
    setTimeout(() => {
      this.opacityValue = 1;
      this.scaleValue = 1;
    }, 50);
  }

  aboutDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  updateCountdown(): void {
    if (!this.item) return;
    const result = calculateCountdown(this.item.targetDate, this.item.type);
    if (this.prevDays !== -1 && this.prevDays !== result.days) {
      this.daysScale = 1.15;
      setTimeout(() => {
        this.daysScale = 1;
      }, 150);
    }
    this.prevDays = this.countdown.days;
    this.countdown = {
      days: result.days,
      hours: result.hours,
      minutes: result.minutes,
      seconds: result.seconds,
      isPast: result.isPast
    };
  }

  build() {
    Column() {
      if (this.item) {
        Row() {
          Row() {
            Text(CategoryLabels[this.item.category])
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor(CategoryColors[this.item.category])
              .borderRadius(10)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })

            if (this.item.isPinned) {
              Text('📌')
                .fontSize(12)
                .margin({ left: 6 })
            }
          }

          Blank()

          if (this.onTogglePin) {
            Text(this.item.isPinned ? '取消置顶' : '置顶')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
              .onClick(() => {
                if (this.onTogglePin) {
                  this.onTogglePin();
                }
              })
          }
        }
        .width('100%')
        .margin({ bottom: 10 })

        Row() {
          Column() {
            Text(this.item.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(formatDate(this.item.targetDate))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })

            if (this.item.note) {
              Text(this.item.note)
                .fontSize(12)
                .fontColor($r('app.color.text_hint'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
                .margin({ top: 2 })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ right: 16 })

          Column() {
            Text(calculateDaysForItem(this.item))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.item.type === CountdownType.COUNTUP ?
                $r('app.color.success') :
                (this.countdown.isPast ? $r('app.color.danger') : $r('app.color.primary')))
              .scale({ x: this.daysScale, y: this.daysScale })
              .animation({
                duration: 150,
                curve: Curve.EaseOut
              })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Text(`${this.countdown.hours.toString().padStart(2, '0')}时`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))

          Text(' : ')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))

          Text(`${this.countdown.minutes.toString().padStart(2, '0')}分`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))

          Text(' : ')
            .fontSize(13)
            .fontColor($r('app.color.text_hint'))

          Text(`${this.countdown.seconds.toString().padStart(2, '0')}秒`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 12 })
        .padding({ top: 12 })
        .border({ width: { top: 1 }, color: $r('app.color.divider') })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .border({
      width: this.item?.isPinned ? 2 : 0,
      color: this.item?.isPinned ? $r('app.color.primary') : Color.Transparent
    })
    .shadow({ radius: 6, color: '#15000000', offsetX: 0, offsetY: 2 })
    .opacity(this.opacityValue)
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
    .onClick(() => {
      if (this.item) {
        router.pushUrl({
          url: 'pages/EditCountdown',
          params: { id: this.item.id }
        });
      }
    })
  }
}
