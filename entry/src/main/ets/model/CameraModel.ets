/**
 * 相机型号详细数据模型
 */

// 相机类型枚举
export enum CameraType {
  DSLR = 'DSLR', // 单反相机
  MIRRORLESS = 'Mirrorless', // 微单相机
  COMPACT = 'Compact', // 便携相机
  ACTION = 'Action', // 运动相机
  INSTANT = 'Instant', // 拍立得
  MEDIUM_FORMAT = 'Medium Format', // 中画幅
  LARGE_FORMAT = 'Large Format', // 大画幅
  FILM = 'Film' // 胶片相机
}

// 画幅类型枚举
export enum SensorFormat {
  FULL_FRAME = 'Full Frame', // 全画幅
  APS_C = 'APS-C', // APS-C画幅
  APS_H = 'APS-H', // APS-H画幅
  MICRO_FOUR_THIRDS = 'Micro Four Thirds', // M4/3画幅
  FOUR_THIRDS = 'Four Thirds', // 4/3画幅
  MEDIUM_FORMAT = 'Medium Format', // 中画幅
  LARGE_FORMAT = 'Large Format', // 大画幅
  ONE_INCH = '1"', // 1英寸
  TWO_THIRDS_INCH = '2/3"', // 2/3英寸
  HALF_INCH = '1/2"', // 1/2英寸
  QUARTER_INCH = '1/4"' // 1/4英寸
}

// 相机状态枚举
export enum CameraStatus {
  IN_PRODUCTION = 'In Production', // 在售
  DISCONTINUED = 'Discontinued', // 停产
  ANNOUNCED = 'Announced', // 已发布未上市
  RUMORED = 'Rumored' // 传闻
}

// 核心参数接口
export interface CameraSpecs {
  // 传感器参数
  sensor_resolution: string; // 传感器分辨率，如"24.2MP"
  sensor_size: string; // 传感器尺寸，如"35.9 x 24.0mm"
  sensor_type: string; // 传感器类型，如"CMOS"
  
  // ISO参数
  iso_range: string; // ISO范围，如"100-51200"
  iso_extended: string; // 扩展ISO，如"50-204800"
  
  // 快门参数
  shutter_speed: string; // 快门速度，如"1/8000 - 30s"
  
  // 连拍参数
  continuous_shooting: string; // 连拍速度，如"10fps"
  
  // 对焦参数
  autofocus_points: string; // 对焦点数量，如"61点"
  autofocus_type: string; // 对焦类型，如"相位检测+对比检测"
  
  // 测光参数
  metering_modes: string; // 测光模式，如"矩阵/中央重点/点测光"
  
  // 视频参数
  video_resolution: string; // 视频分辨率，如"4K UHD 30p"
  video_codec: string; // 视频编码，如"H.264/H.265"
  
  // 显示屏参数
  lcd_size: string; // 显示屏尺寸，如"3.2英寸"
  lcd_resolution: string; // 显示屏分辨率，如"2,100,000点"
  lcd_type: string; // 显示屏类型，如"触摸屏/翻转屏"
  
  // 取景器参数
  viewfinder_type: string; // 取景器类型，如"光学/电子"
  viewfinder_coverage: string; // 取景器覆盖率，如"100%"
  viewfinder_magnification: string; // 取景器放大倍率，如"0.76x"
  
  // 存储参数
  storage_slots: string; // 存储卡槽，如"双SD卡槽"
  storage_types: string; // 存储卡类型，如"SD/SDHC/SDXC"
  
  // 连接参数
  connectivity: string; // 连接方式，如"Wi-Fi/蓝牙/USB-C"
  
  // 电池参数
  battery_life: string; // 电池续航，如"1200张"
  battery_type: string; // 电池型号，如"EN-EL15c"
  
  // 物理参数
  dimensions: string; // 机身尺寸，如"146 x 124 x 85mm"
  weight: string; // 重量，如"675g"
  weather_sealing: boolean; // 防护等级
  
