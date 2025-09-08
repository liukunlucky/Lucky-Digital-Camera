import { CameraModel, CameraModelService, CameraType, SensorFormat, CameraStatus } from '../model/CameraModel';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';

/**
 * 相机型号数据服务实现类
 */
class CameraModelDataService implements CameraModelService {
  private cameraModels: CameraModel[] = [];
  private isLoaded: boolean = false;

  /**
   * 加载相机型号数据
   */
  private async loadCameraModels(): Promise<void> {
    if (this.isLoaded) {
      return;
    }

    try {
      const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
      const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
      const rawFileData: Uint8Array = await resourceMgr.getRawFileContent('camera_models.json');
      const jsonString: string = new TextDecoder().decode(rawFileData);
      this.cameraModels = JSON.parse(jsonString) as CameraModel[];
      this.isLoaded = true;
      console.info('相机型号数据加载成功，共加载', this.cameraModels.length, '个型号');
    } catch (error: Error) {
      console.error('加载相机型号数据失败:', error.message);
      // 如果加载失败，使用示例数据
      this.cameraModels = this.getExampleData();
      this.isLoaded = true;
    }
  }

  /**
   * 按品牌获取相机型号（英文品牌名）
   */
  async getModelsByBrandEn(brandNameEn: string): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => model.brand_name_en === brandNameEn);
  }

  /**
   * 获取示例数据（用于开发和测试）
   */
  private getExampleData(): CameraModel[] {
    return [
      {
        id: 'canon-eos-r5',
        model_name: 'EOS R5',
        full_name: 'Canon EOS R5',
        brand_name_en: 'Canon',
        brand_name_zh: '佳能',
        release_date: '2020-07-09',
        announcement_date: '2020-07-09',
        availability_date: '2020-07-30',
        camera_type: CameraType.MIRRORLESS,
        sensor_format: SensorFormat.FULL_FRAME,
        status: CameraStatus.IN_PRODUCTION,
        cover_image: 'https://cdn.dxomark.com/wp-content/uploads/medias/post-61815/Canon-EOS-R5_featured-image-packshot-review.jpg',
        gallery_images: [
          'https://cdn.dxomark.com/wp-content/uploads/medias/post-61815/Canon-EOS-R5_featured-image-packshot-review.jpg'
        ],
        price_info: {
          launch_price_usd: 3899,
          launch_price_cny: 25999,
          current_price_usd: 3299,
          current_price_cny: 22999,
          price_history: []
        },
        specs: {
          sensor_resolution: '45MP',
          sensor_size: '36 x 24mm',
          sensor_type: 'CMOS',
          iso_range: '100-51200',
          iso_extended: '50-102400',
          shutter_speed: '1/8000 - 30s',
          continuous_shooting: '12fps (机械快门), 20fps (电子快门)',
          autofocus_points: '5940个检测点',
          autofocus_type: '全像素双核CMOS AF',
          metering_modes: '384区测光',
          video_resolution: '8K RAW 30p, 4K 120p',
          video_codec: 'H.264/H.265',
          lcd_size: '3.2英寸',
          lcd_resolution: '2,100,000点',
          lcd_type: '翻转触摸屏',
          viewfinder_type: '0.5英寸OLED电子取景器',
          viewfinder_coverage: '100%',
          viewfinder_magnification: '0.76x',
          storage_slots: '双卡槽',
          storage_types: 'CFexpress Type B + SD UHS-II',
          connectivity: 'Wi-Fi 5GHz/2.4GHz, 蓝牙4.2, USB-C 3.2',
          battery_life: '320张 (取景器), 490张 (LCD)',
          battery_type: 'LP-E6NH',
          dimensions: '138.5 x 97.5 x 88.0mm',
          weight: '650g (仅机身)',
          weather_sealing: true,
          image_stabilization: '5轴机身防抖 (最高8档)',
          flash_sync_speed: '1/200s',
          special_features: ['像素偏移多重拍摄', '对焦包围', '深度合成', '4K延时摄影']
        },
        description: 'Canon EOS R5是一款专业级全画幅无反相机，具备4500万像素传感器和8K视频录制能力。',
        key_features: ['4500万像素全画幅传感器', '8K 30p RAW视频', '5轴机身防抖', '双卡槽设计'],
        target_audience: ['专业摄影师', '视频创作者', '商业摄影'],
        competitors: ['sony-a7r-iv', 'nikon-z7-ii'],
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
        data_source: 'official',
        data_quality: 9
      },
      {
        id: 'sony-a7r-v',
        model_name: 'α7R V',
        full_name: 'Sony α7R V',
        brand_name_en: 'Sony',
        brand_name_zh: '索尼',
        release_date: '2022-10-26',
        announcement_date: '2022-10-26',
        availability_date: '2022-12-01',
        camera_type: CameraType.MIRRORLESS,
        sensor_format: SensorFormat.FULL_FRAME,
        status: CameraStatus.IN_PRODUCTION,
        cover_image: 'https://www.sony.com/image/5d02da5df552836db894c4bda2d9e6f0?fmt=pjpeg&wid=330&bgcolor=FFFFFF&bgc=FFFFFF',
        gallery_images: [
          'https://www.sony.com/image/5d02da5df552836db894c4bda2d9e6f0?fmt=pjpeg&wid=330&bgcolor=FFFFFF&bgc=FFFFFF'
        ],
        price_info: {
          launch_price_usd: 3898,
          launch_price_cny: 28999,
          current_price_usd: 3498,
          current_price_cny: 26999,
          price_history: []
        },
        specs: {
          sensor_resolution: '61MP',
          sensor_size: '35.7 x 23.8mm',
          sensor_type: 'Exmor R CMOS',
          iso_range: '100-32000',
          iso_extended: '50-102400',
          shutter_speed: '1/8000 - 30s',
          continuous_shooting: '10fps',
          autofocus_points: '693个相位检测点',
          autofocus_type: '快速混合自动对焦',
          metering_modes: '1200区测光',
          video_resolution: '8K 24p, 4K 60p',
          video_codec: 'XAVC S/XAVC HS',
          lcd_size: '3.2英寸',
          lcd_resolution: '2,095,104点',
          lcd_type: '4轴翻转触摸屏',
          viewfinder_type: '0.64英寸OLED',
          viewfinder_coverage: '100%',
          viewfinder_magnification: '0.9x',
          storage_slots: '双卡槽',
          storage_types: 'CFexpress Type A + SD UHS-II',
          connectivity: 'Wi-Fi 6, 蓝牙5.0, USB-C 3.2',
          battery_life: '530张 (取景器), 670张 (LCD)',
          battery_type: 'NP-FZ100',
          dimensions: '131.3 x 96.9 x 82.4mm',
          weight: '723g (含电池和存储卡)',
          weather_sealing: true,
          image_stabilization: '5轴机身防抖 (最高8档)',
          flash_sync_speed: '1/250s',
          special_features: ['像素偏移多重拍摄', 'AI智能对焦', '呼吸补偿', '对焦地图']
        },
        description: 'Sony α7R V是一款高分辨率全画幅无反相机，搭载6100万像素传感器和先进的AI对焦系统。',
        key_features: ['6100万像素传感器', 'AI智能对焦', '8K视频录制', '像素偏移多重拍摄'],
        target_audience: ['风光摄影师', '商业摄影师', '艺术创作者'],
        competitors: ['canon-eos-r5', 'nikon-z7-ii'],
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
        data_source: 'official',
        data_quality: 9
      }
    ];
  }

  /**
   * 获取所有相机型号
   */
  async getAllModels(): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return [...this.cameraModels];
  }

  /**
   * 按品牌获取相机型号（中文品牌名）
   */
  async getModelsByBrand(brandNameZh: string): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => model.brand_name_zh === brandNameZh);
  }

  /**
   * 按类型获取相机型号
   */
  async getModelsByType(cameraType: CameraType): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => model.camera_type === cameraType);
  }

  /**
   * 按画幅获取相机型号
   */
  async getModelsByFormat(sensorFormat: SensorFormat): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => model.sensor_format === sensorFormat);
  }

  /**
   * 按状态获取相机型号
   */
  async getModelsByStatus(status: CameraStatus): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => model.status === status);
  }

  /**
   * 按价格范围获取相机型号
   */
  async getModelsByPriceRange(minPrice: number, maxPrice: number): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => {
      const currentPrice = model.price_info.current_price_cny || model.price_info.launch_price_cny;
      return currentPrice >= minPrice && currentPrice <= maxPrice;
    });
  }

  /**
   * 按发布年份获取相机型号
   */
  async getModelsByYear(year: number): Promise<CameraModel[]> {
    await this.loadCameraModels();
    return this.cameraModels.filter(model => {
      const releaseYear = new Date(model.release_date).getFullYear();
      return releaseYear === year;
    });
  }

  /**
   * 获取单个相机型号详情
   */
  async getModelById(id: string): Promise<CameraModel | null> {
    await this.loadCameraModels();
    return this.cameraModels.find(model => model.id === id) || null;
  }

  /**
   * 搜索相机型号
   */
  async searchModels(keyword: string): Promise<CameraModel[]> {
    await this.loadCameraModels();
    const lowerKeyword = keyword.toLowerCase();
    return this.cameraModels.filter(model => 
      model.model_name.toLowerCase().includes(lowerKeyword) ||
      model.full_name.toLowerCase().includes(lowerKeyword) ||
      model.brand_name_en.toLowerCase().includes(lowerKeyword) ||
      model.brand_name_zh.includes(keyword) ||
      model.description.toLowerCase().includes(lowerKeyword)
    );
  }

  /**
   * 获取热门相机型号
   */
  async getPopularModels(limit: number = 10): Promise<CameraModel[]> {
    await this.loadCameraModels();
    // 简单的热门度算法：按数据质量和发布日期排序
    const sortedModels = this.cameraModels
      .filter(model => model.status === CameraStatus.IN_PRODUCTION)
      .sort((a, b) => {
        const scoreA = a.data_quality * 10 + (new Date(a.release_date).getTime() / 1000000000);
        const scoreB = b.data_quality * 10 + (new Date(b.release_date).getTime() / 1000000000);
        return scoreB - scoreA;
      });
    return sortedModels.slice(0, limit);
  }

  /**
   * 获取最新相机型号
   */
  async getLatestModels(limit: number = 10): Promise<CameraModel[]> {
    await this.loadCameraModels();
    const sortedModels = this.cameraModels
      .sort((a, b) => new Date(b.release_date).getTime() - new Date(a.release_date).getTime());
    return sortedModels.slice(0, limit);
  }
}

// 导出单例实例
export const cameraModelDataService = new CameraModelDataService();