// 相机数据模型 (兼容旧版本)
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

// 价格信息接口
export interface PriceInfo {
  launch_price_usd?: number;
  launch_price_cny?: number;
  current_price_usd?: number;
  current_price_cny?: number;
  price_history?: PriceHistoryItem[];
}

// 价格历史记录项
export interface PriceHistoryItem {
  date: string;
  price_usd?: number;
  price_cny?: number;
  source?: string;
}

// 相机规格接口
export interface CameraSpecsExtended {
  sensor_resolution?: string;
  sensor_size?: string;
  sensor_type?: string;
  iso_range?: string;
  iso_extended?: string;
  shutter_speed?: string;
  continuous_shooting?: string;
  autofocus_points?: string;
  autofocus_type?: string;
  metering_modes?: string;
  video_resolution?: string;
  video_codec?: string;
  lcd_size?: string;
  lcd_resolution?: string;
  lcd_type?: string;
  viewfinder_type?: string;
  viewfinder_coverage?: string;
  viewfinder_magnification?: string;
  storage_slots?: string;
  storage_types?: string;
  connectivity?: string;
  battery_life?: string;
  battery_type?: string;
  dimensions?: string;
  weight?: string;
  weather_sealing?: boolean;
  image_stabilization?: string;
  flash_sync_speed?: string;
  special_features?: string[];
}

// 扩展相机数据模型 (新版本，与CameraModel兼容)
export interface ExtendedCamera extends Camera {
  id_string?: string; // 字符串ID
  model_name?: string; // 型号名称
  full_name?: string; // 完整名称
  brand_name_en?: string; // 英文品牌名
  brand_name_zh?: string; // 中文品牌名
  announcement_date?: string; // 发布日期
  availability_date?: string; // 上市日期
  camera_type?: string; // 相机类型
  sensor_format?: string; // 传感器画幅
  status?: string; // 产品状态
  cover_image?: string; // 封面图片
  gallery_images?: string[]; // 图片库
  price_info?: PriceInfo;
  specs?: CameraSpecsExtended;
  key_features?: string[];
  target_audience?: string[];
  competitors?: string[];
  created_at?: string;
  updated_at?: string;
  data_source?: string;
  data_quality?: number;
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

// 输入相机模型接口（用于类型安全的转换）
export interface InputCameraModel {
  id?: string;
  model_name?: string;
  brand_name_zh?: string;
  brand_name_en?: string;
  release_date?: string;
  camera_type?: string;
  sensor_format?: string;
  cover_image?: string;
  description?: string;
  price_info?: PriceInfo;
  specs?: CameraSpecsExtended;
}

// 工具函数：将CameraModel转换为Camera格式
export function convertCameraModelToCamera(cameraModel: InputCameraModel): Camera {
  // 生成数字ID（基于字符串ID的哈希）
  const numericId = cameraModel.id ? hashStringToNumber(cameraModel.id) : Math.floor(Math.random() * 1000000);
  
  // 映射相机类型
  const mapCameraType = (type: string | undefined): CameraCategory => {
    switch (type?.toLowerCase()) {
      case 'mirrorless': return CameraCategory.MIRRORLESS;
      case 'dslr': return CameraCategory.DSLR;
      case 'compact': return CameraCategory.COMPACT;
      case 'instant': return CameraCategory.INSTANT;
      case 'film': return CameraCategory.FILM;
      case 'medium format': return CameraCategory.MEDIUM_FORMAT;
      case 'large format': return CameraCategory.LARGE_FORMAT;
      default: return CameraCategory.MIRRORLESS;
    }
  };
  
  // 映射传感器画幅
  const mapSensorFormat = (format: string | undefined): SensorFormat => {
    switch (format?.toLowerCase()) {
      case 'full frame': return SensorFormat.FULL_FRAME;
      case 'aps-c': return SensorFormat.APS_C;
      case 'aps-h': return SensorFormat.APS_H;
      case 'micro four thirds':
      case 'm43': return SensorFormat.MICRO_FOUR_THIRDS;
      case 'medium format': return SensorFormat.MEDIUM_FORMAT;
      case 'large format': return SensorFormat.LARGE_FORMAT;
      case '1 inch':
      case '1英寸': return SensorFormat.ONE_INCH;
      case 'four thirds':
      case '4/3': return SensorFormat.FOUR_THIRDS;
      default: return SensorFormat.FULL_FRAME;
    }
  };
  
  return {
    id: numericId,
    brand: cameraModel.brand_name_zh || cameraModel.brand_name_en || '',
    model: cameraModel.model_name || '',
    releaseDate: cameraModel.release_date || '',
    releasePrice: cameraModel.price_info?.launch_price_cny || cameraModel.price_info?.launch_price_usd || 0,
    imageUrl: cameraModel.cover_image || '',
    description: cameraModel.description || '',
    specifications: {
      sensorType: cameraModel.specs?.sensor_type || '',
      megapixels: parseFloat(cameraModel.specs?.sensor_resolution?.replace('MP', '') || '0'),
      isoRange: cameraModel.specs?.iso_range || '',
      shutterSpeed: cameraModel.specs?.shutter_speed || '',
      lensMount: '', // 需要从其他地方获取
      videoCapability: cameraModel.specs?.video_resolution || '',
      weight: parseFloat(cameraModel.specs?.weight?.replace('g', '') || '0'),
      dimensions: cameraModel.specs?.dimensions || ''
    },
    category: mapCameraType(cameraModel.camera_type),
    sensorFormat: mapSensorFormat(cameraModel.sensor_format)
  };
}

// 简单的字符串哈希函数
function hashStringToNumber(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // 转换为32位整数
  }
  return Math.abs(hash);
}