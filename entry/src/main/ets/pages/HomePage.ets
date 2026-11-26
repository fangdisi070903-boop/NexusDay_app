import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CountdownItem, Category, CategoryLabels, CategoryColors, CategoryTextColors, CardBackgroundColors, CountdownType, SortMode, getDaysRemaining, calculateDaysForItem, formatDate } from '../models/CountdownModel';
import dataStore from '../services/DataStore';

@Entry
@Component
struct HomePage {
  @State countdowns: CountdownItem[] = [];
  @State selectedCategory: Category | 'all' = 'all';
  @State currentTab: number = 0;
  @State sortMode: SortMode = SortMode.BY_TIME;
  @State cardOpacity: number[] = [];
  @State cardTranslateX: number[] = [];
  @State showDeleteDialog: boolean = false;
  @State deleteTarget: CountdownItem | null = null;
  @State deleteIndex: number = -1;

  aboutToAppear(): void {
    console.info('HomePage aboutToAppear');
    this.sortMode = dataStore.getSortMode();
    this.loadCountdowns();
  }

  onPageShow(): void {
    console.info('HomePage onPageShow');
    this.sortMode = dataStore.getSortMode();
    this.loadCountdowns();
  }

  loadCountdowns(): void {
    console.info('loadCountdowns called');
    let list: CountdownItem[];
    if (this.selectedCategory === 'all') {
      list = dataStore.getCountdowns();
    } else {
      list = dataStore.getCountdownsByCategory(this.selectedCategory);
    }
    console.info('Loaded list count:', list.length);
    this.countdowns = this.sortList(list);
    this.cardOpacity = new Array(this.countdowns.length).fill(1);
    this.cardTranslateX = new Array(this.countdowns.length).fill(0);
    console.info('After sort, countdowns count:', this.countdowns.length);
  }

  sortList(list: CountdownItem[]): CountdownItem[] {
    const pinned = list.filter(item => item.isPinned);
    const unpinned = list.filter(item => !item.isPinned);

    if (this.sortMode === SortMode.BY_TIME) {
      pinned.sort((a, b) => getDaysRemaining(a.targetDate) - getDaysRemaining(b.targetDate));
      unpinned.sort((a, b) => getDaysRemaining(a.targetDate) - getDaysRemaining(b.targetDate));
    }

    return [...pinned, ...unpinned];
  }

  async toggleSortMode(): Promise<void> {
    const newMode = this.sortMode === SortMode.BY_TIME ? SortMode.BY_CUSTOM : SortMode.BY_TIME;
    await dataStore.setSortMode(newMode);
    this.sortMode = newMode;
    this.loadCountdowns();
    promptAction.showToast({
      message: newMode === SortMode.BY_TIME ? '按时间排序' : '自定义排序'
    });
  }

  async addQuickTemplate(title: string, daysFromNow: number, category: Category, type: CountdownType): Promise<void> {
    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + daysFromNow);
    const year = targetDate.getFullYear();
    const month = String(targetDate.getMonth() + 1).padStart(2, '0');
    const day = String(targetDate.getDate()).padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;

