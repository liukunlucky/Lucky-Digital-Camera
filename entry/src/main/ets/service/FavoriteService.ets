import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { CameraDataItem } from './CameraDataJsonService';

/**
 * 收藏服务 - 统一管理收藏数据的持久化
 */
export class FavoriteService {
  private static instance: FavoriteService;
  private preferencesStore?: preferences.Preferences;
  private favoriteList: CameraDataItem[] = [];
  private isInitialized: boolean = false;

  private constructor() {}

  static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService();
    }
    return FavoriteService.instance;
  }

  /**
   * 初始化收藏服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    
    try {
      this.preferencesStore = await preferences.getPreferences(context, 'camera_favorites');
      await this.loadFavorites();
      this.isInitialized = true;
    } catch (error) {
      console.error('初始化收藏服务失败:', error);
    }
  }

  /**
   * 加载收藏列表
   */
  private async loadFavorites(): Promise<void> {
    try {
      if (this.preferencesStore) {
        const favoritesJson = await this.preferencesStore.get('favorites', '[]') as string;
        this.favoriteList = JSON.parse(favoritesJson);
      }
    } catch (error) {
      console.error('加载收藏列表失败:', error);
      this.favoriteList = [];
    }
  }

  /**
   * 保存收藏列表
   */
  private async saveFavorites(): Promise<void> {
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.put('favorites', JSON.stringify(this.favoriteList));
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('保存收藏列表失败:', error);
    }
  }

  /**
   * 获取所有收藏
   */
  getFavorites(): CameraDataItem[] {
    return this.favoriteList.slice();
  }

  /**
   * 检查是否已收藏
   */
  isFavorite(camera: CameraDataItem): boolean {
    return this.favoriteList.some(fav => 
      fav.Brand === camera.Brand && fav.Model === camera.Model
    );
  }

  /**
   * 添加收藏
   */
  async addFavorite(camera: CameraDataItem): Promise<boolean> {
    try {
      if (!this.isFavorite(camera)) {
        this.favoriteList.push(camera);
        await this.saveFavorites();
        return true;
      }
      return false;
    } catch (error) {
      console.error('添加收藏失败:', error);
      return false;
    }
  }

  /**
   * 移除收藏
   */
  async removeFavorite(camera: CameraDataItem): Promise<boolean> {
    try {
      const originalLength = this.favoriteList.length;
      this.favoriteList = this.favoriteList.filter(fav => 
        !(fav.Brand === camera.Brand && fav.Model === camera.Model)
      );
      
      if (this.favoriteList.length < originalLength) {
        await this.saveFavorites();
        return true;
      }
      return false;
    } catch (error) {
      console.error('移除收藏失败:', error);
      return false;
    }
  }

  /**
   * 切换收藏状态
   */
  async toggleFavorite(camera: CameraDataItem): Promise<boolean> {
    if (this.isFavorite(camera)) {
      return await this.removeFavorite(camera);
    } else {
      return await this.addFavorite(camera);
    }
  }

  /**
   * 清空所有收藏
   */
  async clearAllFavorites(): Promise<boolean> {
    try {
      this.favoriteList = [];
      await this.saveFavorites();
      return true;
    } catch (error) {
      console.error('清空收藏失败:', error);
      return false;
    }
  }

  /**
   * 获取收藏数量
   */
  getFavoriteCount(): number {
    return this.favoriteList.length;
  }
}

// 导出单例实例
export const favoriteService = FavoriteService.getInstance();