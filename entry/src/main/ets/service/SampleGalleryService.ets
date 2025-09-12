// 样张库服务类

import {
  SamplePhoto,
  SampleFilter,
  SampleStats,
  CameraSampleStats,
  UploadSampleRequest,
  SamplePhotoDetail,
  PhotoCategory,
  SortType,
  PhotoComment,
  HotLabel
} from '../model/SampleGalleryModel';
import { DatabaseService } from './DatabaseService';

// 样张库服务类
export class SampleGalleryService {
  private static instance: SampleGalleryService;
  private dbService: DatabaseService;
  private samplePhotos: SamplePhoto[] = [];
  private isInitialized: boolean = false;

  private constructor() {
    this.dbService = DatabaseService.getInstance();
    this.initializeSampleData();
  }

  public static getInstance(): SampleGalleryService {
    if (!SampleGalleryService.instance) {
      SampleGalleryService.instance = new SampleGalleryService();
    }
    return SampleGalleryService.instance;
  }

  // 初始化样张数据
  private async initializeSampleData(): Promise<void> {
    if (this.isInitialized) return;

    try {
      // 从数据库加载样张数据
      this.samplePhotos = await this.loadSamplePhotosFromDB();
      
      // 如果没有数据，创建示例数据
      if (this.samplePhotos.length === 0) {
        this.samplePhotos = this.createSampleData();
        await this.saveSamplePhotosToDB();
      }
      
      this.isInitialized = true;
    } catch (error) {
      console.error('初始化样张数据失败:', error);
      // 使用默认数据
      this.samplePhotos = this.createSampleData();
      this.isInitialized = true;
    }
  }

  // 创建示例样张数据
  private createSampleData(): SamplePhoto[] {
    return [];
  }

  // 获取样张列表
  public async getSamplePhotos(filter?: SampleFilter): Promise<SamplePhoto[]> {
    await this.initializeSampleData();
    
    let filteredPhotos = [...this.samplePhotos];
    
    if (filter) {

      if (filter.brand) {
        filteredPhotos = filteredPhotos.filter(photo => photo.cameraDataItem?.Brand === filter.brand);
      }

      if (filter.category) {
        filteredPhotos = filteredPhotos.filter(photo => photo.category === filter.category);
      }
      
      if (filter.tags && filter.tags.length > 0) {
        filteredPhotos = filteredPhotos.filter(photo => 
          filter.tags!.some(tag => photo.tags.includes(tag))
        );
      }
      
      if (filter.photographer) {
        filteredPhotos = filteredPhotos.filter(photo => 
          photo.photographer?.includes(filter.photographer!) || false
        );
      }
      
      if (filter.isPublic !== undefined) {
        filteredPhotos = filteredPhotos.filter(photo => photo.isPublic === filter.isPublic);
      }
      
      // 应用排序
      if (filter.sortBy) {
        filteredPhotos = this.sortPhotos(filteredPhotos, filter.sortBy);
      }
    }
    
    return filteredPhotos;
  }

  // 排序照片
  private sortPhotos(photos: SamplePhoto[], sortType: SortType): SamplePhoto[] {
    return photos.sort((a, b) => {
      switch (sortType) {
        case SortType.UPLOAD_TIME_DESC:
          return new Date(b.uploadTime).getTime() - new Date(a.uploadTime).getTime();
        case SortType.UPLOAD_TIME_ASC:
          return new Date(a.uploadTime).getTime() - new Date(b.uploadTime).getTime();
        case SortType.LIKES_DESC:
          return b.likes - a.likes;
        case SortType.VIEWS_DESC:
          return b.views - a.views;
        case SortType.TITLE_ASC:
          return a.title.localeCompare(b.title);
        default:
          return 0;
      }
    });
  }

