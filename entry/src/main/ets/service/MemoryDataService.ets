import preferences from '@ohos.data.preferences';
import { CameraDataItem } from './CameraDataJsonService';

// 回忆相机数据接口
export interface MemoryCamera {
  id: string;
  camera: CameraDataItem;
  addedDate: string;
  description?: string;
}

// 回忆数据存储服务
export class MemoryDataService {
  private static instance: MemoryDataService;
  private preferencesHelper: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME = 'memory_preferences';
  private readonly MEMORY_KEY = 'memory_cameras';
  
  private constructor() {}
  
  static getInstance(): MemoryDataService {
    if (!MemoryDataService.instance) {
      MemoryDataService.instance = new MemoryDataService();
    }
    return MemoryDataService.instance;
  }
  
  // 初始化数据存储服务
  async init() {
    try {
      this.preferencesHelper = await preferences.getPreferences(getContext(), this.PREFERENCES_NAME);
    } catch (error) {
      console.error('MemoryDataService init failed:', error);
    }
  }
  
  // 保存回忆数据
  async saveMemoryCameras(memoryCameras: MemoryCamera[]): Promise<boolean> {
    try {
      if (this.preferencesHelper) {
        await this.preferencesHelper.put(this.MEMORY_KEY, JSON.stringify(memoryCameras));
        await this.preferencesHelper.flush();
        return true;
      }
    } catch (error) {
      console.error('Save memory cameras failed:', error);
    }
    return false;
  }
  
  // 加载回忆数据
  async loadMemoryCameras(): Promise<MemoryCamera[]> {
    try {
      if (this.preferencesHelper) {
        const savedData = await this.preferencesHelper.get(this.MEMORY_KEY, '[]') as string;
        return JSON.parse(savedData) as MemoryCamera[];
      }
    } catch (error) {
      console.error('Load memory cameras failed:', error);
    }
    return [];
  }
  
  // 添加单个回忆相机
  async addMemoryCamera(memoryCamera: MemoryCamera): Promise<boolean> {
    try {
      const memoryCameras = await this.loadMemoryCameras();
      memoryCameras.push(memoryCamera);
      return await this.saveMemoryCameras(memoryCameras);
    } catch (error) {
      console.error('Add memory camera failed:', error);
      return false;
    }
  }
  
  // 删除回忆相机
  async removeMemoryCamera(cameraId: string): Promise<boolean> {
    try {
      const memoryCameras = await this.loadMemoryCameras();
      const filteredCameras = memoryCameras.filter(memory => memory.id !== cameraId);
      return await this.saveMemoryCameras(filteredCameras);
    } catch (error) {
      console.error('Remove memory camera failed:', error);
      return false;
    }
  }
  
  // 清空所有回忆数据
  async clearAllMemories(): Promise<boolean> {
    try {
      return await this.saveMemoryCameras([]);
    } catch (error) {
      console.error('Clear all memories failed:', error);
      return false;
    }
  }
  
  // 检查相机是否已存在
  async isCameraExists(brand: string, model: string): Promise<boolean> {
    try {
      const memoryCameras = await this.loadMemoryCameras();
      return memoryCameras.some(memory => 
        memory.camera.Brand === brand && memory.camera.Model === model
      );
    } catch (error) {
      console.error('Check camera exists failed:', error);
      return false;
    }
  }
}

// 导出单例实例
export const memoryDataService = MemoryDataService.getInstance();