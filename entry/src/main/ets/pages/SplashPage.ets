import router from '@ohos.router';
import dataStore from '../services/DataStore';

@Entry
@Component
struct SplashPage {
  @State opacityValue: number = 0;
  @State scaleValue: number = 1;
  private isNavigated: boolean = false;

  aboutToAppear(): void {
    this.startAnimation();
    this.waitForInitAndNavigate();
  }

  aboutDisappear(): void {
    this.isNavigated = true;
  }

  startAnimation(): void {
    setTimeout(() => {
      this.opacityValue = 1;
    }, 50);
  }

  async waitForInitAndNavigate(): Promise<void> {
    const startTime = Date.now();
    const minDuration = 2500;
    
    try {
      await this.ensureDataStoreReady();
      
      const elapsed = Date.now() - startTime;
      const remainingTime = Math.max(0, minDuration - elapsed);
      
      setTimeout(() => {
        this.navigateToHome();
      }, remainingTime);
    } catch (error) {
      console.error('Splash init failed:', error);
      setTimeout(() => {
        this.navigateToHome();
      }, minDuration);
    }
  }

  async ensureDataStoreReady(): Promise<void> {
    return new Promise<void>((resolve) => {
      const checkReady = (): void => {
        if (dataStore.isReady()) {
          console.info('DataStore is ready');
          resolve();
        } else {
          setTimeout(checkReady, 50);
        }
      };
      checkReady();
    });
  }

  navigateToHome(): void {
    if (this.isNavigated) return;
    this.isNavigated = true;
    router.replaceUrl({
      url: 'pages/Index'
    });
  }

  build() {
    Column() {
      Blank().layoutWeight(1)

      Column() {
        this.MainIcon()
        
        Blank().height(32)

        Text('Nexus Day')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .letterSpacing(2)

        Blank().height(12)

        Text('Nexus是连接点、核心。每个倒计时是你时间线的连接点')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .padding({ left: 40, right: 40 })
          .lineHeight(22)
      }
      .opacity(this.opacityValue)
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .animation({
        duration: 500,
        curve: Curve.EaseOut
      })

      Blank().layoutWeight(1)

      Text('v1.0.0 © 2026 Nexus Day')
        .fontSize(12)
        .fontColor($r('app.color.text_hint'))
        .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.card_background'))
  }

  @Builder
  MainIcon() {
    Column() {
      Column() {
        Text('Nexus')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 180,
        colors: [['#165DFF', 0], ['#3B82F6', 1]]
      })

      Column() {
        Stack() {
          this.GridBackground()
          
          Text('ND')
            .fontSize(52)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .letterSpacing(2)
        }
        .width('100%')
        .height(72)
      }
      .width('100%')
      .backgroundColor(Color.White)
    }
    .width(120)
    .height(120)
    .borderRadius(16)
    .clip(true)
    .shadow({
      radius: 20,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 10
    })
  }

  @Builder
  GridBackground() {
    Column() {
      ForEach([0, 1, 2, 3, 4, 5], (row: number) => {
        Row() {
          ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], (col: number) => {
            Column()
              .width(12)
              .height(12)
              .border({ width: 0.5, color: '#EEEEEE' })
          })
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
