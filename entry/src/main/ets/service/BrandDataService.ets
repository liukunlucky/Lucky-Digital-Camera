import { Brand, BrandService } from '../model/Brand';
import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import util from '@ohos.util';

// 品牌数据服务实现类
export class BrandDataService implements BrandService {
  private brands: Brand[] = [];
  private isLoaded: boolean = false;

  // 加载品牌数据
  private async loadBrands(): Promise<void> {
    if (this.isLoaded) {
      return;
    }

    try {
      const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
      const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
      const rawFileData: Uint8Array = await resourceMgr.getRawFileContent('camera_brand.json');
      let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
      let decodedData = textDecoder.decodeToString(rawFileData, { stream: false})
      this.brands = JSON.parse(decodedData) as Brand[];
      this.isLoaded = true;
    } catch (error) {
      console.error('加载品牌数据失败:', error.message);
      this.brands = [];
    }
  }

  async getAllBrands(): Promise<Brand[]> {
    await this.loadBrands();
    return this.brands;
  }

  async getBrandByNameEn(nameEn: string): Promise<Brand | undefined> {
    await this.loadBrands();
    return this.brands.find(brand => brand.name_en === nameEn);
  }

  async getBrandByNameZh(nameZh: string): Promise<Brand | undefined> {
    await this.loadBrands();
    return this.brands.find(brand => brand.name_zh === nameZh);
  }

  // 获取品牌名称列表（中文）
  async getBrandNamesZh(): Promise<string[]> {
    await this.loadBrands();
    return this.brands.map(brand => brand.name_zh);
  }

  // 获取品牌名称列表（英文）
  async getBrandNamesEn(): Promise<string[]> {
    await this.loadBrands();
    return this.brands.map(brand => brand.name_en);
  }
}

// 单例模式
export const brandDataService = new BrandDataService();