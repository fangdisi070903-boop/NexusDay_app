import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CountdownItem, CountdownTime, Category, CategoryLabels, CountdownType, calculateCountdown, formatDate } from '../models/CountdownModel';
import dataStore from '../services/DataStore';
import componentSnapshot from '@ohos.arkui.componentSnapshot';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { ConfigurationConstant } from '@kit.AbilityKit';
import picker from '@ohos.file.picker';

@Entry
@Component
struct CountdownDetail {
  @State item: CountdownItem | null = null;
  @State countdownResult: CountdownTime | null = null;
  @State isDarkMode: boolean = false;
  @State customBgImage: string = '';
  @State showBackgroundOptions: boolean = false;
  private context: common.UIAbilityContext | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.id) {
      this.item = dataStore.getCountdownById(params.id) || null;
      if (this.item) {
        this.countdownResult = calculateCountdown(this.item.targetDate, this.item.type);
      }
    }
    this.context = getContext(this) as common.UIAbilityContext;
    this.checkColorMode();
  }

  checkColorMode(): void {
    try {
      const config = this.context?.config;
      if (config) {
        this.isDarkMode = config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      }
    } catch (error) {
      console.error('Check color mode failed:', error);
    }
  }

  getWeekDay(dateStr: string): string {
    const weekDays: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const date = new Date(dateStr);
    return weekDays[date.getDay()];
  }

  formatDateFull(dateStr: string): string {
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${year}年${month}月${day}日`;
  }

  getMonth(): number {
    if (!this.item) return new Date().getMonth() + 1;
    const date = new Date(this.item.targetDate);
    return date.getMonth() + 1;
  }

  getDay(): number {
    if (!this.item) return new Date().getDate();
    const date = new Date(this.item.targetDate);
    return date.getDate();
  }

  async pickFromGallery(): Promise<void> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);

      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.customBgImage = photoSelectResult.photoUris[0];
        this.showBackgroundOptions = false;
        promptAction.showToast({ message: '背景已更换' });
      }
    } catch (error) {
      const err = error as Error;
      console.error('Pick from gallery failed:', err.message);
      promptAction.showToast({ message: '选择图片失败' });
      this.showBackgroundOptions = false;
    }
  }

  async takePhoto(): Promise<void> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);

      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.customBgImage = photoSelectResult.photoUris[0];
        this.showBackgroundOptions = false;
        promptAction.showToast({ message: '背景已更换' });
      }
    } catch (error) {
      const err = error as Error;
      console.error('Take photo failed:', err.message);
      promptAction.showToast({ message: '请尝试从图库选择' });
      this.showBackgroundOptions = false;
    }
  }

  async saveAsImage(): Promise<void> {
    try {
      promptAction.showToast({ message: '正在保存图片...' });
      
      const snapshot = componentSnapshot.get('calendarCard');
      const pixelMap = await snapshot;
      
      const packingOptions: image.PackingOption = {
        format: 'image/jpeg',
        quality: 98
      };
      
      const imagePackerApi = image.createImagePacker();
      const packData = await imagePackerApi.packing(pixelMap, packingOptions);
      
      const filesDir = this.context?.filesDir || '';
      const fileName = `countdown_${Date.now()}.jpg`;
      const filePath = `${filesDir}/${fileName}`;
      
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, packData);
      fs.closeSync(file);
      
      promptAction.showToast({ message: '图片已保存到应用目录' });
    } catch (error) {
      const err = error as Error;
      console.error('Save image failed:', err.message);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  async shareImage(): Promise<void> {
    try {
      promptAction.showToast({ message: '分享功能准备中...' });
      
      const snapshot = componentSnapshot.get('calendarCard');
      const pixelMap = await snapshot;
      
      promptAction.showToast({ message: '请使用系统分享功能' });
    } catch (error) {
      const err = error as Error;
      console.error('Share failed:', err.message);
      promptAction.showToast({ message: '分享失败，请重试' });
    }
  }

  goToEdit(): void {
    if (this.item) {
      router.pushUrl({
        url: 'pages/EditCountdown',
        params: { id: this.item.id }
      });
    }
  }

  @Builder
  backgroundOptionsSheet() {
    Column() {
      Text('更换背景')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5D4037')
        .margin({ top: 20, bottom: 20 })

      Row() {
        Button() {
          Column() {
            Text('📷')
              .fontSize(32)
            Text('拍照')
              .fontSize(14)
              .fontColor('#5D4037')
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .height(100)
        .borderRadius(16)
        .backgroundColor('#FFF8E1')
        .onClick(() => {
          this.takePhoto();
        })

        Blank().width(16)

        Button() {
          Column() {
            Text('🖼️')
              .fontSize(32)
            Text('从图库选择')
              .fontSize(14)
              .fontColor('#5D4037')
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .height(100)
        .borderRadius(16)
        .backgroundColor('#FFF8E1')
        .onClick(() => {
          this.pickFromGallery();
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      Button() {
        Text('取消')
          .fontSize(16)
          .fontColor('#8D6E63')
      }
      .width('100%')
      .height(48)
      .borderRadius(24)
      .backgroundColor('#EFEBE9')
      .margin({ top: 20, bottom: 24 })
      .onClick(() => {
        this.showBackgroundOptions = false;
      })
    }
    .width('100%')
    .backgroundColor('#FFFDE7')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  calendarCard() {
    Column() {
      Column() {
        Text(this.item?.title || '')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .width('100%')

        Blank().height(12)

        Text(CategoryLabels[this.item?.category || Category.LIFE])
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(255,255,255,0.3)')
          .borderRadius(10)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      }
      .width('100%')
      .padding({ top: 32, bottom: 24 })
      .linearGradient({
        angle: 180,
        colors: this.customBgImage ? [
          ['rgba(255,152,0,0.85)', 0],
          ['rgba(255,111,0,0.85)', 1]
        ] : [
          ['#FF9800', 0],
          ['#FF6F00', 1]
        ]
      })

      Column() {
        if (this.customBgImage) {
          Stack() {
            Image(this.customBgImage)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
            
            Column() {
              Row() {
                if (this.item?.type === CountdownType.COUNTUP) {
                  Text('已经')
                    .fontSize(18)
                    .fontColor('#FFFFFF')
                } else {
                  Text('还有')
                    .fontSize(18)
                    .fontColor('#FFFFFF')
                }

                Text(`${this.countdownResult?.days || 0}`)
                  .fontSize(56)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 8, right: 8 })

                Text('天')
                  .fontSize(18)
                  .fontColor('#FFFFFF')
              }
              .justifyContent(FlexAlign.Center)

              Blank().height(12)

              Text(this.formatDateFull(this.item?.targetDate || ''))
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.7)')
            }
            .width('100%')
            .padding({ top: 32, bottom: 32 })
            .backgroundColor('rgba(0,0,0,0.3)')
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          Column() {
            Row() {
              if (this.item?.type === CountdownType.COUNTUP) {
                Text('已经')
                  .fontSize(18)
                  .fontColor('#5D4037')
              } else {
                Text('还有')
                  .fontSize(18)
                  .fontColor('#5D4037')
              }

              Text(`${this.countdownResult?.days || 0}`)
                .fontSize(56)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6F00')
                .margin({ left: 8, right: 8 })

              Text('天')
                .fontSize(18)
                .fontColor('#5D4037')
            }
            .justifyContent(FlexAlign.Center)

            Blank().height(12)

            Text(this.formatDateFull(this.item?.targetDate || ''))
              .fontSize(14)
              .fontColor('#9E9E9E')
          }
          .width('100%')
          .padding({ top: 32, bottom: 32 })
          .backgroundColor('#FFFDE7')
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(20)
    .backgroundColor('#FFFDE7')
    .shadow({
      radius: 30,
      color: '#40000000',
      offsetX: 0,
      offsetY: 15
    })
    .border({ width: 1, color: '#E0E0E0' })
    .clip(true)
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#5D4037')
        }
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor('#FFF8E1')
        .shadow({ radius: 4, color: '#20000000', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          router.back();
        })

        Blank()

        Button() {
          Text('编辑')
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .height(40)
        .borderRadius(20)
        .linearGradient({
          angle: 90,
          colors: [
            ['#FF9800', 0],
            ['#FF6F00', 1]
          ]
        })
        .shadow({ radius: 6, color: '#30FF9800', offsetX: 0, offsetY: 3 })
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          this.goToEdit();
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      Column() {
        this.calendarCard()
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .id('calendarCard')

      Blank()

      Column() {
        Row() {
          Button() {
            Column() {
              Text('📷')
                .fontSize(22)
              Text('保存图片')
                .fontSize(13)
                .fontColor('#5D4037')
                .margin({ top: 6 })
            }
          }
          .layoutWeight(1)
          .height(72)
          .borderRadius(16)
          .backgroundColor('#FFF8E1')
          .shadow({ radius: 6, color: '#20000000', offsetX: 0, offsetY: 3 })
          .onClick(() => {
            this.saveAsImage();
          })

          Blank().width(12)

          Button() {
            Column() {
              Text('🎨')
                .fontSize(22)
              Text('更换背景')
                .fontSize(13)
                .fontColor('#5D4037')
                .margin({ top: 6 })
            }
          }
          .layoutWeight(1)
          .height(72)
          .borderRadius(16)
          .backgroundColor('#FFF8E1')
          .shadow({ radius: 6, color: '#20000000', offsetX: 0, offsetY: 3 })
          .onClick(() => {
            this.showBackgroundOptions = true;
          })

          Blank().width(12)

          Button() {
            Column() {
              Text('📤')
                .fontSize(22)
              Text('分享')
                .fontSize(13)
                .fontColor('#5D4037')
                .margin({ top: 6 })
            }
          }
          .layoutWeight(1)
          .height(72)
          .borderRadius(16)
          .backgroundColor('#FFF8E1')
          .shadow({ radius: 6, color: '#20000000', offsetX: 0, offsetY: 3 })
          .onClick(() => {
            this.shareImage();
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFDE7')
    .bindSheet($$this.showBackgroundOptions, this.backgroundOptionsSheet(), {
      height: 260,
      backgroundColor: '#FFFDE7',
      dragBar: true
    })
  }
}
