import { CameraRating, CameraRatingStats, TagCount, SimilarCamera, UpgradeCamera, PREDEFINED_TAGS } from '../model/CameraRating';
import { CameraDataItem } from './CameraDataJsonService';
import preferences from '@ohos.data.preferences';

// 升级潜力结果接口
interface UpgradePotentialResult {
  score: number;
  reasons: string[];
  type: 'entry_to_mid' | 'mid_to_pro' | 'brand_switch' | 'format_upgrade';
}

// 相似度计算结果接口
interface SimilarityResult {
  score: number;
  reasons: string[];
}

// 相机评分和推荐服务
class CameraRatingService {
  private context: Context | undefined = undefined;
  private preferencesStore: preferences.Preferences | undefined = undefined;
  private ratings: Map<string, CameraRating[]> = new Map();
  private ratingStats: Map<string, CameraRatingStats> = new Map();

  // 初始化服务
  async init(context: Context): Promise<void> {
    this.context = context;
    try {
      this.preferencesStore = await preferences.getPreferences(context, 'camera_ratings');
      await this.loadRatings();
      this.calculateStats();
    } catch (error) {
      console.error('初始化评分服务失败:', error);
    }
  }

  // 加载评分数据
  private async loadRatings(): Promise<void> {
    try {
      if (!this.preferencesStore) return;

      const ratingsData = await this.preferencesStore.get('ratings', '{}') as string;
      const ratingsObj: Record<string, CameraRating[]> = JSON.parse(ratingsData);

      this.ratings.clear();
      Object.keys(ratingsObj).forEach((key: string) => {
        this.ratings.set(key, ratingsObj[key]);
      });
    } catch (error) {
      console.error('加载评分数据失败:', error);
    }
  }

  // 保存评分数据
  private async saveRatings(): Promise<void> {
    try {
      if (!this.preferencesStore) return;

      const ratingsObj: Record<string, CameraRating[]> = {};
      this.ratings.forEach((value, key) => {
        ratingsObj[key] = value;
      });

      await this.preferencesStore.put('ratings', JSON.stringify(ratingsObj));
      await this.preferencesStore.flush();
    } catch (error) {
      console.error('保存评分数据失败:', error);
    }
  }

  // 生成相机ID
  private generateCameraId(brand: string, model: string): string {
    return `${brand}_${model}`.replace(/\s+/g, '_');
  }

  // 添加或更新评分
  async addOrUpdateRating(brand: string, model: string, rating: number, tags: string[], comment?: string): Promise<void> {
    const cameraId = this.generateCameraId(brand, model);
    const now = new Date().toISOString();

    const existingRatings = this.ratings.get(cameraId) || [];
    const newRating: CameraRating = {
      cameraId,
      rating,
      tags,
      comment,
      createdAt: now,
      updatedAt: now
    };

    existingRatings.push(newRating);
    this.ratings.set(cameraId, existingRatings);
    await this.saveRatings();
    this.calculateStats();
  }

  // 获取相机评分
  getRating(brand: string, model: string): CameraRating | undefined {
    const cameraId = this.generateCameraId(brand, model);
    const ratings = this.ratings.get(cameraId);
    return ratings && ratings.length > 0 ? ratings[ratings.length - 1] : undefined;
  }

  // 获取相机评分统计
  getRatingStats(brand: string, model: string): CameraRatingStats | undefined {
    const cameraId = this.generateCameraId(brand, model);
    return this.ratingStats.get(cameraId);
  }

