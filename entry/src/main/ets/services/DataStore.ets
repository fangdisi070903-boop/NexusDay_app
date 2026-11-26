import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { CountdownItem, Category, CountdownType, generateId, SortMode } from '../models/CountdownModel';

const STORE_NAME = 'nexus_day_store';
const COUNTDOWN_KEY = 'countdowns';
const SORT_MODE_KEY = 'sort_mode';

export class DataStore {
  private static instance: DataStore;
  private preferences: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;
  private countdowns: CountdownItem[] = [];
  private sortMode: SortMode = SortMode.BY_TIME;
  private isInitialized: boolean = false;

  private constructor() {}

  static getInstance(): DataStore {
    if (!DataStore.instance) {
      DataStore.instance = new DataStore();
    }
    return DataStore.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    try {
      this.preferences = await preferences.getPreferences(context, STORE_NAME);
      await this.loadCountdowns();
      await this.loadSortMode();
      this.isInitialized = true;
      console.info('DataStore initialized successfully, countdowns count:', this.countdowns.length);
    } catch (error) {
      console.error('DataStore init failed:', error);
      this.countdowns = [];
      this.isInitialized = true;
    }
  }

  isReady(): boolean {
    return this.isInitialized;
  }

  private async loadCountdowns(): Promise<void> {
    if (!this.preferences) {
      console.error('Preferences is null');
      return;
    }
    try {
      const data = await this.preferences.get(COUNTDOWN_KEY, '[]');
      console.info('Loaded raw data:', data);
      const loaded = JSON.parse(data as string) as CountdownItem[];
      this.countdowns = loaded.map((item: CountdownItem): CountdownItem => {
        return {
          id: item.id,
          title: item.title,
          targetDate: item.targetDate,
          note: item.note,
          category: item.category,
          type: item.type,
          isPinned: item.isPinned ?? false,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        };
      });
      console.info('Loaded countdowns:', this.countdowns.length);
    } catch (error) {
      console.error('Load countdowns failed:', error);
      this.countdowns = [];
    }
  }

  private async loadSortMode(): Promise<void> {
    if (!this.preferences) return;
    try {
      const mode = await this.preferences.get(SORT_MODE_KEY, SortMode.BY_TIME);
      this.sortMode = mode as SortMode;
    } catch (error) {
      this.sortMode = SortMode.BY_TIME;
    }
  }

  private async saveCountdowns(): Promise<void> {
    if (!this.preferences) {
      console.error('Cannot save: preferences is null');
      return;
    }
    try {
      const jsonStr = JSON.stringify(this.countdowns);
      console.info('Saving countdowns:', jsonStr);
      await this.preferences.put(COUNTDOWN_KEY, jsonStr);
      await this.preferences.flush();
      console.info('Countdowns saved successfully');
    } catch (error) {
      console.error('Save countdowns failed:', error);
    }
  }

  getSortMode(): SortMode {
    return this.sortMode;
  }

  async setSortMode(mode: SortMode): Promise<void> {
    this.sortMode = mode;
    if (this.preferences) {
      await this.preferences.put(SORT_MODE_KEY, mode);
      await this.preferences.flush();
    }
  }

  getCountdowns(): CountdownItem[] {
    console.info('getCountdowns called, count:', this.countdowns.length);
    return [...this.countdowns];
  }

  getCountdownsByCategory(category: Category): CountdownItem[] {
    return this.countdowns.filter(item => item.category === category);
  }

  getCountdownById(id: string): CountdownItem | undefined {
    return this.countdowns.find(item => item.id === id);
  }

  async addCountdown(
    title: string,
    targetDate: string,
    note: string,
    category: Category,
    type: CountdownType
  ): Promise<CountdownItem> {
    const now = Date.now();
    const item: CountdownItem = {
      id: generateId(),
      title,
      targetDate,
      note,
      category,
      type,
      isPinned: false,
      createdAt: now,
      updatedAt: now
    };
    this.countdowns.push(item);
    console.info('Adding countdown:', item.title);
    await this.saveCountdowns();
    console.info('Countdown added, total count:', this.countdowns.length);
    return item;
  }

  async updateCountdown(item: CountdownItem): Promise<void> {
    const index = this.countdowns.findIndex(c => c.id === item.id);
    if (index !== -1) {
      item.updatedAt = Date.now();
      this.countdowns[index] = item;
      await this.saveCountdowns();
    }
  }

  async togglePin(id: string): Promise<void> {
    const item = this.countdowns.find(c => c.id === id);
    if (item) {
      item.isPinned = !item.isPinned;
      await this.saveCountdowns();
    }
  }

  async deleteCountdown(id: string): Promise<void> {
    this.countdowns = this.countdowns.filter(item => item.id !== id);
    await this.saveCountdowns();
  }

  async clearAllData(): Promise<void> {
    this.countdowns = [];
    await this.saveCountdowns();
  }
}

export default DataStore.getInstance();
