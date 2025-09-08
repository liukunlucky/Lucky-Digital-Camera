# 相机品牌和型号映射功能实现说明

## 功能概述

已成功在首页建立了基于 `camera_data.json` 的相机品牌和型号联系，实现了切换品牌查询不同品牌相机型号的功能。

## 实现的功能

### 1. 数据服务层 (CameraDataJsonService)
- 📁 文件位置: `entry/src/main/ets/service/CameraDataJsonService.ets`
- 🔧 功能:
  - 加载和解析 `camera_data.json` 文件
  - 构建品牌到相机型号的映射关系
  - 提供按品牌筛选相机型号的接口
  - 支持搜索功能（按品牌名或型号名）
  - 处理相机图片路径转换

### 2. 首页集成 (HomePage)
- 📁 文件位置: `entry/src/main/ets/pages/HomePage.ets`
- 🔧 功能:
  - 集成新的 `CameraDataJsonService`
  - 显示基于 `camera_data.json` 的真实相机数据
  - 支持品牌切换功能
  - 支持搜索筛选功能
  - 新增 `CameraDataCard` 组件显示相机信息

### 3. 测试页面 (TestCameraData)
- 📁 文件位置: `entry/src/main/ets/pages/TestCameraData.ets`
- 🔧 功能:
  - 独立测试品牌和型号映射功能
  - 显示所有品牌列表
  - 点击品牌查看对应的相机型号
  - 验证数据加载和映射逻辑

## 数据结构

### camera_data.json 数据格式
```json
{
  "Brand": "Canon",
  "Model": "EOS R5",
  "Year": "2020",
  "image_file": "data/images/canon_eos_r5.jpg",
  "Megapixels": "45.0",
  "Sensor type": "CMOS",
  ...
}
```

### 支持的品牌
从 `camera_data.json` 中提取的品牌包括：
- Acer, AgfaPhoto, BenQ, Canon, Casio
- Fujifilm, Kodak, Leica, Nikon, Olympus
- Panasonic, Pentax, Samsung, Sony
- 等多个知名相机品牌

## 图片资源

- 📁 图片存储路径: `/Users/monkey/Documents/Harmony/Lucky_Digital_Camera/entry/src/main/resources/rawfile/images`
- 🖼️ 图片引用方式: `$rawfile('images/相机图片文件名')`
- 🔄 路径转换: 自动将 `data/images/xxx.jpg` 转换为 `images/xxx.jpg`

## 核心功能实现

### 品牌切换
```typescript
async onBrandChange(brand: string) {
  this.selectedBrand = brand;
  await this.updateFilteredCameras();
}
```

### 型号筛选
```typescript
async updateFilteredCameras() {
  this.filteredCameraDataItems = await cameraDataJsonService.getCamerasByBrandAndSearch(
    this.selectedBrand,
    this.searchText
  );
}
```

### 搜索功能
```typescript
async onSearchTextChange(text: string) {
  this.searchText = text;
  await this.updateFilteredCameras();
}
```

## 技术特点

1. **异步数据加载**: 使用 `resourceManager.getRawFileContent` 异步加载 JSON 数据
2. **内存优化**: 构建品牌映射表，避免重复遍历
3. **错误处理**: 完善的异常捕获和日志记录
4. **类型安全**: 使用 TypeScript 接口定义数据结构
5. **单例模式**: 数据服务采用单例模式，避免重复加载

## 使用方式

1. **首页使用**: 直接在首页选择品牌，查看对应的相机型号
2. **搜索功能**: 在搜索框输入品牌名或型号名进行筛选
3. **测试页面**: 访问 `TestCameraData` 页面独立测试功能

## 编译和运行

```bash
# 编译项目
hvigorw assembleHap

# 构建并运行
hvigorw --mode module -p product=default -p buildMode=debug assembleHap
```

## 状态

✅ **已完成**: 品牌和型号映射功能已成功实现并通过编译测试
✅ **数据加载**: 成功加载 `camera_data.json` 中的所有相机数据
✅ **UI集成**: 首页已集成新的数据显示和筛选功能
✅ **测试验证**: 创建了独立的测试页面验证功能正确性