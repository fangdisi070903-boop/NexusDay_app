import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface HistoryEvent {
  year: number;
  title: string;
  description: string;
  category: string;
}

@Entry
@Component
struct HistoryToday {
  @State historyEvents: HistoryEvent[] = [];
  @State todayDate: string = '';
  @State isLoading: boolean = true;
  @State selectedCategory: string = '全部';
  @State currentMonth: number = 0;
  @State currentDay: number = 0;
  @State offsetX: number = 0;
  @State cardOpacity: number = 1;

  private categories: string[] = ['全部', '政治', '科技', '文化', '军事', '社会', '经济', '人物'];

  aboutToAppear(): void {
    const now = new Date();
    this.currentMonth = now.getMonth() + 1;
    this.currentDay = now.getDate();
    this.initTodayDate();
    this.loadHistoryEvents();
  }

  initTodayDate(): void {
    this.todayDate = `${this.currentMonth}月${this.currentDay}日`;
  }

  loadHistoryEvents(): void {
    this.isLoading = true;
    this.historyEvents = this.getHistoryData(this.currentMonth, this.currentDay);
    this.isLoading = false;
  }

  changeDate(delta: number): void {
    const date = new Date();
    date.setMonth(this.currentMonth - 1);
    date.setDate(this.currentDay);
    date.setDate(date.getDate() + delta);

    this.currentMonth = date.getMonth() + 1;
    this.currentDay = date.getDate();
    this.todayDate = `${this.currentMonth}月${this.currentDay}日`;

    this.cardOpacity = 0;
    setTimeout(() => {
      this.loadHistoryEvents();
      this.cardOpacity = 1;
    }, 150);
  }

