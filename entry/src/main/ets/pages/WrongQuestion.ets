import router from '@ohos.router';
import { mockWrongQuestion } from '../data/MockData';
import { learningFlowPages, DemoCard, DemoPage } from '../models/LearningFlowData';
import { WrongAnalysisResult } from '../models/AgentModels';
import { LocalAgentService } from '../services/LocalAgentService';

const pageData: DemoPage = learningFlowPages[2];
const wrongAnalysis: WrongAnalysisResult =
  LocalAgentService.analyzeWrongQuestion(mockWrongQuestion.input.image);
const wrongAnalysisCard: DemoCard = {
  title: `服务分析：${wrongAnalysis.wrongType}`,
  description: wrongAnalysis.reason,
  badge: wrongAnalysis.course,
  bullets: [
    `知识点：${wrongAnalysis.knowledge.join('、')}`,
    `标签：${wrongAnalysis.tags.join('、')}`,
    `建议：${wrongAnalysis.suggestions.join('；')}`
  ]
};

@Entry
@Component
struct WrongQuestion {
  private openNext(): void {
    try {
      router.pushUrl({ url: pageData.nextUrl });
    } catch (error) {
      console.error(`Navigation failed: ${JSON.stringify(error)}`);
    }
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
          .backgroundColor('#B15B2A')
          .borderRadius(14)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      }
      .width('100%')

      if (card.title === '错题缩略图') {
        Column() {
          Text('二叉树遍历题')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
          Text('A(B(D,E),C(,F))')
            .fontSize(18)
            .fontColor('#B15B2A')
            .margin({ top: 8 })
          Text('请写出前序 / 中序 / 后序遍历')
            .fontSize(13)
            .fontColor('#667085')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFF4E8')
        .borderRadius(16)
        .border({ width: 1, color: '#F3C99C' })
      }

      Text(card.description)
        .fontSize(15)
        .fontColor('#4B5565')
        .lineHeight(22)

      ForEach(card.bullets, (item: string) => {
        Row({ space: 8 }) {
          Text('')
            .width(7)
            .height(7)
            .borderRadius(4)
            .backgroundColor('#B15B2A')
          Text(item)
            .fontSize(14)
            .fontColor('#344054')
            .layoutWeight(1)
        }
        .width('100%')
      }, (item: string) => item)
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
            .fontColor('#B15B2A')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFF4E8')
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

          this.CardView(wrongAnalysisCard)

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
        .backgroundColor('#B15B2A')
        .borderRadius(16)
        .margin({ bottom: 24 })
        .onClick(() => {
          this.openNext();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F4EF')
  }
}
