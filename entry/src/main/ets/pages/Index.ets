import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CountdownItem, Category, CategoryLabels, CategoryColors, CategoryColorsDark, CategoryTextColors, CategoryTextColorsDark, CardBackgroundColors, CardBackgroundColorsDark, MainCardColorsLight, MainCardColorsDark, CountdownType, SortMode, getDaysRemaining, calculateDaysForItem, formatDate } from '../models/CountdownModel';
import dataStore from '../services/DataStore';
import { ConfigurationConstant } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';

interface HistoryEvent {
  year: number;
  title: string;
  description: string;
  category: string;
}

interface EventLibraryItem {
  title: string;
  date: string;
  category: string;
  description: string;
  isUserEvent?: boolean;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State countdowns: CountdownItem[] = [];
  @State filteredCountdowns: CountdownItem[] = [];
  @State searchKeyword: string = '';
  @State selectedCategory: Category | 'all' = 'all';
  @State sortMode: SortMode = SortMode.BY_TIME;
  @State cardOpacity: number[] = [];
  @State cardTranslateX: number[] = [];
  @State showDeleteDialog: boolean = false;
  @State deleteTarget: CountdownItem | null = null;
  @State deleteIndex: number = -1;

  @State historyEvents: HistoryEvent[] = [];
  @State todayDate: string = '';
  @State isLoading: boolean = true;
  @State selectedHistoryCategory: string = '全部';
  @State currentMonth: number = 0;
  @State currentDay: number = 0;
  @State historyCardOpacity: number = 1;
  private categories: string[] = ['全部', '政治', '科技', '文化', '军事', '社会', '经济', '人物'];

  @State showClearDialog: boolean = false;
  @State countdownCount: number = 0;
  @State isDarkMode: boolean = false;
  @State switchScale: number = 1;
  private context: common.UIAbilityContext | null = null;