  // 获取样张详情
  public async getSamplePhotoDetail(photoId: string): Promise<SamplePhotoDetail | null> {
    await this.initializeSampleData();
    
    const photo = this.samplePhotos.find(p => p.id === photoId);
    if (!photo) return null;
    
    // 获取相关样张（同相机或同分类）
    const relatedPhotos = this.samplePhotos
      .filter(p => p.id !== photoId && (p.cameraDataItem?.Brand === photo.cameraDataItem?.Brand || p.category === photo.category))
      .slice(0, 6);
    
    // 模拟评论数据
    const comments: PhotoComment[] = [
      {
        id: 'comment_001',
        photoId: photoId,
        userId: 'user_101',
        userName: '摄影爱好者',
        content: '拍得真不错，构图很棒！',
        createTime: '2024-01-16T10:30:00Z',
        likes: 5,
        replies: []
      }
    ];
    
    const photoDetail: SamplePhotoDetail = {
      id: photo.id,
      title: photo.title,
      description: photo.description,
      imageUri: photo.imageUri,
      thumbnailUri: photo.thumbnailUri,
      cameraId: photo.cameraId,
      cameraBrand: photo.cameraBrand,
      cameraModel: photo.cameraModel,
      cameraDataItem: photo.cameraDataItem,
      shootingParams: photo.shootingParams,
      tags: photo.tags,
      category: photo.category,
      uploadTime: photo.uploadTime,
      photographer: photo.photographer,
      location: photo.location,
      likes: photo.likes,
      views: photo.views,
      isPublic: photo.isPublic,
      userId: photo.userId,
      relatedPhotos,
      comments
    };
    return photoDetail;
  }

