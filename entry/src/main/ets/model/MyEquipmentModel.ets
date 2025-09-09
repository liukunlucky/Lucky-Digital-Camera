// 我的器材数据模型

import { CameraDataItem } from '../service/CameraDataJsonService';

export interface MyEquipmentItem {
  id: number;
  cameraId?: number; // 关联的相机ID（如果是从相机库选择的）
  cameraDataItem?: CameraDataItem; // 关联的相机数据项
  equipmentName: string; // 器材名称
  brand: string; // 品牌
  model: string; // 型号
  imageUrl?: string; // 图片URL
  transactions: EquipmentTransaction[]; // 交易记录
  addTime: string; // 添加时间
}

export interface EquipmentTransaction {
  type: 'buy' | 'sell';
  date: string;
  price?: number;
  notes?: string;
}