  // 其他特性
  image_stabilization: string; // 防抖系统，如"5轴机身防抖"
  flash_sync_speed: string; // 闪光同步速度，如"1/250s"
  special_features: string[]; // 特殊功能，如["静音拍摄", "像素偏移"]
}

// 价格历史记录接口
export interface PriceHistoryItem {
  date: string;
  price_usd: number;
  price_cny: number;
  source: string;
}

// 评测信息接口
export interface ReviewInfo {
  source: string; // 评测来源
  score: number; // 评分
  review_url: string; // 评测链接
  summary: string; // 评测摘要
}

// 奖项信息接口
export interface AwardInfo {
  award_name: string; // 奖项名称
  organization: string; // 颁奖机构
  year: number; // 获奖年份
}

// 价格信息接口
export interface PriceInfo {
  launch_price_usd: number; // 发布价格（美元）
  launch_price_cny: number; // 发布价格（人民币）
  current_price_usd?: number; // 当前价格（美元）
  current_price_cny?: number; // 当前价格（人民币）
  price_history: PriceHistoryItem[]; // 价格历史
}

// 相机型号主接口
export interface CameraModel {
  id: string; // 唯一标识符
  model_name: string; // 型号名称，如"EOS R5"
  full_name: string; // 完整名称，如"Canon EOS R5"
  brand_name_en: string; // 品牌英文名
  brand_name_zh: string; // 品牌中文名
  
  // 基本信息
  release_date: string; // 发布日期，格式：YYYY-MM-DD
  announcement_date: string; // 公布日期
  availability_date?: string; // 上市日期
  discontinuation_date?: string; // 停产日期
  
  // 分类信息
  camera_type: CameraType; // 相机类型
  sensor_format: SensorFormat; // 画幅类型
  status: CameraStatus; // 当前状态
  
  // 媒体资源
  cover_image: string; // 封面图片URL
  gallery_images: string[]; // 图片库
  promotional_video?: string; // 宣传视频URL
  
  // 价格信息
  price_info: PriceInfo;
  
  // 技术规格
  specs: CameraSpecs;
  
  // 描述信息
  description: string; // 产品描述
  key_features: string[]; // 主要特性
  target_audience: string[]; // 目标用户群体，如["专业摄影师", "视频创作者"]
  
  // 竞品信息
  competitors: string[]; // 竞品型号ID列表
  
  // 评测信息
  reviews?: ReviewInfo[];
  
  // 奖项信息
  awards?: AwardInfo[];
  
  // 元数据
  created_at: string; // 数据创建时间
  updated_at: string; // 数据更新时间
  data_source: string; // 数据来源
  data_quality: number; // 数据质量评分 (1-10)
}

// 相机型号服务接口
export interface CameraModelService {
  // 获取所有相机型号
  getAllModels(): Promise<CameraModel[]>;
  
  // 按品牌获取相机型号
  getModelsByBrand(brandNameZh: string): Promise<CameraModel[]>;
  
  // 按类型获取相机型号
  getModelsByType(cameraType: CameraType): Promise<CameraModel[]>;
  
  // 按画幅获取相机型号
  getModelsByFormat(sensorFormat: SensorFormat): Promise<CameraModel[]>;
  
  // 按状态获取相机型号
  getModelsByStatus(status: CameraStatus): Promise<CameraModel[]>;
  
  // 按价格范围获取相机型号
  getModelsByPriceRange(minPrice: number, maxPrice: number): Promise<CameraModel[]>;
  
  // 按发布年份获取相机型号
  getModelsByYear(year: number): Promise<CameraModel[]>;
  
  // 获取单个相机型号详情
  getModelById(id: string): Promise<CameraModel | null>;
  
  // 搜索相机型号
  searchModels(keyword: string): Promise<CameraModel[]>;
  
  // 获取热门相机型号
  getPopularModels(limit?: number): Promise<CameraModel[]>;
  
  // 获取最新相机型号
  getLatestModels(limit?: number): Promise<CameraModel[]>;
}