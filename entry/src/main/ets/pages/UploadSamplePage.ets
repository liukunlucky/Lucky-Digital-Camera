// 样张上传页面

import {
  UploadSampleRequest,
  PhotoCategory,
  ShootingParams,
  CATEGORY_NAMES,
  PREDEFINED_TAGS
} from '../model/SampleGalleryModel';
import { SampleGalleryService } from '../service/SampleGalleryService';
import { CameraDataItem, cameraDataJsonService } from '../service/CameraDataJsonService';
import { CameraModel, CameraType, SensorFormat, CameraStatus } from '../model/CameraModel';
import router from '@ohos.router';
import picker from '@ohos.file.picker';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct UploadSamplePage {
  @State selectedImageUri: string = '';
  @State title: string = '';
  @State description: string = '';
  @State selectedCameraId: string = '';
  @State selectedCategory: PhotoCategory = PhotoCategory.OTHER;
  @State selectedTags: string[] = [];
  @State customTag: string = '';
  @State photographer: string = '';
  @State location: string = '';
  @State isPublic: boolean = true;
  @State isUploading: boolean = false;
  
  // 拍摄参数
  @State aperture: string = '';
  @State shutterSpeed: string = '';
  @State iso: string = '';
  @State focalLength: string = '';
  @State exposureMode: string = '';
  @State meteringMode: string = '';
  @State whiteBalance: string = '';
  @State flashMode: string = '';
  @State lens: string = '';
  
  @State availableCameras: CameraModel[] = [];
  @State selectCameraDataItem: CameraDataItem | undefined = undefined;
  @State availableCameraDataItems: CameraDataItem[] = [];
  @State showCameraSelector: boolean = false;
  @State showTagSelector: boolean = false;
  
  private sampleService = SampleGalleryService.getInstance();

  async aboutToAppear() {
    await this.loadCameras();
  }

  // 加载相机列表
  private async loadCameras() {
    try {
      const cameras = await cameraDataJsonService.getAllCameras();
      this.availableCameraDataItems = cameras;
      // 将CameraDataItem类型转换为CameraModel类型
      this.availableCameras = cameras.map(camera => {
        const cameraModel: CameraModel = {
          id: `${camera.Brand}_${camera.Model}`,
          model_name: camera.Model,
          full_name: `${camera.Brand} ${camera.Model}`,
          brand_name_en: camera.Brand,
          brand_name_zh: camera.Brand,
          release_date: camera.Year,
          announcement_date: camera.Year,
          availability_date: camera.Year,
          discontinuation_date: undefined,
          camera_type: CameraType.DSLR,
          sensor_format: SensorFormat.FULL_FRAME,
          status: CameraStatus.IN_PRODUCTION,
          cover_image: camera.image_file,
          gallery_images: [camera.image_file],
          promotional_video: undefined,
          price_info: {
            launch_price_usd: 0,
            launch_price_cny: 0,
            current_price_usd: 0,
            current_price_cny: 0,
            price_history: []
          },
          specs: {
            sensor_type: camera.SensorType || '',
            sensor_size: camera.SensorSize || '',
            sensor_resolution: camera.Megapixels ? camera.Megapixels + 'MP' : '',
            iso_range: camera.ISO || '',
            iso_extended: camera.ISO || '',
            autofocus_points: '',
            autofocus_type: 'Phase Detection',
            shutter_speed: camera.MaxShutterSpeed || '',
            flash_sync_speed: '1/250s',
            continuous_shooting: '',
            metering_modes: camera.Metering || '',
            image_stabilization: '',
            special_features: [],
            viewfinder_type: camera.Viewfinder || '',
            viewfinder_coverage: '',
            viewfinder_magnification: '',
            lcd_size: camera.ScreenSize || '',
            lcd_resolution: camera.ScreenResolution || '',
            lcd_type: '触摸翻转屏',
            video_resolution: camera.MaxVideoResolution || '',
            video_codec: 'H.264/H.265',
            storage_slots: 'SD卡槽',
            storage_types: camera.StorageTypes || '',
            connectivity: camera.USB || '',
            battery_life: camera.Battery || '',
            battery_type: camera.Battery || '',
            dimensions: camera.Dimensions || '',
            weight: camera.Weight || '',
            weather_sealing: false
          },
          description: '',
          key_features: [],
          target_audience: [],
          competitors: [],
          reviews: [],
          awards: [],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          data_source: 'CameraDataService',
          data_quality: 8
        };
        return cameraModel;
      });
    } catch (error) {
      console.error('加载相机列表失败:', error);
    }
  }

  // 选择图片
  private async selectImage() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      
      if (photoSelectResult.photoUris.length > 0) {
        this.selectedImageUri = photoSelectResult.photoUris[0];
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
  }

  // 添加标签
  private addTag(tag: string) {
    if (!this.selectedTags.includes(tag)) {
      this.selectedTags.push(tag);
    }
  }

  // 移除标签
  private removeTag(tag: string) {
    const index = this.selectedTags.indexOf(tag);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    }
  }

  // 添加自定义标签
  private addCustomTag() {
    if (this.customTag.trim() && !this.selectedTags.includes(this.customTag.trim())) {
      this.selectedTags.push(this.customTag.trim());
      this.customTag = '';
    }
  }

  // 验证表单
  private validateForm(): boolean {
    if (!this.selectedImageUri) {
      promptAction.showToast({
        message: '请选择图片',
        duration: 1500
      });
      return false;
    }
    
    if (!this.title.trim()) {
      promptAction.showToast({
        message: '请输入样张标题',
        duration: 1500
      });
      return false;
    }
    
    if (!this.selectedCameraId) {
      promptAction.showToast({
        message: '请选择相机设备',
        duration: 1500
      });
      return false;
    }
    
    return true;
  }

  // 上传样张
  private async uploadSample() {
    if (!this.validateForm()) {
      return;
    }
    
    try {
      this.isUploading = true;
      
      const shootingParams: ShootingParams = {
        aperture: this.aperture || undefined,
        shutterSpeed: this.shutterSpeed || undefined,
        iso: this.iso || undefined,
        focalLength: this.focalLength || undefined,
        exposureMode: this.exposureMode || undefined,
        meteringMode: this.meteringMode || undefined,
        whiteBalance: this.whiteBalance || undefined,
        flashMode: this.flashMode || undefined,
        lens: this.lens || undefined
      };
      
      const request: UploadSampleRequest = {
        title: this.title.trim(),
        description: this.description.trim() || undefined,
        cameraDataItem: this.selectCameraDataItem,
        cameraId: this.selectedCameraId,
        shootingParams,
        tags: this.selectedTags,
        category: this.selectedCategory,
        photographer: this.photographer.trim() || undefined,
        location: this.location.trim() || undefined,
        isPublic: this.isPublic
      };
      
      await this.sampleService.uploadSamplePhoto(request, this.selectedImageUri);
      
      // 通知样张库页面刷新数据
      AppStorage.setOrCreate('refreshSampleGallery', Date.now());
      
      // 上传成功，返回样张库
      router.back();
    } catch (error) {
      console.error('上传样张失败:', error);
    } finally {
      this.isUploading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar()
      
      Scroll() {
        Column() {
          // 图片选择
          this.buildImageSelector()
          
          // 基本信息
          this.buildBasicInfo()
          
          // 相机选择
          this.buildCameraSelector()
          
          // 拍摄参数
          this.buildShootingParams()
          
          // 分类和标签
          this.buildCategoryAndTags()
          
          // 其他信息
          this.buildOtherInfo()
          
          // 隐私设置
          this.buildPrivacySettings()
          
          // 上传按钮
          this.buildUploadButton()
        }
        .padding(16)
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
    .bindSheet($$this.showCameraSelector, this.CameraSelector(), {
      height: '70%',
      showClose: false,
      dragBar: true
    })
  }

  // 顶部导航栏
  @Builder
  buildTopBar() {
    Row() {
      Button() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.primary_text_color'))
      }
      .width(40)
      .height(40)
      .backgroundColor('transparent')
      .onClick(() => {
        router.back();
      })
      
      Text('上传样张')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Blank().width(40)

    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.background_color'))
  }

  // 图片选择
  @Builder
  buildImageSelector() {
    Column() {
      Row() {
        Text('选择图片 ')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
        
        Text('*')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF0000')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      if (this.selectedImageUri) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(this.selectedImageUri)
            .width('100%')
            .height(200)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
          
          Button() {
            Image($r('app.media.icon_close'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.background_color'))
          }
          .width(32)
          .height(32)
          .backgroundColor($r('app.color.primary_text_color'))
          .borderRadius(16)
          .margin(8)
          .onClick(() => {
            this.selectedImageUri = '';
          })
        }
      } else {
        Column() {
          Image($r('app.media.icon_add_photo'))
            .width(48)
            .height(48)
            .fillColor($r('app.color.secondary_text_color'))
          
          Text('点击选择图片')
            .fontSize(14)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 12 })
          
          Text('支持 JPG、PNG 格式，最大 10MB')
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .margin({ top: 4 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.input_background_color'))
        .borderRadius(8)
        .border({ width: 2, color: $r('app.color.border_color'), style: BorderStyle.Dashed })
        .onClick(() => {
          this.selectImage();
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 24 })
  }

  // 基本信息
  @Builder
  buildBasicInfo() {
    Column() {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .width('100%')
        .margin({ bottom: 12 })
      
      // 标题
      Column() {
        Row() {
          Text('标题 ')
            .fontSize(14)
            .fontColor($r('app.color.primary_text_color'))
          Text('*')
            .fontSize(14)
            .fontColor(Color.Red)
        }
        .width('100%')
        .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入样张标题', text: this.title })
          .width('100%')
          .height(40)
          .backgroundColor($r('app.color.input_background_color'))
          .borderRadius(8)
          .onChange((value: string) => {
            this.title = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      
      // 描述
      Column() {
        Text('描述')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 8 })
        
        TextArea({ placeholder: '请输入样张描述...', text: this.description })
          .width('100%')
          .height(80)
          .backgroundColor($r('app.color.input_background_color'))
          .borderRadius(8)
          .onChange((value: string) => {
            this.description = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 24 })
  }

  // 相机选择
  @Builder
  buildCameraSelector() {
    Column() {
      Row() {
        Text('相机设备 ')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
        
        Text('*')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF0000')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Button() {
        Row() {
          Text(this.selectCameraDataItem ? this.selectCameraDataItem.Brand + ' ' + this.selectCameraDataItem.Model : '请选择相机')
            .fontSize(14)
            .fontColor(this.selectCameraDataItem ? $r('app.color.primary_text_color') : $r('app.color.secondary_text_color'))
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
          
          Image($r('app.media.icon_arrow_down'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.secondary_text_color'))
        }
      }
      .width('100%')
      .height(40)
      .backgroundColor($r('app.color.input_background_color'))
      .borderRadius(8)
      .padding({ left: 12, right: 12 })
      .onClick(() => {
        this.showCameraSelector = true;
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 24 })
  }

  // 拍摄参数
  @Builder
  buildShootingParams() {
    Column() {
      Text('拍摄参数')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .width('100%')
        .margin({ bottom: 12 })
      
      Grid() {
        GridItem() {
          this.buildParamInput('光圈', 'f/2.8', this.aperture, (value: string) => {
            this.aperture = value;
          })
        }
        
        GridItem() {
          this.buildParamInput('快门', '1/125s', this.shutterSpeed, (value: string) => {
            this.shutterSpeed = value;
          })
        }
        
        GridItem() {
          this.buildParamInput('ISO', 'ISO 400', this.iso, (value: string) => {
            this.iso = value;
          })
        }
        
        GridItem() {
          this.buildParamInput('焦距', '85mm', this.focalLength, (value: string) => {
            this.focalLength = value;
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .margin({ bottom: 12 })
      
      // 其他参数
      Column() {
        this.buildParamInput('镜头', 'RF 85mm f/1.8 MACRO IS STM', this.lens, (value: string) => {
          this.lens = value;
        })
      }
      .margin({ bottom: 12 })
      
      Grid() {
        GridItem() {
          this.buildParamInput('曝光模式', '光圈优先', this.exposureMode, (value: string) => {
            this.exposureMode = value;
          })
        }
        
        GridItem() {
          this.buildParamInput('测光模式', '矩阵测光', this.meteringMode, (value: string) => {
            this.meteringMode = value;
          })
        }
        
        GridItem() {
          this.buildParamInput('白平衡', '自动', this.whiteBalance, (value: string) => {
            this.whiteBalance = value;
          })
        }
        
        GridItem() {
          this.buildParamInput('闪光灯', '关闭', this.flashMode, (value: string) => {
            this.flashMode = value;
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 24 })
  }

  // 参数输入框
  @Builder
  buildParamInput(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.secondary_text_color'))
        .width('100%')
        .margin({ bottom: 4 })
      
      TextInput({ placeholder: placeholder, text: value })
        .width('100%')
        .height(36)
        .fontSize(12)
        .backgroundColor($r('app.color.input_background_color'))
        .borderRadius(6)
        .onChange(onChange)
    }
    .alignItems(HorizontalAlign.Start)
  }

  // 分类和标签
  @Builder
  buildCategoryAndTags() {
    Column() {
      // 分类选择
      Column() {
        Row() {
          Text('分类 ')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
          Text('*')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Red)
        }
        .width('100%')
        .margin({ bottom: 12 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
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
                this.selectedCategory = category;
              })
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      
      // 标签选择
      Column() {
        Text('标签')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 12 })
        
        // 已选标签
        if (this.selectedTags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.selectedTags, (tag: string) => {
              Row() {
                Text(tag)
                  .fontSize(12)
                  .fontColor($r('app.color.brand_color'))
                
                Button() {
                  Image($r('app.media.icon_close'))
                    .width(12)
                    .height(12)
                    .fillColor($r('app.color.brand_color'))
                }
                .width(16)
                .height(16)
                .backgroundColor(Color.Transparent)
                .margin({ left: 4 })
                .onClick(() => {
                  this.removeTag(tag);
                })
              }
              .backgroundColor($r('app.color.tag_background_primary'))
              .borderRadius(12)
              .padding({ left: 8, right: 4, top: 4, bottom: 4 })
              .margin({ right: 8, bottom: 8 })
            })
          }
          .margin({ bottom: 12 })
        }
        
        // 预定义标签
        Text('推荐标签')
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .width('100%')
          .margin({ bottom: 8 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(PREDEFINED_TAGS.slice(0, 15), (tag: string) => {
            Button(tag)
              .fontSize(12)
              .fontColor(this.selectedTags.includes(tag) ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
              .backgroundColor(this.selectedTags.includes(tag) ? $r('app.color.tag_background_primary') : $r('app.color.tag_background_secondary'))
              .border({ width: 1, color: this.selectedTags.includes(tag) ? $r('app.color.brand_color') : $r('app.color.border_color') })
              .borderRadius(12)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .margin({ right: 6, bottom: 6 })
              .onClick(() => {
                if (this.selectedTags.includes(tag)) {
                  this.removeTag(tag);
                } else {
                  this.addTag(tag);
                }
              })
          })
        }
        .margin({ bottom: 12 })
        
        // 自定义标签
        // Row() {
        //   TextInput({ placeholder: '添加自定义标签', text: this.customTag })
        //     .layoutWeight(1)
        //     .height(36)
        //     .backgroundColor($r('app.color.input_background_color'))
        //     .borderRadius(6)
        //     .onChange((value: string) => {
        //       this.customTag = value;
        //     })
        //
        //   Button('添加')
        //     .fontSize(12)
        //     .fontColor($r('app.color.background_color'))
        //     .backgroundColor($r('app.color.brand_color'))
        //     .borderRadius(6)
        //     .padding({ left: 12, right: 12 })
        //     .margin({ left: 8 })
        //     .onClick(() => {
        //       this.addCustomTag();
        //     })
        // }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 24 })
  }

  // 其他信息
  @Builder
  buildOtherInfo() {
    Column() {
      Text('其他信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .width('100%')
        .margin({ bottom: 12 })
      
      // 摄影师
      Column() {
        Text('摄影师')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入摄影师姓名', text: this.photographer })
          .width('100%')
          .height(40)
          .backgroundColor($r('app.color.input_background_color'))
          .borderRadius(8)
          .onChange((value: string) => {
            this.photographer = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      
      // 拍摄地点
      Column() {
        Text('拍摄地点')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .width('100%')
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入拍摄地点', text: this.location })
          .width('100%')
          .height(40)
          .backgroundColor($r('app.color.input_background_color'))
          .borderRadius(8)
          .onChange((value: string) => {
            this.location = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 24 })
  }

  // 隐私设置
  @Builder
  buildPrivacySettings() {
    Column() {
      Text('隐私设置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_text_color'))
        .width('100%')
        .margin({ bottom: 12 })
      
      Row() {
        Column() {
          Text('公开样张')
            .fontSize(14)
            .fontColor($r('app.color.primary_text_color'))
            .width('100%')

          Text('其他用户可以查看和搜索到此样张')
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
            .width('100%')
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Toggle({ type: ToggleType.Switch, isOn: this.isPublic })
          .selectedColor($r('app.color.brand_color'))
          .onChange((isOn: boolean) => {
            this.isPublic = isOn;
          })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .visibility(Visibility.None)
    .margin({ bottom: 32 })
  }

  // 上传按钮
  @Builder
  buildUploadButton() {
    Button() {
      if (this.isUploading) {
        Row() {
          LoadingProgress()
            .width(16)
            .height(16)
            .color($r('app.color.background_color'))
          
          Text('上传中...')
            .fontSize(16)
            .fontColor($r('app.color.background_color'))
            .margin({ left: 8 })
        }
      } else {
        Text('上传样张')
          .fontSize(16)
          .fontColor($r('app.color.background_color'))
      }
    }
    .width('100%')
    .height(48)
    .backgroundColor($r('app.color.brand_color'))
    .borderRadius(24)
    .enabled(!this.isUploading)
    .onClick(() => {
      this.uploadSample();
    })
  }

  // 相机选择器
  @Builder
  CameraSelector() {
    Column() {
      // 标题栏
      Row() {
        Text('选择相机')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .layoutWeight(1)
        
        Button('取消')
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .backgroundColor('transparent')
          .onClick(() => {
            this.showCameraSelector = false;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      
      // 相机列表
      List() {
        ForEach(this.availableCameraDataItems, (camera: CameraDataItem) => {
          ListItem() {
            this.CameraItemCard(camera)
          }
          .margin({ bottom: 8 })
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  // 相机卡片
  @Builder
  CameraItemCard(camera: CameraDataItem) {
    Row() {
      // 相机图片
      Image($rawfile(cameraDataJsonService.getCameraImagePath(camera)))
        .width(50)
        .height(50)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })
        .alt($r('app.media.foreground'))
      
      Column() {
        Text(`${camera.Brand} ${camera.Model}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row() {
          if (camera.Year) {
            Text(camera.Year + '年')
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
              .margin({ right: 8 })
          }
          
          if (camera.SensorType) {
            Text(camera.SensorType)
              .fontSize(12)
              .fontColor($r('app.color.tertiary_text_color'))
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor($r('app.color.tertiary_text_color'))
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(8)
    .onClick(() => {
      this.selectedCameraId = `${camera.Brand}_${camera.Model}`;
      this.selectCameraDataItem = camera
      this.showCameraSelector = false;
    })
  }
}