// 相机评分和标签数据模型

// 用户评分接口
export interface CameraRating {
  cameraId: string; // 相机ID (Brand_Model格式)
  rating: number; // 评分 (1-5星)
  tags: string[]; // 用户标签
  comment?: string; // 评论
  createdAt: string; // 创建时间
  updatedAt: string; // 更新时间
}

// 相机统计评分接口
export interface CameraRatingStats {
  cameraId: string;
  averageRating: number; // 平均评分
  totalRatings: number; // 评分总数
  ratingDistribution: Map<number, number>; // 评分分布
  popularTags: TagCount[]; // 热门标签
}

// 标签计数接口
export interface TagCount {
  tag: string;
  count: number;
}

// 预定义标签
export const PREDEFINED_TAGS = [
  '色彩科学好',
  '对焦迅猛',
  '视频神器',
  '便携轻巧',
  '画质出色',
  '操控优秀',
  '续航持久',
  '性价比高',
  '专业级',
  '入门友好',
  '低光表现',
  '防抖优秀',
  '连拍强悍',
  '触屏灵敏',
  '菜单简洁',
  '做工精良',
  '镜头群丰富',
  '升级潜力',
  '二手保值',
  '维修方便'
];

// 相似产品推荐接口
export interface SimilarCamera {
  cameraId: string;
  brand: string;
  model: string;
  similarityScore: number; // 相似度评分 (0-1)
  similarityReasons: string[]; // 相似原因
  imageUrl?: string;
  priceRange?: string;
}

// 升级路径推荐接口
export interface UpgradeCamera {
  cameraId: string;
  brand: string;
  model: string;
  upgradeScore: number; // 升级推荐度 (0-1)
  upgradeReasons: string[]; // 升级原因
  imageUrl?: string;
  priceRange?: string;
  upgradeType: 'entry_to_mid' | 'mid_to_pro' | 'brand_switch' | 'format_upgrade'; // 升级类型
}