import router from '@ohos.router';
import { learningFlowPages, DemoCard, DemoPage } from '../models/LearningFlowData';

const pageData: DemoPage = learningFlowPages[3];

@Entry
@Component
struct StudyTags {
  private openNext(): void {
    router.pushUrl({ url: pageData.nextUrl });
  }

  @Builder
  CardView(card: DemoCard) {
    Column({ space: 12 }) {
      Row() {
        Text(card.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
          .layoutWeight(1)
        Text(card.badge)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#5967D8')
          .borderRadius(14)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      }
      .width('100%')

      Text(card.description)
        .fontSize(15)
        .fontColor('#4B5565')
        .lineHeight(22)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(card.bullets, (item: string) => {
          Text(item)
            .fontSize(13)
            .fontColor('#344054')
            .backgroundColor('#EEF0FF')
            .borderRadius(14)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .margin({ right: 8, bottom: 8 })
        }, (item: string) => item)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 14, color: '#14000000', offsetX: 0, offsetY: 6 })
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Text(pageData.step)
            .fontSize(13)
            .fontColor('#5967D8')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#EEF0FF')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })

          Text(pageData.title)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .width('100%')

          Text(pageData.subtitle)
            .fontSize(16)
            .fontColor('#667085')
            .lineHeight(24)
            .width('100%')

          ForEach(pageData.cards, (card: DemoCard) => {
            this.CardView(card)
          }, (card: DemoCard) => card.title)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 24, bottom: 120 })
      }
      .layoutWeight(1)

      Button(pageData.primaryAction)
        .width('88%')
        .height(52)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#5967D8')
        .borderRadius(16)
        .margin({ bottom: 24 })
        .onClick(() => {
          this.openNext();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FF')
  }
}
