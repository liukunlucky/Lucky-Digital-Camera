// 样张库数据模型
import { CameraDataItem } from "../service/CameraDataJsonService";

// 样张信息接口
export interface SamplePhoto {
  id: string;                    // 样张ID
  title: string;                 // 样张标题
  description?: string;          // 样张描述
  imageUri: string;              // 图片URI
  thumbnailUri?: string;         // 缩略图URI
  cameraId: string;              // 关联的相机ID
  cameraBrand: string;           // 相机品牌
  cameraModel: string;
  cameraDataItem: CameraDataItem | undefined; // 关联的相机
  shootingParams: ShootingParams; // 拍摄参数
  tags: string[];                // 标签
  category: PhotoCategory;       // 分类
  uploadTime: string;            // 上传时间
  photographer?: string;         // 摄影师
  location?: string;             // 拍摄地点
  likes: number;                 // 点赞数
  views: number;                 // 查看数
  isPublic: boolean;             // 是否公开
  userId: string;                // 用户ID
}

// 拍摄参数接口
export interface ShootingParams {
  aperture?: string;             // 光圈值，如"f/2.8"
  shutterSpeed?: string;         // 快门速度，如"1/125s"
  iso?: string;                  // ISO值，如"ISO 400"
  focalLength?: string;          // 焦距，如"85mm"
  exposureMode?: string;         // 曝光模式
  meteringMode?: string;         // 测光模式
  whiteBalance?: string;         // 白平衡
  flashMode?: string;            // 闪光灯模式
  lens?: string;                 // 镜头信息
}

// 照片分类枚举
export enum PhotoCategory {
  PORTRAIT = 'portrait',         // 人像
  LANDSCAPE = 'landscape',       // 风景
  STREET = 'street',             // 街拍
  MACRO = 'macro',               // 微距
  WILDLIFE = 'wildlife',         // 野生动物
  ARCHITECTURE = 'architecture', // 建筑
  SPORTS = 'sports',             // 运动
  NIGHT = 'night',               // 夜景
  ABSTRACT = 'abstract',         // 抽象
  DOCUMENTARY = 'documentary',   // 纪实
  FASHION = 'fashion',           // 时尚
  FOOD = 'food',                 // 美食
  OTHER = 'other'                // 其他
}

// 样张筛选条件接口
export interface SampleFilter {
  cameraId?: string;             // 相机ID筛选
  brand?: string;                // 品牌筛选
  category?: PhotoCategory;      // 分类筛选
  tags?: string[];               // 标签筛选
  photographer?: string;         // 摄影师筛选
  sortBy?: SortType;             // 排序方式
  isPublic?: boolean;            // 是否公开
}

// 排序类型枚举
export enum SortType {
  UPLOAD_TIME_DESC = 'upload_time_desc',  // 上传时间降序
  UPLOAD_TIME_ASC = 'upload_time_asc',    // 上传时间升序
  LIKES_DESC = 'likes_desc',              // 点赞数降序
  VIEWS_DESC = 'views_desc',              // 查看数降序
  TITLE_ASC = 'title_asc'                 // 标题升序
}

export interface HotLabel {
  tag: string;           // 总样张数
  count: number;            // 总查看数
}

// 样张统计信息接口
export interface SampleStats {
  totalPhotos: number;           // 总样张数
  totalViews: number;            // 总查看数
  totalLikes: number;            // 总点赞数
  categoryCounts: Map<PhotoCategory, number>; // 各分类数量
  brandCounts: Map<string, number>;           // 各品牌数量
  popularTags: Array<HotLabel>; // 热门标签
}

// 相机样张统计接口
export interface CameraSampleStats {
  cameraId: string;              // 相机ID
  cameraBrand: string;           // 相机品牌
  cameraModel: string;           // 相机型号
  photoCount: number;            // 样张数量
  avgLikes: number;              // 平均点赞数
  avgViews: number;              // 平均查看数
  popularCategories: PhotoCategory[]; // 热门分类
  samplePhotos: SamplePhoto[];   // 代表性样张
}

// 上传样张请求接口
export interface UploadSampleRequest {
  title: string;
  description?: string;
  cameraId: string;
  cameraDataItem: CameraDataItem | undefined;
  shootingParams: ShootingParams;
  tags: string[];
  category: PhotoCategory;
  photographer?: string;
  location?: string;
  isPublic: boolean;
}

// 样张详情接口
export interface SamplePhotoDetail extends SamplePhoto {
  exifData?: ExifData;           // EXIF数据
  relatedPhotos: SamplePhoto[];  // 相关样张
  comments: PhotoComment[];      // 评论
}

// EXIF数据接口
export interface ExifData {
  make?: string;                 // 制造商
  model?: string;                // 型号
  dateTime?: string;             // 拍摄时间
  orientation?: number;          // 方向
  xResolution?: number;          // X分辨率
  yResolution?: number;          // Y分辨率
  software?: string;             // 软件
  artist?: string;               // 艺术家
  copyright?: string;            // 版权
  gpsLatitude?: number;          // GPS纬度
  gpsLongitude?: number;         // GPS经度
}

// 照片评论接口
export interface PhotoComment {
  id: string;                    // 评论ID
  photoId: string;               // 照片ID
  userId: string;                // 用户ID
  userName: string;              // 用户名
  content: string;               // 评论内容
  createTime: string;            // 创建时间
  likes: number;                 // 点赞数
  replies: PhotoComment[];       // 回复
}

// 分类显示名称映射
export const CATEGORY_NAMES: Record<PhotoCategory, string> = {
  [PhotoCategory.PORTRAIT]: '人像',
  [PhotoCategory.LANDSCAPE]: '风景',
  [PhotoCategory.STREET]: '街拍',
  [PhotoCategory.MACRO]: '微距',
  [PhotoCategory.WILDLIFE]: '野生动物',
  [PhotoCategory.ARCHITECTURE]: '建筑',
  [PhotoCategory.SPORTS]: '运动',
  [PhotoCategory.NIGHT]: '夜景',
  [PhotoCategory.ABSTRACT]: '抽象',
  [PhotoCategory.DOCUMENTARY]: '纪实',
  [PhotoCategory.FASHION]: '时尚',
  [PhotoCategory.FOOD]: '美食',
  [PhotoCategory.OTHER]: '其他'
};

// 预定义标签
export const PREDEFINED_TAGS = [
  '自然光', '人工光', '逆光', '侧光', '顶光',
  '黄金时间', '蓝调时间', '日出', '日落', '夜景',
  '室内', '室外', '工作室', '街头', '旅行',
  '黑白', '彩色', '高对比', '低对比', '柔光',
  '锐利', '虚化', '景深', '广角', '长焦',
  '微距', '全景', '抓拍', '摆拍', '连拍'
];