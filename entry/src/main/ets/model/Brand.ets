// 品牌数据模型
export interface Brand {
  name_en: string;        // 英文名称
  name_zh: string;        // 中文名称
  website: string;        // 官网地址
  logo_url: string;       // Logo URL
  country_region: string; // 国家/地区
  founded_year: number;   // 成立年份
  parent_company: string; // 母公司
}

// 品牌服务接口
export interface BrandService {
  getAllBrands(): Promise<Brand[]>;
  getBrandByNameEn(nameEn: string): Promise<Brand | undefined>;
  getBrandByNameZh(nameZh: string): Promise<Brand | undefined>;
}