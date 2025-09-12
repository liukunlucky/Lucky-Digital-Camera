// 数据库服务类
import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

export class DatabaseService {
  private static instance: DatabaseService;
  private preferencesStore: preferences.Preferences | null = null;
  private isInitialized: boolean = false;

  private constructor() {}

  public static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  // 初始化数据库服务
  public async init(): Promise<void> {
    if (this.isInitialized) return;

    try {
      const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
      this.preferencesStore = await preferences.getPreferences(context, 'app_database');
      this.isInitialized = true;
    } catch (error) {
      console.error('初始化数据库服务失败:', error);
    }
  }

  // 保存数据
  public async saveData(key: string, data: string): Promise<void> {
    await this.init();
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.put(key, data);
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('保存数据失败:', error);
    }
  }

  // 获取数据
  public async getData(key: string): Promise<string | null> {
    await this.init();
    try {
      if (this.preferencesStore) {
        const data = await this.preferencesStore.get(key, '') as string;
        return data || null;
      }
    } catch (error) {
      console.error('获取数据失败:', error);
    }
    return null;
  }

  // 删除数据
  public async deleteData(key: string): Promise<void> {
    await this.init();
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.delete(key);
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('删除数据失败:', error);
    }
  }

  // 清空所有数据
  public async clearAll(): Promise<void> {
    await this.init();
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.clear();
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('清空数据失败:', error);
    }
  }
}