    await dataStore.addCountdown(title, dateStr, '', category, type);
    promptAction.showToast({ message: '添加成功' });
    this.loadCountdowns();
  }

  getCountdownDisplay(item: CountdownItem): string {
    return calculateDaysForItem(item);
  }

  async togglePin(item: CountdownItem): Promise<void> {
    await dataStore.togglePin(item.id);
    promptAction.showToast({
      message: item.isPinned ? '已取消置顶' : '已置顶'
    });
    this.loadCountdowns();
  }

  showDeleteConfirm(item: CountdownItem, index: number): void {
    this.deleteTarget = item;
    this.deleteIndex = index;
    this.showDeleteDialog = true;
  }

  async confirmDelete(): Promise<void> {
    if (this.deleteTarget && this.deleteIndex >= 0) {
      this.cardOpacity[this.deleteIndex] = 0;
      await new Promise<void>(resolve => setTimeout(resolve, 200));
      await dataStore.deleteCountdown(this.deleteTarget.id);
      promptAction.showToast({ message: '已删除' });
      this.showDeleteDialog = false;
      this.deleteTarget = null;
      this.deleteIndex = -1;
      this.loadCountdowns();
    }
  }

  cancelDelete(): void {
    if (this.deleteIndex >= 0) {
      this.cardTranslateX[this.deleteIndex] = 0;
    }
    this.showDeleteDialog = false;
    this.deleteTarget = null;
    this.deleteIndex = -1;
  }

  @Builder
  categoryTab(label: string, category: Category | 'all') {
    Text(label)
      .fontSize(13)
      .fontWeight(this.selectedCategory === category ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.selectedCategory === category ? Color.White : $r('app.color.text_secondary'))
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.selectedCategory === category ?
        $r('app.color.primary') : Color.Transparent)
      .borderRadius(20)
      .border({
        width: this.selectedCategory === category ? 0 : 1,
        color: '#E2E8F0'
      })
      .margin({ right: 8 })
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
      .onClick(() => {
        this.selectedCategory = category;
        this.loadCountdowns();
      })
  }

  @Builder
  countdownCard(item: CountdownItem, index: number) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        Button('删除')
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor('#EF4444')
          .borderRadius(12)
          .height(36)
          .padding({ left: 20, right: 20 })
          .margin({ right: 16 })
          .onClick(() => {
            this.showDeleteConfirm(item, index);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

      Column() {
        Row() {
          Text(CategoryLabels[item.category])
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(CategoryTextColors[item.category])
            .backgroundColor(CategoryColors[item.category])
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }

        Blank().height(8)

        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .padding({ right: 24 })

        Blank().height(6)

        Row() {
          Text(formatDate(item.targetDate))
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))

          Blank()

          Text(this.getCountdownDisplay(item))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary'))
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .linearGradient({
        angle: 135,
        colors: [
          [CardBackgroundColors[item.category][0], 0],
          [CardBackgroundColors[item.category][1], 1]
        ]
      })
      .borderRadius(16)
      .border({
        width: item.isPinned ? 2 : 0,
        color: $r('app.color.primary')
      })
      .shadow({ radius: 8, color: '#0A000000', offsetX: 0, offsetY: 2 })
      .translate({ x: this.cardTranslateX[index] })
      .opacity(this.cardOpacity[index])
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
      .onClick(() => {
        router.pushUrl({
          url: 'pages/EditCountdown',
          params: { id: item.id }
        });
      })
      .gesture(
        LongPressGesture({ repeat: false })
          .onAction(() => {
            this.togglePin(item);
          })
      )

      if (item.isPinned) {
        Text('⭐')
          .fontSize(18)
          .margin({ top: 14, right: 14 })
      } else {
        Text('📌')
          .fontSize(16)
          .fontColor($r('app.color.text_hint'))
          .margin({ top: 14, right: 14 })
          .opacity(0.3)
      }
    }
    .width('100%')
    .height(110)
    .clip(true)
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionUpdate((event: GestureEvent) => {
          if (event.offsetX < 0) {
            this.cardTranslateX[index] = Math.max(event.offsetX, -80);
          } else {
            this.cardTranslateX[index] = Math.min(event.offsetX, 0);
          }
        })
        .onActionEnd((event: GestureEvent) => {
          if (this.cardTranslateX[index] < -40) {
            this.cardTranslateX[index] = -80;
          } else {
            this.cardTranslateX[index] = 0;
          }
        })
    )
    .margin({ bottom: 12 })
  }

  @Builder
  emptyState() {
    Column() {
      Column() {
        Text('⏰')
          .fontSize(48)
          .margin({ bottom: 12 })

        Text('还没有添加倒计时')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 6 })

        Text('点击右上角 + 按钮\n记录你的第一个重要日子')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .lineHeight(20)
          .margin({ bottom: 24 })

        Column() {
          Text('快速添加')
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
            .width('100%')
            .margin({ bottom: 12 })

          Row() {
            Button('🎂 生日')
              .fontSize(13)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(12)
              .layoutWeight(1)
              .height(40)
              .onClick(() => {
                this.addQuickTemplate('我的生日', 30, Category.LIFE, CountdownType.COUNTDOWN);
              })

            Blank().width(8)

            Button('📚 考试')
              .fontSize(13)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(12)
              .layoutWeight(1)
              .height(40)
              .onClick(() => {
                this.addQuickTemplate('期末考试', 14, Category.STUDY, CountdownType.COUNTDOWN);
              })
          }
          .width('100%')

          Row() {
            Button('✈️ 旅行')
              .fontSize(13)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(12)
              .layoutWeight(1)
              .height(40)
              .margin({ top: 8 })
              .onClick(() => {
                this.addQuickTemplate('旅行出发', 60, Category.LIFE, CountdownType.COUNTDOWN);
              })

            Blank().width(8)

            Button('💰 发薪')
              .fontSize(13)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(12)
              .layoutWeight(1)
              .height(40)
              .margin({ top: 8 })
              .onClick(() => {
                this.addQuickTemplate('发薪日', 15, Category.WORK, CountdownType.COUNTDOWN);
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: 40 })
  }

  build() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text('Nexus Day')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary'))

            Text('你的时间枢纽')
              .fontSize(11)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 1 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row() {
            Button() {
              Text(this.sortMode === SortMode.BY_TIME ? '⏱️' : '📌')
                .fontSize(18)
            }
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor($r('app.color.background'))
            .margin({ right: 8 })
            .onClick(() => {
              this.toggleSortMode();
            })

            Button() {
              Text('+')
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .width(44)
            .height(44)
            .borderRadius(22)
            .backgroundColor($r('app.color.primary'))
            .shadow({ radius: 8, color: '#403B82F6', offsetX: 0, offsetY: 4 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddCountdown' });
            })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 14, bottom: 12 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))

      Column() {
        Scroll() {
          Row() {
            this.categoryTab('全部', 'all')
            this.categoryTab('生活', Category.LIFE)
            this.categoryTab('学习', Category.STUDY)
            this.categoryTab('工作', Category.WORK)
            this.categoryTab('纪念日', Category.ANNIVERSARY)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 6, bottom: 6 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))
      .padding({ top: 6, bottom: 6 })
      .border({ width: { bottom: 1 }, color: $r('app.color.divider') })

      if (this.countdowns.length === 0) {
        this.emptyState()
      } else {
        List() {
          ForEach(this.countdowns, (item: CountdownItem, index: number) => {
            ListItem() {
              this.countdownCard(item, index)
            }
          }, (item: CountdownItem) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .listDirection(Axis.Vertical)
        .lanes(1)
        .margin({ left: 20, right: 20 })
        .padding({ top: 12, bottom: 12 })
      }

      Row() {
        Column() {
          Text('🏠')
            .fontSize(20)
          Text('首页')
            .fontSize(10)
            .fontColor($r('app.color.primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: 1 })
        }
        .layoutWeight(1)
        .padding({ top: 5, bottom: 5 })
        .onClick(() => {
          this.currentTab = 0;
        })

        Column() {
          Text('📜')
            .fontSize(20)
          Text('历史')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 1 })
        }
        .layoutWeight(1)
        .padding({ top: 5, bottom: 5 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/HistoryToday' });
        })

        Column() {
          Text('⚙️')
            .fontSize(20)
          Text('设置')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 1 })
        }
        .layoutWeight(1)
        .padding({ top: 5, bottom: 5 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Settings' });
        })
      }
      .width('100%')
      .height(52)
      .backgroundColor($r('app.color.card_background'))
      .border({ width: { top: 1 }, color: $r('app.color.divider') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .bindSheet($$this.showDeleteDialog, this.deleteDialogBuilder(), {
      height: 200,
      backgroundColor: $r('app.color.card_background'),
      dragBar: false
    })
  }

  @Builder
  deleteDialogBuilder() {
    Column() {
      Text('⚠️')
        .fontSize(40)
        .margin({ top: 16, bottom: 12 })

      Text('确定要删除这个倒计时吗？')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 8 })

      Text('删除后无法恢复')
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
            this.cancelDelete();
          })

        Blank().width(12)

        Button('删除')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#EF4444')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.confirmDelete();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
  }
}
