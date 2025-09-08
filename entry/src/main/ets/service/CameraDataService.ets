import { Camera, CameraSpecs, CameraCategory, CameraBrand, CameraService, SensorFormat } from '../model/Camera';
import { brandDataService } from './BrandDataService';

// 相机数据服务实现类
export class CameraDataService implements CameraService {
  private cameras: Camera[] = [
    {
      id: 1,
      brand: CameraBrand.CANON,
      model: 'EOS R5',
      releaseDate: '2020-07-09',
      releasePrice: 3899,
      imageUrl: 'https://example.com/canon-r5.jpg',
      description: 'Canon EOS R5是一款全画幅无反相机，具有4500万像素和8K视频录制能力。',
      specifications: {
        sensorType: 'CMOS全画幅',
        megapixels: 45,
        isoRange: '100-51200',
        shutterSpeed: '1/8000 - 30s',
        lensMount: 'RF卡口',
        videoCapability: '8K 30fps, 4K 120fps',
        weight: 738,
        dimensions: '138.5 x 97.5 x 88.0'
      },
      category: CameraCategory.MIRRORLESS,
      sensorFormat: SensorFormat.FULL_FRAME
    },
    {
      id: 2,
      brand: CameraBrand.NIKON,
      model: 'D850',
      releaseDate: '2017-08-24',
      releasePrice: 3297,
      imageUrl: 'https://example.com/nikon-d850.jpg',
      description: 'Nikon D850是一款专业级全画幅单反相机，拥有4575万像素和出色的动态范围。',
      specifications: {
        sensorType: 'CMOS全画幅',
        megapixels: 45.7,
        isoRange: '64-25600',
        shutterSpeed: '1/8000 - 30s',
        lensMount: 'F卡口',
        videoCapability: '4K 30fps',
        weight: 1005,
        dimensions: '146 x 124 x 78.5'
      },
      category: CameraCategory.DSLR,
      sensorFormat: SensorFormat.FULL_FRAME
    },
    {
      id: 3,
      brand: CameraBrand.SONY,
      model: 'α7R IV',
      releaseDate: '2019-07-16',
      releasePrice: 3498,
      imageUrl: 'https://example.com/sony-a7r4.jpg',
      description: 'Sony α7R IV是一款高分辨率全画幅无反相机，拥有6100万像素。',
      specifications: {
        sensorType: 'CMOS全画幅',
        megapixels: 61,
        isoRange: '100-32000',
        shutterSpeed: '1/8000 - 30s',
        lensMount: 'E卡口',
        videoCapability: '4K 30fps',
        weight: 665,
        dimensions: '128.9 x 96.4 x 77.5'
      },
      category: CameraCategory.MIRRORLESS,
      sensorFormat: SensorFormat.FULL_FRAME
    },
    {
      id: 4,
      brand: CameraBrand.FUJIFILM,
      model: 'X-T4',
      releaseDate: '2020-02-26',
      releasePrice: 1699,
      imageUrl: 'https://example.com/fuji-xt4.jpg',
      description: 'Fujifilm X-T4是一款APS-C画幅无反相机，具有优秀的色彩表现和机身防抖。',
      specifications: {
        sensorType: 'CMOS APS-C',
        megapixels: 26.1,
        isoRange: '160-12800',
        shutterSpeed: '1/8000 - 15min',
        lensMount: 'X卡口',
        videoCapability: '4K 60fps',
        weight: 607,
        dimensions: '134.6 x 92.8 x 63.8'
      },
      category: CameraCategory.MIRRORLESS,
      sensorFormat: SensorFormat.APS_C
    },
    {
      id: 5,
      brand: CameraBrand.LEICA,
      model: 'M11',
      releaseDate: '2022-01-13',
      releasePrice: 8595,
      imageUrl: 'https://example.com/leica-m11.jpg',
      description: 'Leica M11是一款经典的旁轴相机，延续了M系列的传统设计和卓越品质。',
      specifications: {
        sensorType: 'CMOS全画幅',
        megapixels: 60,
        isoRange: '64-50000',
        shutterSpeed: '1/4000 - 60s',
        lensMount: 'M卡口',
        videoCapability: '不支持',
        weight: 640,
        dimensions: '139 x 80 x 38.5'
      },
      category: CameraCategory.COMPACT,
      sensorFormat: SensorFormat.FULL_FRAME
    },
    {
      id: 6,
      brand: CameraBrand.HASSELBLAD,
      model: 'X1D II 50C',
      releaseDate: '2019-07-11',
      releasePrice: 5750,
      imageUrl: 'https://example.com/hasselblad-x1d2.jpg',
      description: 'Hasselblad X1D II 50C是一款中画幅无反相机，提供卓越的图像质量。',
      specifications: {
        sensorType: 'CMOS中画幅',
        megapixels: 50,
        isoRange: '100-25600',
        shutterSpeed: '1/2000 - 60min',
        lensMount: 'XCD卡口',
        videoCapability: '2.7K 25fps',
        weight: 766,
        dimensions: '148 x 97 x 71'
      },
      category: CameraCategory.MEDIUM_FORMAT,
      sensorFormat: SensorFormat.MEDIUM_FORMAT
    }
  ];

  getAllCameras(): Camera[] {
    return this.cameras;
  }

  getCameraById(id: number): Camera | undefined {
    return this.cameras.find(camera => camera.id === id);
  }

  getCamerasByBrand(brand: string): Camera[] {
    return this.cameras.filter(camera => camera.brand === brand);
  }

  getCamerasByCategory(category: CameraCategory): Camera[] {
    return this.cameras.filter(camera => camera.category === category);
  }

  searchCameras(keyword: string): Camera[] {
    const lowerKeyword = keyword.toLowerCase();
    return this.cameras.filter(camera => 
      camera.brand.toLowerCase().includes(lowerKeyword) ||
      camera.model.toLowerCase().includes(lowerKeyword) ||
      camera.description.toLowerCase().includes(lowerKeyword)
    );
  }

  getAllBrands(): string[] {
    const brands = Array.from(new Set(this.cameras.map(camera => camera.brand)));
    return brands.sort();
  }

  // 获取真实品牌数据（中文名称）
  async getRealBrands(): Promise<string[]> {
    try {
      const brandNames = await brandDataService.getBrandNamesZh();
      return ['全部', ...brandNames];
    } catch (error) {
      console.error('获取品牌数据失败，使用默认数据:', error);
      return ['全部', ...this.getAllBrands()];
    }
  }

  getCamerasByBrandAndSearch(brand?: string, keyword?: string): Camera[] {
    let filteredCameras = this.cameras;
    
    // 按品牌筛选
    if (brand && brand !== '全部') {
      filteredCameras = filteredCameras.filter(camera => camera.brand === brand);
    }
    
    // 按关键词搜索
    if (keyword && keyword.trim() !== '') {
      const lowerKeyword = keyword.toLowerCase();
      filteredCameras = filteredCameras.filter(camera => 
        camera.brand.toLowerCase().includes(lowerKeyword) ||
        camera.model.toLowerCase().includes(lowerKeyword) ||
        camera.description.toLowerCase().includes(lowerKeyword)
      );
    }
    
    return filteredCameras;
  }
}

// 单例模式
export const cameraDataService = new CameraDataService();