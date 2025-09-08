import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import util from '@ohos.util';

// camera_data.json中的相机数据接口
export interface CameraDataItem {
  Brand: string;
  Model: string;
  Year: string;
  image_file: string;
  TotalMegapixels?: string | null;
  ExposureCompensation?: string | null;
  NormalFocusRange?: string | null;
  Battery?: string | null;
  SensorResolution?: string | null;
  CropFactor?: string | null;
  SensorType?: string | null;
  Dimensions?: string | null;
  MaxAperture?: string | null;
  MinShutterSpeed?: string | null;
  WhiteBalancePresets?: string | null;
  MacroFocusRange?: string | null;
  OpticalZoom?: string | null;
  USB?: string | null;
  Weight?: string | null;
  MaxAperture35mmEquiv?: string | null;
  FocalLength35mmEquiv?: string | null;
  AlsoKnownAs?: string | null;
  AperturePriority?: string | null;
  MaxImageResolution?: string | null;
  MaxShutterSpeed?: string | null;
  StorageTypes?: string | null;
  EffectiveMegapixels?: string | null;
  Megapixels?: string | null;
  MaxVideoResolution?: string | null;
  ScreenSize?: string | null;
  Metering?: string | null;
  DigitalZoom?: string | null;
  ShutterPriority?: string | null;
  SensorSize?: string | null;
  Viewfinder?: string | null;
  ScreenResolution?: string | null;
  ISO?: string | null;
}

// 品牌统计信息
export interface BrandInfo {
  brandName: string;
  modelCount: number;
  models: CameraDataItem[];
}

/**
 * camera_data.json数据服务
 */
export class CameraDataJsonService {
  private cameraData: CameraDataItem[] = [];
  private isLoaded: boolean = false;
  private brandMap: Map<string, CameraDataItem[]> = new Map();

  /**
   * 加载camera_data.json数据
   */
  private async loadCameraData(): Promise<void> {
    if (this.isLoaded) {
      return;
    }

    try {
      const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
      const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
      const rawFileData: Uint8Array = await resourceMgr.getRawFileContent('camera_data.json');
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const jsonString = textDecoder.decodeToString(rawFileData, { stream: false });
      this.cameraData = JSON.parse(jsonString) as CameraDataItem[];
      
      // 构建品牌映射
      this.buildBrandMap();
      this.isLoaded = true;
      
      console.info(`成功加载 ${this.cameraData.length} 条相机数据`);
    } catch (error) {
      console.error('加载camera_data.json失败:', error.message);
      this.cameraData = [];
    }
  }

  /**
   * 构建品牌到相机型号的映射
   */
  private buildBrandMap(): void {
    this.brandMap.clear();
    
    for (const camera of this.cameraData) {
      const brand = camera.Brand;
      if (!this.brandMap.has(brand)) {
        this.brandMap.set(brand, []);
      }
      this.brandMap.get(brand)!.push(camera);
    }
  }

  /**
   * 获取所有品牌名称
   */
  async getAllBrands(): Promise<string[]> {
    await this.loadCameraData();
    return Array.from(this.brandMap.keys()).sort();
  }

  /**
   * 获取品牌统计信息
   */
  async getBrandInfos(): Promise<BrandInfo[]> {
    await this.loadCameraData();
    
    const brandInfos: BrandInfo[] = [];
    this.brandMap.forEach((models: CameraDataItem[], brandName: string) => {
      brandInfos.push({
        brandName: brandName,
        modelCount: models.length,
        models: models
      });
    });
    
    return brandInfos.sort((a, b) => a.brandName.localeCompare(b.brandName));
  }

  /**
   * 根据品牌获取相机型号
   */
  async getModelsByBrand(brandName: string): Promise<CameraDataItem[]> {
    await this.loadCameraData();
    return this.brandMap.get(brandName) || [];
  }

  /**
   * 搜索相机（按品牌或型号）
   */
  async searchCameras(keyword: string): Promise<CameraDataItem[]> {
    await this.loadCameraData();
    
    if (!keyword || keyword.trim() === '') {
      return this.cameraData;
    }
    
    const lowerKeyword = keyword.toLowerCase();
    return this.cameraData.filter(camera => 
      camera.Brand.toLowerCase().includes(lowerKeyword) ||
      camera.Model.toLowerCase().includes(lowerKeyword)
    );
  }

  /**
   * 根据品牌和搜索关键词获取相机
   */
  async getCamerasByBrandAndSearch(brandName?: string, keyword?: string): Promise<CameraDataItem[]> {
    await this.loadCameraData();
    
    let filteredCameras = this.cameraData;
    
    // 按品牌筛选
    if (brandName && brandName !== '全部') {
      filteredCameras = this.brandMap.get(brandName) || [];
    }
    
    // 按关键词搜索
    if (keyword && keyword.trim() !== '') {
      const lowerKeyword = keyword.toLowerCase();
      filteredCameras = filteredCameras.filter(camera => 
        camera.Brand.toLowerCase().includes(lowerKeyword) ||
        camera.Model.toLowerCase().includes(lowerKeyword)
      );
    }
    
    return filteredCameras;
  }

  /**
   * 获取相机图片路径（转换为rawfile路径）
   */
  getCameraImagePath(camera: CameraDataItem): string {
    if (!camera.image_file) {
      return '';
    }
    
    // 将 "data/images/xxx.jpg" 转换为 "images/xxx.jpg"
    const imagePath = camera.image_file.replace('data/', '');
    return imagePath;
  }

  /**
   * 获取所有相机数据
   */
  async getAllCameras(): Promise<CameraDataItem[]> {
    await this.loadCameraData();
    return this.cameraData;
  }

  /**
   * 根据品牌和型号获取特定相机
   */
  async getCameraByBrandAndModel(brand: string, model: string): Promise<CameraDataItem | undefined> {
    await this.loadCameraData();
    return this.cameraData.find(camera => 
      camera.Brand === brand && camera.Model === model
    );
  }
}

// 单例模式
export const cameraDataJsonService = new CameraDataJsonService();