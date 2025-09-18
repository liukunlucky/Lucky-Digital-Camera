// 样张库页面

import {
  SamplePhoto,
  SampleFilter,
  PhotoCategory,
  SortType,
  CATEGORY_NAMES
} from '../model/SampleGalleryModel';
import { SampleGalleryService } from '../service/SampleGalleryService';
import router from '@ohos.router';

@Component
export struct SampleGalleryPage {
  @State samplePhotos: SamplePhoto[] = [];
  @State filteredPhotos: SamplePhoto[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  @State selectedCategory: PhotoCategory | undefined = undefined;
  @State selectedBrand: string = '';
  @State sortType: SortType = SortType.UPLOAD_TIME_DESC;
  @State showFilterPanel: boolean = false;
  @State gridColumns: number = 2;
  @StorageProp('refreshSampleGallery') @Watch('onRefreshSampleGallery') refreshSampleGallery: number = 0;
  
  private sampleService = SampleGalleryService.getInstance();
  private availableBrands: string[] = [];

  async aboutToAppear() {
    await this.loadSamplePhotos();
  }

  async onPageShow() {
    // 页面显示时重新加载数据，确保数据同步
    await this.loadSamplePhotos();
  }

  // 监听样张库数据刷新
  onRefreshSampleGallery() {
    this.loadSamplePhotos();
  }

  // 加载样张数据
  private async loadSamplePhotos() {
    try {
      this.isLoading = true;
      this.samplePhotos = await this.sampleService.getSamplePhotos();
      this.filteredPhotos = [...this.samplePhotos];
      
      // 提取可用品牌
      this.availableBrands = Array.from(new Set(this.samplePhotos.map(photo => photo.cameraBrand)));
      
      this.isLoading = false;
    } catch (error) {
      console.error('加载样张失败:', error);
      this.isLoading = false;
    }
  }

  // 应用筛选
  private async applyFilter() {
    const filter: SampleFilter = {
      category: this.selectedCategory,
      brand: this.selectedBrand || undefined,
      sortBy: this.sortType
    };
    
    try {
      let photos = await this.sampleService.getSamplePhotos(filter);
      
      // 应用搜索关键词
      if (this.searchKeyword.trim()) {
        const searchResults = await this.sampleService.searchSamplePhotos(this.searchKeyword.trim());
        photos = photos.filter(photo => searchResults.some(result => result.id === photo.id));
      }
      
      this.filteredPhotos = photos;
    } catch (error) {
      console.error('筛选样张失败:', error);
    }
  }

  // 清除筛选
  private clearFilter() {
    this.selectedCategory = undefined;
    this.selectedBrand = '';
    this.searchKeyword = '';
    this.sortType = SortType.UPLOAD_TIME_DESC;
    this.filteredPhotos = [...this.samplePhotos];
  }

  // 查看样张详情
  private viewPhotoDetail(photo: SamplePhoto) {
    router.pushUrl({
      url: 'pages/SamplePhotoDetailPage',
      params: {
        photoId: photo.id
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar()
      
      // 搜索和筛选栏
      this.buildSearchAndFilterBar()
      
      // // 筛选面板
      // if (this.showFilterPanel) {
      //   this.buildFilterPanel()
      // }
      
      // 样张网格
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.filteredPhotos.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildPhotoGrid()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  // 顶部导航栏
  @Builder
  buildTopBar() {
    Row() {
      Blank().width(40)
      Text('样张库')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))

      Button() {
        Image($r('app.media.icon_add2'))
          .width(20)
          .height(20)
          .fillColor(Color.White)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor($r('app.color.brand_color'))
      .onClick(() => {
        router.pushUrl({ url: 'pages/UploadSamplePage' });
      })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.start_window_background'))
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }

  // 搜索和筛选栏
  @Builder
  buildSearchAndFilterBar() {
    Row() {
      TextInput({ placeholder: '搜索样张...', text: this.searchKeyword })
        .layoutWeight(1)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('app.color.divider_color'))
        .fontColor($r('app.color.primary_text_color'))
        .placeholderColor($r('app.color.placeholder_text_color'))
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.applyFilter();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.surface_color'))
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }

  // 筛选面板
  @Builder
  buildFilterPanel() {
    Column() {
      // 分类筛选
      Column() {
        Text('分类')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          // 全部分类
          Button('全部')
            .fontSize(12)
            .fontColor(this.selectedCategory === undefined ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
            .backgroundColor(this.selectedCategory === undefined ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
            .border({ width: 1, color: this.selectedCategory === undefined ? $r('app.color.brand_color') : $r('app.color.border_color') })
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedCategory = undefined;
              this.applyFilter();
            })
          
          // 各分类按钮
          ForEach(Object.values(PhotoCategory), (category: PhotoCategory) => {
            Button(CATEGORY_NAMES[category])
              .fontSize(12)
              .fontColor(this.selectedCategory === category ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
              .backgroundColor(this.selectedCategory === category ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
              .border({ width: 1, color: this.selectedCategory === category ? $r('app.color.brand_color') : $r('app.color.border_color') })
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.selectedCategory = this.selectedCategory === category ? undefined : category;
                this.applyFilter();
              })
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      
      // 品牌筛选
      Column() {
        Text('品牌')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          // 全部品牌
          Button('全部')
            .fontSize(12)
            .fontColor(this.selectedBrand === '' ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
            .backgroundColor(this.selectedBrand === '' ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
            .border({ width: 1, color: this.selectedBrand === '' ? $r('app.color.brand_color') : $r('app.color.border_color') })
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedBrand = '';
              this.applyFilter();
            })
          
          // 各品牌按钮
          ForEach(this.availableBrands, (brand: string) => {
            Button(brand)
              .fontSize(12)
              .fontColor(this.selectedBrand === brand ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
              .backgroundColor(this.selectedBrand === brand ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
              .border({ width: 1, color: this.selectedBrand === brand ? $r('app.color.brand_color') : $r('app.color.border_color') })
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.selectedBrand = this.selectedBrand === brand ? '' : brand;
                this.applyFilter();
              })
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      
      // 排序选择
      Column() {
        Text('排序')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })
        
        Row() {
          Button('最新上传')
            .fontSize(12)
            .fontColor(this.sortType === SortType.UPLOAD_TIME_DESC ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
            .backgroundColor(this.sortType === SortType.UPLOAD_TIME_DESC ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
            .border({ width: 1, color: this.sortType === SortType.UPLOAD_TIME_DESC ? $r('app.color.brand_color') : $r('app.color.border_color') })
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })
            .onClick(() => {
              this.sortType = SortType.UPLOAD_TIME_DESC;
              this.applyFilter();
            })
          
          Button('最多点赞')
            .fontSize(12)
            .fontColor(this.sortType === SortType.LIKES_DESC ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
            .backgroundColor(this.sortType === SortType.LIKES_DESC ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
            .border({ width: 1, color: this.sortType === SortType.LIKES_DESC ? $r('app.color.brand_color') : $r('app.color.border_color') })
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })
            .onClick(() => {
              this.sortType = SortType.LIKES_DESC;
              this.applyFilter();
            })
          
          Button('最多查看')
            .fontSize(12)
            .fontColor(this.sortType === SortType.VIEWS_DESC ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
            .backgroundColor(this.sortType === SortType.VIEWS_DESC ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
            .border({ width: 1, color: this.sortType === SortType.VIEWS_DESC ? $r('app.color.brand_color') : $r('app.color.border_color') })
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              this.sortType = SortType.VIEWS_DESC;
              this.applyFilter();
            })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      
      // 操作按钮
      Row() {
        Button('清除筛选')
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .backgroundColor($r('app.color.tag_background_secondary'))
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.clearFilter();
          })
        
        Button('确定')
          .fontSize(14)
          .fontColor($r('app.color.background_color'))
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.showFilterPanel = false;
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.background_color'))
    .border({ width: { top: 1 }, color: $r('app.color.border_color') })
  }

  // 加载视图
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color($r('app.color.brand_color'))
      
      Text('加载中...')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 16 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  // 空状态视图
  @Builder
  buildEmptyView() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(173)
        .height(128)
        .margin({ bottom: 16 })
      
      Text('暂无样张')
        .fontSize(16)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 16 })
      
      Text('上传您的摄影作品与大家分享')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 8 })
      
      Button('上传样张')
        .fontSize(14)
        .fontColor($r('app.color.background_color'))
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .margin({ top: 24 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/UploadSamplePage' });
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // 样张网格
  @Builder
  buildPhotoGrid() {
    Scroll() {
      Grid() {
        ForEach(this.filteredPhotos, (photo: SamplePhoto) => {
          GridItem() {
            this.buildPhotoCard(photo)
          }
        })
      }
      .columnsTemplate(this.gridColumns === 2 ? '1fr 1fr' : '1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
  }

  // 样张卡片
  @Builder
  buildPhotoCard(photo: SamplePhoto) {
    Column() {
      // 图片
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(photo.thumbnailUri || photo.imageUri)
          .width('100%')
          .aspectRatio(1)
          .borderRadius({ topLeft: 8, topRight: 8 })
          .objectFit(ImageFit.Cover)
        
        // 分类标签
        Text(CATEGORY_NAMES[photo.category])
          .fontSize(10)
          .fontColor($r('app.color.background_color'))
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin(8)
      }
      
      // 信息区域
      Column() {
        Text(photo.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        
        Text(`${photo.cameraBrand} ${photo.cameraModel}`)
          .fontSize(12)
          .fontColor($r('app.color.secondary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 4 })
        
        Row() {
          Row() {
            Image($r('app.media.icon_like'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.secondary_text_color'))
            
            Text(photo.likes.toString())
              .fontSize(10)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ left: 2 })
          }
          
          Row() {
            Image($r('app.media.icon_view'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.secondary_text_color'))
            
            Text(photo.views.toString())
              .fontSize(10)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ left: 2 })
          }
          .margin({ left: 12 })
          
          Blank()
          
          if (photo.photographer) {
            Text(photo.photographer)
              .fontSize(10)
              .fontColor($r('app.color.secondary_text_color'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(8)
    .shadow({ radius: 4, color: Color.Black, offsetX: 0, offsetY: 1 })
    .onClick(() => {
      this.viewPhotoDetail(photo);
    })
  }
}
