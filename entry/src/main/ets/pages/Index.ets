import router from '@ohos.router';
import { mockCandidates, mockCourse, mockCurrentUser } from '../data/MockData';
import { learningFlowPages, DemoCard, DemoPage } from '../models/LearningFlowData';
import { PartnerMatch, StudySuggestion } from '../models/AgentModels';
import { LocalAgentService } from '../services/LocalAgentService';

const pageData: DemoPage = learningFlowPages[0];
const generatedSuggestion: StudySuggestion =
  LocalAgentService.generateStudySuggestions(mockCurrentUser, mockCourse);
const generatedPartner: PartnerMatch | null =
  LocalAgentService.matchBestPartner(mockCurrentUser, mockCandidates);
const partnerSummary: string = generatedPartner === null ?
  '暂时没有找到合适的学习搭档' :
  `推荐搭子：${generatedPartner.matchName}，匹配分数 ${generatedPartner.score}`;
const localServiceCard: DemoCard = {
  title: '本地服务推荐',
  description: `${generatedSuggestion.course}：${generatedSuggestion.task}`,
  badge: generatedSuggestion.priority,
  bullets: [
    generatedSuggestion.reason,
    `建议时长：${generatedSuggestion.duration}`,
    partnerSummary
  ]
};

@Entry
@Component
struct Index {
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
          .backgroundColor('#2F7D6D')
          .borderRadius(14)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      }
      .width('100%')

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
            .backgroundColor('#2F7D6D')
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
          Row() {
            Text('Zhixue Mate')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2F7D6D')
              .layoutWeight(1)
            Text(pageData.step)
              .fontSize(13)
              .fontColor('#2F7D6D')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#DDF3EC')
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          }
          .width('100%')

          Text('知学搭子')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .width('100%')

          Text(pageData.subtitle)
            .fontSize(16)
            .fontColor('#667085')
            .lineHeight(24)
            .width('100%')

          this.CardView(localServiceCard)

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
        .backgroundColor('#2F7D6D')
        .borderRadius(16)
        .margin({ bottom: 24 })
        .onClick(() => {
          this.openNext();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