  // 计算评分统计
  private calculateStats(): void {
    this.ratingStats.clear();

    // 按相机ID分组统计
    const cameraGroups = new Map<string, CameraRating[]>();
    this.ratings.forEach((ratings, cameraId) => {
      cameraGroups.set(cameraId, ratings);
    });

    // 计算每个相机的统计数据
    cameraGroups.forEach((ratings, cameraId) => {
      const totalRatings = ratings.length;
      const averageRating = ratings.reduce((sum, r) => sum + r.rating, 0) / totalRatings;

      // 评分分布
      const ratingDistribution = new Map<number, number>();
      ratingDistribution.set(1, 0);
      ratingDistribution.set(2, 0);
      ratingDistribution.set(3, 0);
      ratingDistribution.set(4, 0);
      ratingDistribution.set(5, 0);
      ratings.forEach(r => {
        ratingDistribution.set(r.rating, (ratingDistribution.get(r.rating) || 0) + 1);
      });

      // 标签统计
      const tagCounts = new Map<string, number>();
      ratings.forEach(r => {
        r.tags.forEach(tag => {
          tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
        });
      });

      const popularTags: TagCount[] = Array.from(tagCounts.entries())
        .map((entry: [string, number]) => {
          const tagCount: TagCount = { tag: entry[0], count: entry[1] };
          return tagCount;
        })
        .sort((a: TagCount, b: TagCount) => b.count - a.count)
        .slice(0, 10);

      this.ratingStats.set(cameraId, {
        cameraId,
        averageRating,
        totalRatings,
        ratingDistribution,
        popularTags
      });
    });
  }

  // 获取相似产品推荐
  getSimilarCameras(targetCamera: CameraDataItem, allCameras: CameraDataItem[]): SimilarCamera[] {
    const similarities: SimilarCamera[] = [];

    allCameras.forEach(camera => {
      if (camera.Brand === targetCamera.Brand && camera.Model === targetCamera.Model) {
        return; // 跳过自己
      }

      const similarity = this.calculateSimilarity(targetCamera, camera);
      if (similarity.score > 0.3) { // 相似度阈值
        similarities.push({
          cameraId: this.generateCameraId(camera.Brand, camera.Model),
          brand: camera.Brand,
          model: camera.Model,
          similarityScore: similarity.score,
          similarityReasons: similarity.reasons,
          imageUrl: camera.image_file,
          priceRange: this.getPriceRange(camera)
        });
      }
    });

    return similarities.sort((a, b) => b.similarityScore - a.similarityScore).slice(0, 6);
  }

  // 获取升级路径推荐
  getUpgradeCameras(targetCamera: CameraDataItem, allCameras: CameraDataItem[]): UpgradeCamera[] {
    const upgrades: UpgradeCamera[] = [];

    allCameras.forEach(camera => {
      if (camera.Brand === targetCamera.Brand && camera.Model === targetCamera.Model) {
        return; // 跳过自己
      }

      const upgrade = this.calculateUpgradePotential(targetCamera, camera);
      if (upgrade.score > 0.4) { // 升级推荐阈值
        upgrades.push({
          cameraId: this.generateCameraId(camera.Brand, camera.Model),
          brand: camera.Brand,
          model: camera.Model,
          upgradeScore: upgrade.score,
          upgradeReasons: upgrade.reasons,
          imageUrl: camera.image_file,
          priceRange: this.getPriceRange(camera),
          upgradeType: upgrade.type
        });
      }
    });

    return upgrades.sort((a, b) => b.upgradeScore - a.upgradeScore).slice(0, 5);
  }

  // 计算相似度
  private calculateSimilarity(camera1: CameraDataItem, camera2: CameraDataItem): SimilarityResult {
    let score = 0;
    const reasons: string[] = [];

    // 品牌相同 +0.3
    if (camera1.Brand === camera2.Brand) {
      score += 0.3;
      reasons.push('同品牌产品');
    }

    // 像素相近 +0.2
    const mp1 = parseFloat(camera1.Megapixels?.replace('MP', '') || '0');
    const mp2 = parseFloat(camera2.Megapixels?.replace('MP', '') || '0');
    if (Math.abs(mp1 - mp2) <= 5) {
      score += 0.2;
      reasons.push('像素相近');
    }

    // 重量相近 +0.15
    const weight1 = parseFloat(camera1.Weight?.replace('g', '') || '0');
    const weight2 = parseFloat(camera2.Weight?.replace('g', '') || '0');
    if (Math.abs(weight1 - weight2) <= 200) {
      score += 0.15;
      reasons.push('重量相近');
    }

    // 发布年份相近 +0.1
    const year1 = parseInt(camera1.Year || '0');
    const year2 = parseInt(camera2.Year || '0');
    if (Math.abs(year1 - year2) <= 2) {
      score += 0.1;
      reasons.push('发布时间相近');
    }

    // 传感器类型相同 +0.25
    if (camera1.SensorType && camera2.SensorType && camera1.SensorType === camera2.SensorType) {
      score += 0.25;
      reasons.push('相同传感器类型');
    }

    const result: SimilarityResult = { score: Math.min(score, 1), reasons };
    return result;
  }
  