  @State selectedTool: string = '';
  @State calcResult: string = '';
  @State startYear: number = 2026;
  @State startMonth: number = 1;
  @State startDay: number = 1;
  @State endYear: number = 2026;
  @State endMonth: number = 1;
  @State endDay: number = 1;
  @State showAddEventDialog: boolean = false;
  @State selectedEvent: EventLibraryItem | null = null;
  @State eventYear: number = 2026;
  @State eventMonth: number = 1;
  @State eventDay: number = 1;
  @State eventPickerSelected: Date = new Date();

  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    this.sortMode = dataStore.getSortMode();
    this.loadCountdowns();
    this.initHistoryData();
    this.countdownCount = dataStore.getCountdowns().length;
    this.context = getContext(this) as common.UIAbilityContext;
    this.checkColorMode();
  }

  onPageShow(): void {
    this.sortMode = dataStore.getSortMode();
    this.loadCountdowns();
    this.countdownCount = dataStore.getCountdowns().length;
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
    this.loadCountdowns();
    promptAction.showToast({ message: '数据已清空' });
    this.showClearDialog = false;
  }

  initHistoryData(): void {
    const now = new Date();
    this.currentMonth = now.getMonth() + 1;
    this.currentDay = now.getDate();
    this.initTodayDate();
    this.loadHistoryEvents();
    this.initToolDates();
  }

  initToolDates(): void {
    const now = new Date();
    this.startYear = now.getFullYear();
    this.startMonth = now.getMonth() + 1;
    this.startDay = now.getDate();
    this.endYear = now.getFullYear();
    this.endMonth = now.getMonth() + 1;
    this.endDay = now.getDate();
  }

  openCalculatorDatePicker(type: 'start' | 'end'): void {
    const selected = type === 'start'
      ? new Date(this.startYear, this.startMonth - 1, this.startDay)
      : new Date(this.endYear, this.endMonth - 1, this.endDay);

    DatePickerDialog.show({
      selected: selected,
      onDateAccept: (value: Date) => {
        if (type === 'start') {
          this.startYear = value.getFullYear();
          this.startMonth = value.getMonth() + 1;
          this.startDay = value.getDate();
        } else {
          this.endYear = value.getFullYear();
          this.endMonth = value.getMonth() + 1;
          this.endDay = value.getDate();
        }
        this.calcResult = '';
      }
    });
  }

  calculateDays(): void {
    const startDate = new Date(this.startYear, this.startMonth - 1, this.startDay);
    const endDate = new Date(this.endYear, this.endMonth - 1, this.endDay);
    const diffTime = endDate.getTime() - startDate.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays > 0) {
      this.calcResult = `相差 ${diffDays} 天`;
    } else if (diffDays < 0) {
      this.calcResult = `相差 ${Math.abs(diffDays)} 天（已过去）`;
    } else {
      this.calcResult = '是同一天';
    }
  }

  getEventLibrary(): EventLibraryItem[] {
    return [
      { title: '出生纪念日', date: '自定义日期', category: '个人事件', description: '记录你的出生日期，看看已经在这个世界上多久了', isUserEvent: true },
      { title: '上小学', date: '自定义日期', category: '个人事件', description: '记录你开始上小学的日子', isUserEvent: true },
      { title: '上初中', date: '自定义日期', category: '个人事件', description: '记录你开始上初中的日子', isUserEvent: true },
      { title: '上高中', date: '自定义日期', category: '个人事件', description: '记录你开始上高中的日子', isUserEvent: true },
      { title: '上大学', date: '自定义日期', category: '个人事件', description: '记录你开始上大学的日子', isUserEvent: true },
      { title: '工作入职', date: '自定义日期', category: '个人事件', description: '记录你开始工作的日子', isUserEvent: true },
      { title: '恋爱纪念日', date: '自定义日期', category: '个人事件', description: '记录你们在一起的日子', isUserEvent: true },
      { title: '结婚纪念日', date: '自定义日期', category: '个人事件', description: '记录你们结婚的日子', isUserEvent: true },
      { title: '春节', date: '农历正月初一', category: '传统节日', description: '中国最重要的传统节日，家人团聚的日子' },
      { title: '元宵节', date: '农历正月十五', category: '传统节日', description: '赏花灯、吃元宵，象征团圆美满' },
      { title: '清明节', date: '4月4日或5日', category: '传统节日', description: '祭祖扫墓，缅怀先人' },
      { title: '端午节', date: '农历五月初五', category: '传统节日', description: '纪念屈原，吃粽子、赛龙舟' },
      { title: '七夕节', date: '农历七月初七', category: '传统节日', description: '中国情人节，牛郎织女相会' },
      { title: '中秋节', date: '农历八月十五', category: '传统节日', description: '赏月吃月饼，象征团圆' },
      { title: '国庆节', date: '10月1日', category: '法定假日', description: '中华人民共和国成立纪念日' },
      { title: '劳动节', date: '5月1日', category: '法定假日', description: '国际劳动节，致敬劳动者' },
      { title: '元旦', date: '1月1日', category: '法定假日', description: '公历新年第一天' },
      { title: '情人节', date: '2月14日', category: '现代节日', description: '表达爱意的浪漫节日' },
      { title: '妇女节', date: '3月8日', category: '现代节日', description: '庆祝女性成就的节日' },
      { title: '儿童节', date: '6月1日', category: '现代节日', description: '属于孩子们的快乐节日' },
      { title: '教师节', date: '9月10日', category: '现代节日', description: '感谢师恩的节日' },
      { title: '母亲节', date: '5月第二个周日', category: '现代节日', description: '感恩母亲的节日' },
      { title: '父亲节', date: '6月第三个周日', category: '现代节日', description: '感恩父亲的节日' },
      { title: '圣诞节', date: '12月25日', category: '西方节日', description: '庆祝耶稣诞生的节日' },
      { title: '万圣节', date: '10月31日', category: '西方节日', description: '西方传统节日，孩子们会装扮讨糖' },
      { title: '感恩节', date: '11月第四个周四', category: '西方节日', description: '美国传统节日，感谢丰收与恩赐' }
    ];
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

    this.historyCardOpacity = 0;
    setTimeout(() => {
      this.loadHistoryEvents();
      this.historyCardOpacity = 1;
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

    if (this.selectedHistoryCategory !== '全部') {
      events = events.filter(e => e.category === this.selectedHistoryCategory);
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

  loadCountdowns(): void {
    let list: CountdownItem[];
    if (this.selectedCategory === 'all') {
      list = dataStore.getCountdowns();
    } else {
      list = dataStore.getCountdownsByCategory(this.selectedCategory);
    }
    this.countdowns = this.sortList(list);
    this.filteredCountdowns = this.filterBySearch(this.countdowns);
    this.cardOpacity = new Array(this.filteredCountdowns.length).fill(1);
    this.cardTranslateX = new Array(this.filteredCountdowns.length).fill(0);
  }

  filterBySearch(list: CountdownItem[]): CountdownItem[] {
    if (!this.searchKeyword.trim()) {
      return list;
    }
    const keyword = this.searchKeyword.toLowerCase().trim();
    return list.filter(item => 
      item.title.toLowerCase().includes(keyword) ||
      item.note.toLowerCase().includes(keyword) ||
      CategoryLabels[item.category].includes(keyword)
    );
  }

  getNearestCountdown(): CountdownItem | null {
    if (this.countdowns.length === 0) return null;
    
    let nearest: CountdownItem | null = null;
    let minDays = Infinity;
    
    for (const item of this.countdowns) {
      const days = getDaysRemaining(item.targetDate);
      if (days < minDays) {
        minDays = days;
        nearest = item;
      }
    }
    
    return nearest;
  }

  getWeekDay(dateStr: string): string {
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const date = new Date(dateStr);
    return weekDays[date.getDay()];
  }

  formatDateWithWeek(dateStr: string): string {
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekDay = this.getWeekDay(dateStr);
    return `${year}年${month}月${day}日 ${weekDay}`;
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
  mainCountdownCard() {
    if (this.getNearestCountdown()) {
      Column() {
        Row() {
          Text(this.getNearestCountdown()!.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .padding({ right: 16 })

          Text(CategoryLabels[this.getNearestCountdown()!.category])
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor('rgba(255,255,255,0.25)')
            .borderRadius(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        }
        .width('100%')

        Blank().height(24)

        Row() {
          Column() {
            if (this.getNearestCountdown()!.type === CountdownType.COUNTUP) {
              Text('已经')
                .fontSize(16)
                .fontColor('rgba(255,255,255,0.8)')
            } else {
              Text('还有')
                .fontSize(16)
                .fontColor('rgba(255,255,255,0.8)')
            }
          }

          Blank()

          Row() {
            Text(this.getCountdownDisplay(this.getNearestCountdown()!))
              .fontSize(56)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text('天')
              .fontSize(20)
              .fontColor('rgba(255,255,255,0.9)')
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')

        Blank().height(20)

        Row() {
          Text('📅')
            .fontSize(14)
          Text(this.formatDateWithWeek(this.getNearestCountdown()!.targetDate))
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.9)')
            .margin({ left: 8 })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 24, bottom: 24 })
      .linearGradient({
        angle: 135,
        colors: this.isDarkMode ? [
          [MainCardColorsDark[0], 0],
          [MainCardColorsDark[1], 1]
        ] : [
          [MainCardColorsLight[0], 0],
          [MainCardColorsLight[1], 1]
        ]
      })
      .borderRadius(20)
      .shadow({ radius: 16, color: this.isDarkMode ? '#301E3A8A' : '#303B82F6', offsetX: 0, offsetY: 8 })
      .onClick(() => {
        const nearest = this.getNearestCountdown();
        if (nearest) {
          router.pushUrl({
            url: 'pages/CountdownDetail',
            params: { id: nearest.id }
          });
        }
      })
    } else {
      Column() {
        Text('⏰')
          .fontSize(48)
          .margin({ bottom: 12 })

        Text('还没有添加倒计时')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text('点击右上角 + 添加')
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 32, bottom: 32 })
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(20)
      .border({ width: 1, color: $r('app.color.divider') })
    }
  }

  @Builder
  searchBar() {
    Row() {
      Text('🔍')
        .fontSize(18)
        .margin({ right: 10 })

      TextInput({ placeholder: '搜索倒计时...', text: $$this.searchKeyword })
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .placeholderFont({ size: 15 })
        .placeholderColor($r('app.color.text_hint'))
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .height(40)
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.filteredCountdowns = this.filterBySearch(this.countdowns);
          this.cardOpacity = new Array(this.filteredCountdowns.length).fill(1);
          this.cardTranslateX = new Array(this.filteredCountdowns.length).fill(0);
        })

      if (this.searchKeyword.length > 0) {
        Button() {
          Text('✕')
            .fontSize(16)
            .fontColor($r('app.color.text_hint'))
        }
        .width(32)
        .height(32)
        .borderRadius(16)
        .backgroundColor($r('app.color.background'))
        .onClick(() => {
          this.searchKeyword = '';
          this.filteredCountdowns = this.filterBySearch(this.countdowns);
          this.cardOpacity = new Array(this.filteredCountdowns.length).fill(1);
          this.cardTranslateX = new Array(this.filteredCountdowns.length).fill(0);
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 12 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .border({ width: 1, color: $r('app.color.divider') })
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
        color: $r('app.color.divider')
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
            .fontColor(this.isDarkMode ? CategoryTextColorsDark[item.category] : CategoryTextColors[item.category])
            .backgroundColor(this.isDarkMode ? CategoryColorsDark[item.category] : CategoryColors[item.category])
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
        colors: this.isDarkMode ? [
          [CardBackgroundColorsDark[item.category][0], 0],
          [CardBackgroundColorsDark[item.category][1], 1]
        ] : [
          [CardBackgroundColors[item.category][0], 0],
          [CardBackgroundColors[item.category][1], 1]
        ]
      })
      .borderRadius(16)
      .border({
        width: item.isPinned ? 2 : 0,
        color: $r('app.color.primary')
      })
      .shadow({ radius: 8, color: this.isDarkMode ? '#20000000' : '#0A000000', offsetX: 0, offsetY: 2 })
      .translate({ x: this.cardTranslateX[index] })
      .opacity(this.cardOpacity[index])
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
      .onClick(() => {
        router.pushUrl({
          url: 'pages/CountdownDetail',
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

  @Builder
  homePage() {
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

      Scroll() {
        Column() {
          Column() {
            this.mainCountdownCard()
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16 })

          Column() {
            this.searchBar()
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12 })

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
              .padding({ left: 4, right: 4, top: 6, bottom: 6 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
          .margin({ top: 8 })

          if (this.filteredCountdowns.length === 0 && this.searchKeyword.length > 0) {
            Column() {
              Text('🔍')
                .fontSize(48)
                .margin({ bottom: 12 })

              Text('没有找到相关倒计时')
                .fontSize(18)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: 8 })

              Text('换个关键词试试')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .padding({ top: 40, bottom: 40 })
          } else if (this.filteredCountdowns.length === 0) {
            this.emptyState()
          } else {
            Column() {
              ForEach(this.filteredCountdowns, (item: CountdownItem, index: number) => {
                this.countdownCard(item, index)
              }, (item: CountdownItem) => item.id)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 8, bottom: 12 })
          }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  historyCategoryFilter() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(13)
            .fontWeight(this.selectedHistoryCategory === category ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedHistoryCategory === category ? Color.White : $r('app.color.text_secondary'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedHistoryCategory === category ?
              $r('app.color.primary') : $r('app.color.background'))
            .borderRadius(20)
            .margin({ right: 6 })
            .onClick(() => {
              this.selectedHistoryCategory = category;
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

  @Builder
  toolCard(title: string, icon: string, description: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(32)

        Column() {
          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(description)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 16 })

        Text('›')
          .fontSize(24)
          .fontColor($r('app.color.text_hint'))
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.selectedTool = title;
    })
  }

  @Builder
  dateCalculatorPage() {
    Column() {
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
        }
        .height(40)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)
        .onClick(() => {
          this.selectedTool = '';
        })

        Blank()

        Text('日期计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      Column() {
        Text('开始日期')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          Button() {
            Text(`${this.startYear}年${this.startMonth}月${this.startDay}日`)
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')
          .height(50)
          .backgroundColor($r('app.color.background'))
          .borderRadius(12)
          .onClick(() => {
            this.openCalculatorDatePicker('start');
          })
        }
        .width('100%')

        Blank().height(20)

        Text('结束日期')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          Button() {
            Text(`${this.endYear}年${this.endMonth}月${this.endDay}日`)
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')
          .height(50)
          .backgroundColor($r('app.color.background'))
          .borderRadius(12)
          .onClick(() => {
            this.openCalculatorDatePicker('end');
          })
        }
        .width('100%')

        Blank().height(24)

        Button() {
          Text('计算')
            .fontSize(18)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(50)
        .borderRadius(25)
        .linearGradient({
          angle: 90,
          colors: [['#FF9800', 0], ['#FF6F00', 1]]
        })
        .onClick(() => {
          this.calculateDays();
        })

        if (this.calcResult) {
          Blank().height(24)

          Column() {
            Text(this.calcResult)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6F00')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFDE7')
          .borderRadius(16)
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(20)
      .margin({ top: 16 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }

  @Builder
  eventLibraryPage() {
    Column() {
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
        }
        .height(40)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)
        .onClick(() => {
          this.selectedTool = '';
        })

        Blank()

        Text('事件库')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      List() {
        ForEach(this.getEventLibrary(), (event: EventLibraryItem) => {
          ListItem() {
            Column() {
              Row() {
                Column() {
                  Text(event.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))

                  Text(event.date)
                    .fontSize(13)
                    .fontColor('#FF6F00')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(event.category)
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor(event.isUserEvent ? '#10B981' : '#FF9800')
                  .borderRadius(10)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              }
              .width('100%')

              Text(event.description)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 8 })
                .width('100%')

              Row() {
                Button() {
                  Text('+ 添加到我的倒计时')
                    .fontSize(14)
                    .fontColor('#FF6F00')
                }
                .height(36)
                .backgroundColor('#FFF3E0')
                .borderRadius(18)
                .onClick(() => {
                  this.selectedEvent = event;
                  const now = new Date();
                  this.eventYear = now.getFullYear();
                  this.eventMonth = now.getMonth() + 1;
                  this.eventDay = now.getDate();
                  this.eventPickerSelected = new Date();
                  this.showAddEventDialog = true;
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
              .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(12)
            .margin({ bottom: 8 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  appGuidePage() {
    Column() {
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
        }
        .height(40)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)
        .onClick(() => {
          this.selectedTool = '';
        })

        Blank()

        Text('使用指南')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      List() {
        ListItem() {
          Column() {
            Text('📌 基本功能')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text('• 点击右上角 + 添加新的倒计时')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 12 })
              .width('100%')

            Text('• 支持倒计时和正计时两种模式')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')

            Text('• 可为倒计时设置分类：生活、学习、工作、纪念日')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 12 })
        }

        ListItem() {
          Column() {
            Text('🎯 卡片操作')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text('• 点击卡片查看详情')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 12 })
              .width('100%')

            Text('• 左滑卡片显示删除按钮')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')

            Text('• 长按卡片可置顶/取消置顶')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 12 })
        }

        ListItem() {
          Column() {
            Text('🔍 搜索与筛选')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text('• 使用搜索框快速查找倒计时')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 12 })
              .width('100%')

            Text('• 点击分类标签筛选特定类型')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 12 })
        }

        ListItem() {
          Column() {
            Text('🌙 深色模式')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text('• 在设置页面可切换深色/浅色模式')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 12 })
              .width('100%')

            Text('• 深色模式护眼，适合夜间使用')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 12 })
        }

        ListItem() {
          Column() {
            Text('💾 数据管理')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text('• 所有数据保存在本地，无需联网')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 12 })
              .width('100%')

            Text('• 可在设置中清空所有数据')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .margin({ bottom: 12 })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  toolsPage() {
    Column() {
      if (this.selectedTool === '日期计算器') {
        this.dateCalculatorPage()
      } else if (this.selectedTool === '事件库') {
        this.eventLibraryPage()
      } else if (this.selectedTool === '使用指南') {
        this.appGuidePage()
      } else {
        Column() {
          Text('工具箱')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding({ left: 20, top: 20, bottom: 8 })

          Text('实用小工具，助你更好管理时间')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .padding({ left: 20, bottom: 20 })

          Column() {
            this.toolCard('日期计算器', '📅', '计算两个日期之间的天数')

            Blank().height(12)

            this.toolCard('事件库', '📚', '常见节日和重要日期参考')

            Blank().height(12)

            this.toolCard('使用指南', '📖', '了解如何使用本应用')
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          Blank()
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  historyPage() {
    Column() {
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
        this.historyCategoryFilter()
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
        .opacity(this.historyCardOpacity)
        .animation({
          duration: 150,
          curve: Curve.EaseOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
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

  @Builder
  settingsPage() {
    Column() {
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
        .padding({ left: 16, right: 16, bottom: 16, top: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  tabBarBuilder(title: string, icon: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(24)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary'))
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          this.homePage()
        }
        .tabBar(this.tabBarBuilder('首页', '🏠', 0))

        TabContent() {
          this.toolsPage()
        }
        .tabBar(this.tabBarBuilder('工具', '🧰', 1))

        TabContent() {
          this.historyPage()
        }
        .tabBar(this.tabBarBuilder('历史', '📜', 2))

        TabContent() {
          this.settingsPage()
        }
        .tabBar(this.tabBarBuilder('设置', '⚙️', 3))
      }
      .barHeight(56)
      .barBackgroundColor($r('app.color.card_background'))
      .onChange((index: number) => {
        this.currentIndex = index;
        if (index === 0) {
          this.loadCountdowns();
        }
        if (index === 3) {
          this.countdownCount = dataStore.getCountdowns().length;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .bindSheet($$this.showDeleteDialog, this.deleteDialogBuilder(), {
      height: 200,
      backgroundColor: $r('app.color.card_background'),
      dragBar: false
    })
    .bindSheet($$this.showClearDialog, this.clearDialogBuilder(), {
      height: 200,
      backgroundColor: $r('app.color.card_background'),
      dragBar: false
    })
    .bindSheet($$this.showAddEventDialog, this.addEventDialogBuilder(), {
      height: 520,
      backgroundColor: $r('app.color.card_background'),
      dragBar: true
    })
  }

  @Builder
  addEventDialogBuilder() {
    Column() {
      Text('添加到我的倒计时')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 20, bottom: 16 })

      if (this.selectedEvent) {
        Row() {
          Text(this.selectedEvent.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(this.selectedEvent.isUserEvent ? '个人事件' : '节日')
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor(this.selectedEvent.isUserEvent ? '#10B981' : '#FF9800')
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .margin({ left: 8 })
        }
        .margin({ bottom: 12 })

        Text(this.selectedEvent.description)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 12 })
      }

      Text(`选择日期：${this.eventYear}年${this.eventMonth}月${this.eventDay}日`)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: 8 })

      DatePicker({
        start: new Date('1900-1-1'),
        end: new Date('2100-12-31'),
        selected: this.eventPickerSelected
      })
        .lunar(false)
        .onChange((value: DatePickerResult) => {
          if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
            this.eventYear = value.year;
            this.eventMonth = value.month + 1;
            this.eventDay = value.day;
          }
        })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r('app.color.background'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(12)
          .onClick(() => {
            this.showAddEventDialog = false;
            this.selectedEvent = null;
          })

        Blank().width(12)

        Button('添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FF6F00')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.addEventToCountdown();
          })
      }
      .width('100%')
      .margin({ top: 16, bottom: 20 })
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }

  addEventToCountdown(): void {
    console.info('=== addEventToCountdown called ===');
    
    if (!this.selectedEvent) {
      console.error('No event selected');
      promptAction.showToast({ message: '未选择事件' });
      return;
    }

    const dateStr = `${this.eventYear}-${String(this.eventMonth).padStart(2, '0')}-${String(this.eventDay).padStart(2, '0')}`;
    console.info('Adding event:', this.selectedEvent.title, 'date:', dateStr);

    const now = Date.now();
    const newItem: CountdownItem = {
      id: now.toString(),
      title: this.selectedEvent.title,
      targetDate: dateStr,
      note: this.selectedEvent.description,
      category: Category.LIFE,
      type: CountdownType.COUNTUP,
      isPinned: false,
      createdAt: now,
      updatedAt: now
    };

    console.info('New item created:', JSON.stringify(newItem));

    dataStore.addCountdown(
      newItem.title,
      newItem.targetDate,
      newItem.note,
      newItem.category,
      newItem.type
    ).then(() => {
      console.info('=== addCountdown promise resolved ===');
      this.showAddEventDialog = false;
      this.selectedEvent = null;
      this.searchKeyword = '';
      this.selectedCategory = 'all';
      
      this.loadCountdowns();
      
      if (this.currentIndex !== 0) {
        this.tabsController.changeIndex(0);
      }
      
      promptAction.showToast({
        message: '已添加到我的倒计时'
      });
    }).catch((err: Error) => {
      console.error('Add countdown error:', err);
      promptAction.showToast({
        message: '添加失败: ' + err.message
      });
    });
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