  getHistoryData(month: number, day: number): HistoryEvent[] {
    const allEvents: Record<string, HistoryEvent[]> = {
      '1-1': [
        { year: 1086, title: '《资治通鉴》编成', description: '司马光主持编纂的编年体通史《资治通鉴》成书，历时19年完成', category: '文化' },
        { year: 1863, title: '美国总统林肯签署《解放宣言》', description: '正式解放南方叛乱各州的奴隶，美国内战转折点', category: '政治' },
        { year: 1912, title: '中华民国成立', description: '孙中山在南京就任临时大总统，宣告中华民国成立', category: '政治' },
        { year: 1959, title: '古巴革命胜利', description: '卡斯特罗率领起义军推翻巴蒂斯塔政权', category: '政治' }
      ],
      '1-15': [
        { year: 1559, title: '英国伊丽莎白一世加冕', description: '伊丽莎白一世在威斯敏斯特教堂加冕为英格兰女王', category: '政治' },
        { year: 1929, title: '马丁·路德·金诞生', description: '美国民权运动领袖马丁·路德·金出生于亚特兰大', category: '人物' },
        { year: 2001, title: '维基百科上线', description: '全球最大的在线百科全书正式上线运营', category: '科技' }
      ],
      '2-14': [
        { year: 270, title: '瓦伦丁殉道', description: '基督教圣人瓦伦丁殉道，后成为情人节起源', category: '文化' },
        { year: 1946, title: '世界上第一台计算机ENIAC诞生', description: '宾夕法尼亚大学研制成功第一台电子计算机', category: '科技' },
        { year: 2005, title: 'YouTube成立', description: '全球最大的视频分享网站正式上线', category: '科技' }
      ],
      '3-8': [
        { year: 1911, title: '第一个国际妇女节', description: '奥地利、丹麦、德国和瑞士等国有超过100万妇女集会', category: '社会' },
        { year: 1975, title: '联合国开始庆祝国际妇女节', description: '联合国正式开始庆祝国际妇女节', category: '社会' },
        { year: 2014, title: '马航MH370失踪', description: '马来西亚航空MH370航班在印度洋上空失踪', category: '社会' }
      ],
      '4-1': [
        { year: 1976, title: '苹果公司成立', description: '史蒂夫·乔布斯、史蒂夫·沃兹尼亚克和罗纳德·韦恩创立苹果公司', category: '科技' },
        { year: 2001, title: '中美撞机事件', description: '美国侦察机与中国战斗机在南海上空相撞', category: '政治' },
        { year: 1939, title: '西班牙内战结束', description: '弗朗哥军队占领马德里，西班牙内战正式结束', category: '军事' }
      ],
      '4-12': [
        { year: 1961, title: '人类首次太空飞行', description: '苏联宇航员尤里·加加林乘坐东方一号飞船进入太空', category: '科技' },
        { year: 1981, title: '第一架航天飞机发射', description: '美国哥伦比亚号航天飞机首次发射成功', category: '科技' }
      ],
      '4-16': [
        { year: 1948, title: '欧洲经济合作组织成立', description: '为实施马歇尔计划而成立，后发展为经合组织', category: '经济' },
        { year: 1972, title: '阿波罗16号发射', description: '美国宇航员约翰·杨和查尔斯·杜克登月', category: '科技' },
        { year: 2003, title: '伊拉克战争重大战役', description: '美军在伊拉克战争中取得重要进展', category: '军事' },
        { year: 2014, title: '韩国世越号沉船事故', description: '韩国世越号客轮沉没，造成304人遇难', category: '社会' }
      ],
      '5-1': [
        { year: 1886, title: '芝加哥工人大罢工', description: '美国芝加哥工人争取八小时工作制大罢工，五一劳动节起源', category: '社会' },
        { year: 1950, title: '中国第一部《婚姻法》实施', description: '新中国第一部婚姻法正式实施', category: '法律' },
        { year: 2011, title: '本·拉登被击毙', description: '美国海豹突击队在巴基斯坦击毙基地组织领导人本·拉登', category: '军事' }
      ],
      '5-4': [
        { year: 1919, title: '五四运动', description: '中国学生在北京发起爱国运动，标志着新民主主义革命开始', category: '政治' },
        { year: 1949, title: '中华全国青年联合会成立', description: '中国最大的青年组织正式成立', category: '社会' }
      ],
      '6-1': [
        { year: 1925, title: '国际儿童节设立', description: '国际儿童节首次在日内瓦设立', category: '社会' },
        { year: 1950, title: '新中国第一个儿童节', description: '中国首次庆祝六一国际儿童节', category: '社会' },
        { year: 1980, title: 'CNN开播', description: '全球第一个24小时新闻频道正式开播', category: '科技' }
      ],
      '6-26': [
        { year: 1945, title: '联合国宪章签署', description: '50个国家代表在旧金山签署联合国宪章', category: '政治' },
        { year: 2000, title: '人类基因组计划完成', description: '人类基因组序列工作草图正式发布', category: '科技' }
      ],
      '7-1': [
        { year: 1921, title: '中国共产党成立', description: '中国共产党第一次全国代表大会在上海召开', category: '政治' },
        { year: 1997, title: '香港回归', description: '中国恢复对香港行使主权，香港特别行政区成立', category: '政治' },
        { year: 2006, title: '青藏铁路全线通车', description: '世界上海拔最高的铁路正式运营', category: '科技' }
      ],
      '7-20': [
        { year: 1969, title: '人类首次登月', description: '阿波罗11号宇航员阿姆斯特朗成为第一个踏上月球的人类', category: '科技' },
        { year: 1976, title: '维京1号登陆火星', description: '美国维京1号探测器成功登陆火星表面', category: '科技' }
      ],
      '8-1': [
        { year: 1927, title: '南昌起义', description: '周恩来、贺龙等领导南昌起义，中国人民解放军建军节', category: '军事' },
        { year: 1894, title: '甲午战争爆发', description: '中日甲午战争正式爆发', category: '军事' },
        { year: 1936, title: '柏林奥运会开幕', description: '第11届夏季奥林匹克运动会在柏林开幕', category: '社会' }
      ],
      '8-15': [
        { year: 1945, title: '日本宣布无条件投降', description: '日本天皇裕仁广播《终战诏书》，宣布接受波茨坦公告', category: '军事' },
        { year: 1947, title: '印度独立', description: '印度脱离英国殖民统治，宣布独立', category: '政治' }
      ],
      '9-10': [
        { year: 1985, title: '中国第一个教师节', description: '中国正式设立教师节，尊师重教成为社会风尚', category: '社会' },
        { year: 1945, title: '上党战役', description: '晋冀鲁豫军区部队在山西上党地区对国民党军进行反击', category: '军事' }
      ],
      '9-18': [
        { year: 1931, title: '九一八事变', description: '日本关东军炸毁南满铁路，发动侵华战争', category: '军事' }
      ],
      '10-1': [
        { year: 1949, title: '中华人民共和国成立', description: '毛泽东在天安门城楼宣告中华人民共和国中央人民政府成立', category: '政治' },
        { year: 1960, title: '尼日利亚独立', description: '尼日利亚脱离英国殖民统治宣布独立', category: '政治' },
        { year: 1969, title: '协和客机首次超音速飞行', description: '英法联合研制的协和客机首次突破音速', category: '科技' }
      ],
      '10-24': [
        { year: 1945, title: '联合国正式成立', description: '联合国宪章生效，联合国正式成立', category: '政治' },
        { year: 2007, title: '嫦娥一号发射', description: '中国首颗绕月探测卫星嫦娥一号成功发射', category: '科技' }
      ],
      '11-11': [
        { year: 1918, title: '第一次世界大战结束', description: '德国签署停战协定，第一次世界大战正式结束', category: '军事' },
        { year: 2009, title: '双十一购物节诞生', description: '淘宝商城发起双十一促销活动', category: '经济' },
        { year: 1965, title: '罗德西亚单方面宣布独立', description: '英国殖民地南罗德西亚单方面宣布独立', category: '政治' }
      ],
      '12-25': [
        { year: 800, title: '查理曼大帝加冕', description: '教皇利奥三世为查理曼加冕为罗马皇帝', category: '政治' },
        { year: 1991, title: '苏联解体', description: '苏联总统戈尔巴乔夫宣布辞职，苏联正式解体', category: '政治' },
        { year: 1642, title: '牛顿诞生', description: '英国物理学家艾萨克·牛顿出生于林肯郡', category: '人物' }
      ],
      '12-26': [
        { year: 1893, title: '毛泽东诞生', description: '中国共产党创始人之一毛泽东出生于湖南韶山', category: '人物' },
        { year: 2004, title: '印度洋海啸', description: '印度洋发生9.1级地震引发海啸，造成约23万人遇难', category: '社会' }
      ]
    };

    const key = `${month}-${day}`;
    let events = allEvents[key] || [
      { year: 1969, title: '阿波罗11号登月', description: '人类首次登上月球，阿姆斯特朗迈出历史性一步', category: '科技' },
      { year: 1945, title: '第二次世界大战结束', description: '日本宣布无条件投降，二战正式结束', category: '军事' },
      { year: 1912, title: '泰坦尼克号沉没', description: '英国豪华邮轮泰坦尼克号在首航中撞上冰山沉没', category: '历史' },
      { year: 1903, title: '莱特兄弟首次飞行', description: '人类历史上第一次动力飞机飞行成功', category: '科技' },
      { year: 1879, title: '爱迪生发明电灯', description: '托马斯·爱迪生成功发明实用白炽灯泡', category: '科技' },
      { year: 1666, title: '牛顿发现万有引力', description: '牛顿因苹果落地而发现万有引力定律', category: '科技' }
    ];

    if (this.selectedCategory !== '全部') {
      events = events.filter(e => e.category === this.selectedCategory);
    }

    return events.sort((a, b) => b.year - a.year);
  }

