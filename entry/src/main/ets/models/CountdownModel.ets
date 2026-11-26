export enum Category {
  LIFE = 'life',
  STUDY = 'study',
  WORK = 'work',
  ANNIVERSARY = 'anniversary'
}

export enum CountdownType {
  COUNTDOWN = 'countdown',
  COUNTUP = 'countup'
}

export enum SortMode {
  BY_TIME = 'by_time',
  BY_CUSTOM = 'by_custom'
}

export interface CountdownItem {
  id: string;
  title: string;
  targetDate: string;
  note: string;
  category: Category;
  type: CountdownType;
  isPinned: boolean;
  createdAt: number;
  updatedAt: number;
}

export interface CountdownTime {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
  isPast: boolean;
}

export const CategoryLabels: Record<Category, string> = {
  [Category.LIFE]: '生活',
  [Category.STUDY]: '学习',
  [Category.WORK]: '工作',
  [Category.ANNIVERSARY]: '纪念日'
};

export const CategoryColors: Record<Category, string> = {
  [Category.LIFE]: '#86EFAC',
  [Category.STUDY]: '#93C5FD',
  [Category.WORK]: '#FCD34D',
  [Category.ANNIVERSARY]: '#F9A8D4'
};

export const CategoryColorsDark: Record<Category, string> = {
  [Category.LIFE]: '#166534',
  [Category.STUDY]: '#1E40AF',
  [Category.WORK]: '#92400E',
  [Category.ANNIVERSARY]: '#9D174D'
};

export const CategoryTextColors: Record<Category, string> = {
  [Category.LIFE]: '#166534',
  [Category.STUDY]: '#1E40AF',
  [Category.WORK]: '#92400E',
  [Category.ANNIVERSARY]: '#9D174D'
};

export const CategoryTextColorsDark: Record<Category, string> = {
  [Category.LIFE]: '#86EFAC',
  [Category.STUDY]: '#93C5FD',
  [Category.WORK]: '#FCD34D',
  [Category.ANNIVERSARY]: '#F9A8D4'
};

export const CardBackgroundColors: Record<Category, string[]> = {
  [Category.LIFE]: ['#ECFDF5', '#D1FAE5'],
  [Category.STUDY]: ['#EFF6FF', '#DBEAFE'],
  [Category.WORK]: ['#FFFBEB', '#FEF3C7'],
  [Category.ANNIVERSARY]: ['#FDF2F8', '#FCE7F3']
};

export const CardBackgroundColorsDark: Record<Category, string[]> = {
  [Category.LIFE]: ['#14532D', '#166534'],
  [Category.STUDY]: ['#1E3A5F', '#1E40AF'],
  [Category.WORK]: ['#78350F', '#92400E'],
  [Category.ANNIVERSARY]: ['#831843', '#9D174D']
};

export const MainCardColorsLight: string[] = ['#3B82F6', '#1D4ED8'];
export const MainCardColorsDark: string[] = ['#1E40AF', '#1E3A8A'];

export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
}

export function calculateCountdown(targetDate: string, type: CountdownType): CountdownTime {
  const target = new Date(targetDate).getTime();
  const now = Date.now();
  const diff = Math.abs(target - now);
  
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);
  
  const isPast = type === CountdownType.COUNTDOWN ? target < now : target <= now;
  
  return { days, hours, minutes, seconds, isPast };
}

export function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}年${month}月${day}日`;
}

export function getDaysRemaining(targetDate: string): number {
  const target = new Date(targetDate).getTime();
  const now = Date.now();
  return Math.abs(Math.floor((target - now) / (1000 * 60 * 60 * 24)));
}

/**
 * 将时间戳截断为本地时区当天 0 点的时间戳
 * 用于消除小时/分钟误差，只按自然日计算天数差
 */
function toDayStart(ts: number): number {
  const d: Date = new Date(ts);
  d.setHours(0, 0, 0, 0); // 时、分、秒、毫秒全部归零
  return d.getTime();
}

/**
 * 计算当前时间与目标时间之间的天数差，返回描述性文本
 *
 * @param targetDate 目标时间戳（毫秒）
 * @param isCountUp  是否为正数模式：false = 倒数日，true = 正数日/纪念日
 * @returns 如 "还有 63 天" / "已过去 10 天" / "已经 301 天" / "就是今天"
 */
export function calculateDays(targetDate: number, isCountUp: boolean): string {
  // 一天的毫秒数
  const MS_PER_DAY: number = 24 * 60 * 60 * 1000;

  // 获取"今天 0 点"和"目标日 0 点"的时间戳，忽略具体时刻
  const todayStart: number = toDayStart(Date.now());
  const targetStart: number = toDayStart(targetDate);

  // 相差的自然日天数（正数表示目标在未来，负数表示目标在过去）
  // 用 Math.round 而非 Math.floor，避免夏令时切换导致的 23/25 小时的一天产生误差
  const diffDays: number = Math.round((targetStart - todayStart) / MS_PER_DAY);

  if (diffDays === 0) {
    // 两种模式下，目标日是今天时都统一提示
    return '就是今天';
  }

  if (!isCountUp) {
    // 倒数日模式：目标应在未来
    return diffDays > 0 ? `还有 ${diffDays} 天` : `已过去 ${Math.abs(diffDays)} 天`;
  } else {
    // 正数日/纪念日模式：目标应在过去
    return diffDays < 0 ? `已经 ${Math.abs(diffDays)} 天` : `还有 ${diffDays} 天开始`;
  }
}

/**
 * 便捷包装：直接根据 CountdownItem 计算展示文本
 * 内部将 item.targetDate（日期字符串）与 item.type 转换为 calculateDays 所需参数
 */
export function calculateDaysForItem(item: CountdownItem): string {
  const targetTs: number = new Date(item.targetDate).getTime();
  return calculateDays(targetTs, item.type === CountdownType.COUNTUP);
}