  // 获取相机样张统计
  public async getCameraSampleStats(cameraId: string): Promise<CameraSampleStats | null> {
    await this.initializeSampleData();
    
    const cameraPhotos = this.samplePhotos.filter(photo => photo.cameraId === cameraId);
    if (cameraPhotos.length === 0) return null;
    
    const totalLikes = cameraPhotos.reduce((sum, photo) => sum + photo.likes, 0);
    const totalViews = cameraPhotos.reduce((sum, photo) => sum + photo.views, 0);
    
    // 统计分类
    const categoryCounts = new Map<PhotoCategory, number>();
    cameraPhotos.forEach(photo => {
      categoryCounts.set(photo.category, (categoryCounts.get(photo.category) || 0) + 1);
    });
    
    // 获取热门分类（按数量排序）
    const popularCategories = Array.from(categoryCounts.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(entry => entry[0]);
    
    const stats: CameraSampleStats = {
      cameraId,
      cameraBrand: cameraPhotos[0].cameraBrand,
      cameraModel: cameraPhotos[0].cameraModel,
      photoCount: cameraPhotos.length,
      avgLikes: totalLikes / cameraPhotos.length,
      avgViews: totalViews / cameraPhotos.length,
      popularCategories,
      samplePhotos: cameraPhotos.slice(0, 6) // 代表性样张
    };
    
    return stats;
  }

  // 获取样张统计信息
  public async getSampleStats(): Promise<SampleStats> {
    await this.initializeSampleData();
    
    const totalPhotos = this.samplePhotos.length;
    const totalViews = this.samplePhotos.reduce((sum, photo) => sum + photo.views, 0);
    const totalLikes = this.samplePhotos.reduce((sum, photo) => sum + photo.likes, 0);
    
    // 统计分类
    const categoryCounts = new Map<PhotoCategory, number>();
    this.samplePhotos.forEach(photo => {
      categoryCounts.set(photo.category, (categoryCounts.get(photo.category) || 0) + 1);
    });
    
    // 统计品牌
    const brandCounts = new Map<string, number>();
    this.samplePhotos.forEach(photo => {
      brandCounts.set(photo.cameraBrand, (brandCounts.get(photo.cameraBrand) || 0) + 1);
    });
    
    // 统计热门标签
    const tagCounts = new Map<string, number>();
    this.samplePhotos.forEach(photo => {
      photo.tags.forEach(tag => {
        tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
      });
    });
    
    const popularTags: Array<HotLabel> = Array.from(tagCounts.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(entry => {
        const hotLabel: HotLabel = { tag: entry[0], count: entry[1] };
        return hotLabel;
      });
    
    const stats: SampleStats = {
      totalPhotos,
      totalViews,
      totalLikes,
      categoryCounts,
      brandCounts,
      popularTags
    };
    return stats;
  }

  // 上传样张
  public async uploadSamplePhoto(request: UploadSampleRequest, imageUri: string): Promise<string> {
    const newPhoto: SamplePhoto = {
      id: `sample_${Date.now()}`,
      title: request.title,
      description: request.description,
      imageUri: imageUri,
      cameraId: request.cameraId,
      cameraBrand: '', // 需要从相机数据中获取
      cameraModel: '', // 需要从相机数据中获取
      cameraDataItem: request.cameraDataItem,
      shootingParams: request.shootingParams,
      tags: request.tags,
      category: request.category,
      uploadTime: new Date().toISOString(),
      photographer: request.photographer,
      location: request.location,
      likes: 0,
      views: 0,
      isPublic: request.isPublic,
      userId: 'current_user' // 实际应用中应该从用户会话获取
    };
    
    this.samplePhotos.unshift(newPhoto);
    await this.saveSamplePhotosToDB();
    
    return newPhoto.id;
  }

  // 点赞样张
  public async likeSamplePhoto(photoId: string): Promise<boolean> {
    const photo = this.samplePhotos.find(p => p.id === photoId);
    if (photo) {
      photo.likes++;
      await this.saveSamplePhotosToDB();
      return true;
    }
    return false;
  }

  // 增加查看数
  public async incrementViews(photoId: string): Promise<void> {
    const photo = this.samplePhotos.find(p => p.id === photoId);
    if (photo) {
      photo.views++;
      await this.saveSamplePhotosToDB();
    }
  }

  // 删除样张
  public async deleteSamplePhoto(photoId: string): Promise<boolean> {
    const index = this.samplePhotos.findIndex(p => p.id === photoId);
    if (index !== -1) {
      this.samplePhotos.splice(index, 1);
      await this.saveSamplePhotosToDB();
      return true;
    }
    return false;
  }

  // 从数据库加载样张数据
  private async loadSamplePhotosFromDB(): Promise<SamplePhoto[]> {
    try {
      const data = await this.dbService.getData('sample_photos');
      return data ? JSON.parse(data) as SamplePhoto[] : [];
    } catch (error) {
      console.error('加载样张数据失败:', error);
      return [];
    }
  }

  // 保存样张数据到数据库
  private async saveSamplePhotosToDB(): Promise<void> {
    try {
      await this.dbService.saveData('sample_photos', JSON.stringify(this.samplePhotos));
    } catch (error) {
      console.error('保存样张数据失败:', error);
    }
  }

  // 搜索样张
  public async searchSamplePhotos(keyword: string): Promise<SamplePhoto[]> {
    await this.initializeSampleData();
    
    const lowerKeyword = keyword.toLowerCase();
    return this.samplePhotos.filter(photo => 
      photo.title.toLowerCase().includes(lowerKeyword) ||
      photo.description?.toLowerCase().includes(lowerKeyword) ||
      photo.tags.some(tag => tag.toLowerCase().includes(lowerKeyword)) ||
      photo.cameraBrand.toLowerCase().includes(lowerKeyword) ||
      photo.cameraModel.toLowerCase().includes(lowerKeyword) ||
      photo.photographer?.toLowerCase().includes(lowerKeyword)
    );
  }

  // 获取热门样张
  public async getPopularSamplePhotos(limit: number = 10): Promise<SamplePhoto[]> {
    await this.initializeSampleData();
    
    return this.samplePhotos
      .sort((a, b) => (b.likes + b.views * 0.1) - (a.likes + a.views * 0.1))
      .slice(0, limit);
  }

  // 获取最新样张
  public async getLatestSamplePhotos(limit: number = 10): Promise<SamplePhoto[]> {
    await this.initializeSampleData();
    
    return this.samplePhotos
      .sort((a, b) => new Date(b.uploadTime).getTime() - new Date(a.uploadTime).getTime())
      .slice(0, limit);
  }
}