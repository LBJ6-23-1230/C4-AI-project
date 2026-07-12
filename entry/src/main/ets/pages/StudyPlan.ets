import router from '@ohos.router';
import { mockCandidates, mockCurrentUser } from '../data/MockData';
import { learningFlowPages, DemoCard, DemoPage } from '../models/LearningFlowData';
import { PartnerMatch as GeneratedPartnerMatch } from '../models/AgentModels';
import { LocalAgentService } from '../services/LocalAgentService';

const pageData: DemoPage = learningFlowPages[5];
const generatedPartner: GeneratedPartnerMatch | null =
  LocalAgentService.matchBestPartner(mockCurrentUser, mockCandidates);
const generatedStudyTime: string =
  generatedPartner !== null && generatedPartner.studyTime !== null ? generatedPartner.studyTime : '今晚';
const servicePlanCard: DemoCard = generatedPartner === null ? {
  title: '服务计划：等待匹配',
  description: '暂无可生成协同计划的学习搭子。',
  badge: '待匹配',
  bullets: [
    '补充候选人数据后可重新生成',
    '也可以先完成个人复习任务'
  ]
} : {
  title: `服务计划：${generatedStudyTime} 协同复习`,
  description: `与 ${generatedPartner.matchName} 进行 ${generatedPartner.duration} 分钟协同学习。`,
  badge: '已生成',
  bullets: [
    `匹配理由：${generatedPartner.reasons.join('、')}`,
    '先互讲薄弱知识点',
    '再用错题检查理解是否到位'
  ]
};

@Entry
@Component
struct StudyPlan {
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

      ForEach(card.bullets, (item: string, index: number) => {
        Row({ space: 10 }) {
          Text((index + 1).toString())
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width(24)
            .height(24)
            .borderRadius(12)
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
          Text(pageData.step)
            .fontSize(13)
            .fontColor('#2F7D6D')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#DDF3EC')
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

          this.CardView(servicePlanCard)

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
