// 相机数据模型
export interface Camera {
  id: number;
  brand: string;
  model: string;
  releaseDate: string;
  releasePrice: number; // 发布价格
  imageUrl: string;
  description: string;
  specifications: CameraSpecs;
  category: CameraCategory;
  sensorFormat: SensorFormat; // 画幅
}

// 相机规格
export interface CameraSpecs {
  sensorType: string;
  megapixels: number;
  isoRange: string;
  shutterSpeed: string;
  lensMount: string;
  videoCapability: string;
  weight: number; // 克
  dimensions: string; // 长x宽x高 (mm)
}

// 相机类别
export enum CameraCategory {
  DSLR = '单反',
  MIRRORLESS = '微单',
  COMPACT = '卡片机',
  INSTANT = '拍立得',
  FILM = '胶片机',
  MEDIUM_FORMAT = '中画幅',
  LARGE_FORMAT = '大画幅'
}

// 传感器画幅
export enum SensorFormat {
  FULL_FRAME = '全画幅',
  APS_C = '半画幅',
  APS_H = 'APS-H',
  MICRO_FOUR_THIRDS = 'M43',
  MEDIUM_FORMAT = '中画幅',
  LARGE_FORMAT = '大画幅',
  ONE_INCH = '1英寸',
  FOUR_THIRDS = '4/3'
}

// 相机品牌
export enum CameraBrand {
  CANON = 'Canon',
  NIKON = 'Nikon',
  SONY = 'Sony',
  FUJIFILM = 'Fujifilm',
  OLYMPUS = 'Olympus',
  PANASONIC = 'Panasonic',
  LEICA = 'Leica',
  PENTAX = 'Pentax',
  HASSELBLAD = 'Hasselblad',
  MAMIYA = 'Mamiya'
}

// 相机数据服务接口
export interface CameraService {
  getAllCameras(): Camera[];
  getCameraById(id: number): Camera | undefined;
  getCamerasByBrand(brand: string): Camera[];
  getCamerasByCategory(category: CameraCategory): Camera[];
  searchCameras(keyword: string): Camera[];
}