  // 计算升级潜力
  private calculateUpgradePotential(currentCamera: CameraDataItem, upgradeCamera: CameraDataItem): UpgradePotentialResult {
    let score = 0;
    const reasons: string[] = [];
    let upgradeType: 'entry_to_mid' | 'mid_to_pro' | 'brand_switch' | 'format_upgrade' = 'entry_to_mid';
    
    // 像素提升 +0.2
    const currentMP = parseFloat(currentCamera.Megapixels?.replace('MP', '') || '0');
    const upgradeMP = parseFloat(upgradeCamera.Megapixels?.replace('MP', '') || '0');
    if (upgradeMP > currentMP + 5) {
      score += 0.2;
      reasons.push('像素显著提升');
    }
    
    // 年份更新 +0.3
    const currentYear = parseInt(currentCamera.Year || '0');
    const upgradeYear = parseInt(upgradeCamera.Year || '0');
    if (upgradeYear > currentYear) {
      score += 0.3;
      reasons.push('更新的产品');
    }
    
    // 品牌升级路径
    if (currentCamera.Brand === upgradeCamera.Brand) {
      score += 0.2;
      reasons.push('品牌内升级');
      upgradeType = this.determineUpgradeType(currentCamera, upgradeCamera);
    } else {
      score += 0.1;
      reasons.push('跨品牌升级');
      upgradeType = 'brand_switch';
    }
    
    // 功能提升（基于型号名称判断）
    if (this.isProModel(upgradeCamera.Model) && !this.isProModel(currentCamera.Model)) {
      score += 0.3;
      reasons.push('专业级升级');
      upgradeType = 'mid_to_pro';
    }
    
    const result: UpgradePotentialResult = { score: Math.min(score, 1), reasons, type: upgradeType };
    return result;
  }
  
  // 判断升级类型
  private determineUpgradeType(current: CameraDataItem, upgrade: CameraDataItem): 'entry_to_mid' | 'mid_to_pro' | 'brand_switch' | 'format_upgrade' {
    if (this.isProModel(upgrade.Model) && !this.isProModel(current.Model)) {
      return 'mid_to_pro';
    }
    if (this.isFullFrame(upgrade) && !this.isFullFrame(current)) {
      return 'format_upgrade';
    }
    return 'entry_to_mid';
  }
  
  // 判断是否为专业型号
  private isProModel(model: string): boolean {
    const proKeywords = ['Pro', 'Mark', 'R5', 'R6', 'A7R', 'A7S', 'Z9', 'Z8', 'D850', 'D780'];
    return proKeywords.some(keyword => model.includes(keyword));
  }
  
  // 判断是否为全画幅
  private isFullFrame(camera: CameraDataItem): boolean {
    const sensorSize = camera.SensorSize || '';
    return sensorSize.includes('Full') || sensorSize.includes('35mm') || sensorSize.includes('36');
  }
  
  // 获取价格范围
  private getPriceRange(camera: CameraDataItem): string {
    // 基于品牌和型号估算价格范围
    const brand = camera.Brand.toLowerCase();
    const model = camera.Model.toLowerCase();
    
    if (model.includes('pro') || model.includes('mark') || model.includes('r5') || model.includes('a7r')) {
      return '¥15,000+';
    } else if (model.includes('r6') || model.includes('a7') || model.includes('z6') || model.includes('d780')) {
      return '¥8,000-15,000';
    } else {
      return '¥3,000-8,000';
    }
  }
  
  // 获取预定义标签
  getPredefinedTags(): string[] {
    return PREDEFINED_TAGS;
  }
  
  // 获取所有评分
  getAllRatings(): CameraRating[] {
    const allRatings: CameraRating[] = [];
    this.ratings.forEach((ratings) => {
      allRatings.push(...ratings);
    });
    return allRatings;
  }
  
  // 删除评分
  async deleteRating(brand: string, model: string): Promise<void> {
    const cameraId = this.generateCameraId(brand, model);
    this.ratings.delete(cameraId);
    await this.saveRatings();
    this.calculateStats();
  }
}

// 导出单例
export const cameraRatingService = new CameraRatingService();
export { CameraRatingService };