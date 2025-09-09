import { MyEquipmentItem } from '../model/MyEquipmentModel';
import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

class MyEquipmentService {
  private static instance: MyEquipmentService;
  private equipmentList: MyEquipmentItem[] = [];
  private context: common.UIAbilityContext | null = null;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): MyEquipmentService {
    if (!MyEquipmentService.instance) {
      MyEquipmentService.instance = new MyEquipmentService();
    }
    return MyEquipmentService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    try {
      this.preferencesStore = await preferences.getPreferences(context, 'my_equipment_data');
      await this.loadEquipmentData();
    } catch (error) {
      console.error('初始化我的器材服务失败:', error);
    }
  }

  private async loadEquipmentData(): Promise<void> {
    try {
      if (this.preferencesStore) {
        const dataStr = await this.preferencesStore.get('equipment_list', '[]') as string;
        this.equipmentList = JSON.parse(dataStr);
      }
    } catch (error) {
      console.error('加载器材数据失败:', error);
      this.equipmentList = [];
    }
  }

  private async saveEquipmentData(): Promise<void> {
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.put('equipment_list', JSON.stringify(this.equipmentList));
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('保存器材数据失败:', error);
    }
  }

  // 添加器材
  async addEquipment(equipment: MyEquipmentItem): Promise<boolean> {
    try {
      const newEquipment: MyEquipmentItem = {
        id: equipment.id || Date.now(),
        cameraId: equipment.cameraId,
        cameraDataItem: equipment.cameraDataItem,
        equipmentName: equipment.equipmentName,
        brand: equipment.brand,
        model: equipment.model,
        transactions: equipment.transactions,
        imageUrl: equipment.imageUrl,
        addTime: equipment.addTime || new Date().toISOString()
      };
      
      this.equipmentList.push(newEquipment);
      await this.saveEquipmentData();
      return true;
    } catch (error) {
      console.error('添加器材失败:', error);
      return false;
    }
  }

  // 获取所有器材
  getAllEquipment(): MyEquipmentItem[] {
    return this.equipmentList.slice();
  }

  // 根据ID获取器材
  getEquipmentById(id: number): MyEquipmentItem | null {
    return this.equipmentList.find(item => item.id === id) || null;
  }

  // 删除器材
  async deleteEquipment(id: number): Promise<boolean> {
    try {
      const index = this.equipmentList.findIndex(item => item.id === id);
      if (index !== -1) {
        this.equipmentList.splice(index, 1);
        await this.saveEquipmentData();
        return true;
      }
      return false;
    } catch (error) {
      console.error('删除器材失败:', error);
      return false;
    }
  }

  // 更新器材
  async updateEquipment(id: number, updates: Partial<MyEquipmentItem>): Promise<boolean> {
    try {
      const index = this.equipmentList.findIndex(item => item.id === id);
      if (index !== -1) {
        const currentItem = this.equipmentList[index];
        this.equipmentList[index] = {
          id: updates.id !== undefined ? updates.id : currentItem.id,
          cameraId: updates.cameraId !== undefined ? updates.cameraId : currentItem.cameraId,
          cameraDataItem: updates.cameraDataItem !== undefined ? updates.cameraDataItem : currentItem.cameraDataItem,
          equipmentName: updates.equipmentName !== undefined ? updates.equipmentName : currentItem.equipmentName,
          brand: updates.brand !== undefined ? updates.brand : currentItem.brand,
          model: updates.model !== undefined ? updates.model : currentItem.model,
          transactions: updates.transactions !== undefined ? updates.transactions : currentItem.transactions,
          imageUrl: updates.imageUrl !== undefined ? updates.imageUrl : currentItem.imageUrl,
          addTime: updates.addTime !== undefined ? updates.addTime : currentItem.addTime
        };
        await this.saveEquipmentData();
        return true;
      }
      return false;
    } catch (error) {
      console.error('更新器材失败:', error);
      return false;
    }
  }

  // 获取买入的器材
  getBoughtEquipment(): MyEquipmentItem[] {
    return this.equipmentList.filter(item => 
      item.transactions.some(transaction => transaction.type === 'buy')
    );
  }

  // 获取卖出的器材
  getSoldEquipment(): MyEquipmentItem[] {
    return this.equipmentList.filter(item => 
      item.transactions.some(transaction => transaction.type === 'sell')
    );
  }

  // 清空所有数据
  async clearAllData(): Promise<boolean> {
    try {
      this.equipmentList = [];
      await this.saveEquipmentData();
      return true;
    } catch (error) {
      console.error('清空数据失败:', error);
      return false;
    }
  }
}

export const myEquipmentService = MyEquipmentService.getInstance();