  getCategoryColor(category: string): string {
    const colors: Record<string, string> = {
      '政治': '#E91E63',
      '科技': '#2196F3',
      '文化': '#9C27B0',
      '军事': '#F44336',
      '社会': '#4CAF50',
      '经济': '#FF9800',
      '人物': '#00BCD4',
      '历史': '#607D8B',
      '法律': '#3F51B5'
    };
    return colors[category] || '#64748B';
  }

  @Builder
  categoryFilter() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(13)
            .fontWeight(this.selectedCategory === category ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedCategory === category ? Color.White : $r('app.color.text_secondary'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedCategory === category ?
              $r('app.color.primary') : $r('app.color.background'))
            .borderRadius(20)
            .margin({ right: 6 })
            .onClick(() => {
              this.selectedCategory = category;
              this.loadHistoryEvents();
            })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  eventCard(event: HistoryEvent, index: number) {
    Column() {
      Row() {
        Column() {
          Text(`${event.year}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary'))

          Text('年')
            .fontSize(12)
            .fontColor($r('app.color.text_hint'))
        }
        .width(60)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Row() {
            Text(event.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)

            Text(event.category)
              .fontSize(11)
              .fontColor(Color.White)
              .backgroundColor(this.getCategoryColor(event.category))
              .borderRadius(10)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          }
          .width('100%')

          Text(event.description)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8 })
            .lineHeight(20)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(18)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .margin({ bottom: 12 })
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
        .onClick(() => {
          router.back();
        })

        Text('历史上的今天')
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

      Column() {
        Row() {
          Button() {
            Text('‹')
              .fontSize(24)
              .fontColor($r('app.color.text_secondary'))
          }
          .backgroundColor($r('app.color.background'))
          .borderRadius(20)
          .width(40)
          .height(40)
          .onClick(() => {
            this.changeDate(-1);
          })

          Column() {
            Text(this.todayDate)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary'))

            Text('历史上的今天')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)

          Button() {
            Text('›')
              .fontSize(24)
              .fontColor($r('app.color.text_secondary'))
          }
          .backgroundColor($r('app.color.background'))
          .borderRadius(20)
          .width(40)
          .height(40)
          .onClick(() => {
            this.changeDate(1);
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))

      Column() {
        this.categoryFilter()
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))
      .padding({ top: 8, bottom: 8 })
      .border({ width: { bottom: 1 }, color: $r('app.color.divider') })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.primary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.historyEvents.length === 0) {
        Column() {
          Text('📭')
            .fontSize(48)
            .margin({ bottom: 16 })

          Text('暂无历史事件')
            .fontSize(18)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 8 })

          Text('换个分类或日期看看吧')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.historyEvents, (event: HistoryEvent, index: number) => {
              this.eventCard(event, index)
            }, (event: HistoryEvent, index: number) => `${event.year}-${index}`)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .opacity(this.cardOpacity)
        .animation({
          duration: 150,
          curve: Curve.EaseOut
        })
      }

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
            .fontColor($r('app.color.primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })

        Column() {
          Text('⚙️')
            .fontSize(24)
          Text('设置')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Settings' });
        })
      }
      .width('100%')
      .height(68)
      .backgroundColor($r('app.color.card_background'))
      .border({ width: { top: 1 }, color: $r('app.color.divider') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
