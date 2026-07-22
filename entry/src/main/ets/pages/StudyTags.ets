import router from '@ohos.router';
import { appState } from '../data/AppState';
import { RadarChart } from '../components/RadarChart';
import { ChatNavigation } from '../services/ChatNavigation';

@Entry
@Component
struct StudyTags {
  @State weakTags: string[] = [];
  @State strongTags: string[] = [];
  @State chartDims: string[] = [];
  @State chartCurrent: number[] = [];
  @State chartTarget: number[] = [];
  @State chartWeak: number[] = [];
  @State chartStrong: number[] = [];

  aboutToAppear(): void {
    this.weakTags = appState.getWeaknessTags();
    this.strongTags = appState.getStrengthTags();
    this.buildChartData();
  }

  private buildChartData(): void {
    const allDims: string[] = this.weakTags.concat(this.strongTags);
    const dims: string[] = allDims.slice(0, 6);

    if (dims.length === 0) {
      this.chartDims = ['暂无疑问', '暂无错题', '暂无数据', '请先上传', '错题分析'];
      this.chartCurrent = [50, 50, 50, 50, 50];
      this.chartTarget = [70, 70, 70, 70, 70];
      this.chartWeak = [];
      this.chartStrong = [];
      return;
    }

    this.chartDims = dims;
    const cur: number[] = [];
    const tgt: number[] = [];
    const weakIdx: number[] = [];
    const strongIdx: number[] = [];

    for (let i: number = 0; i < dims.length; i++) {
      if (i < this.weakTags.length) {
        cur.push(35);
        tgt.push(70);
        weakIdx.push(i);
      } else {
        cur.push(75);
        tgt.push(70);
        strongIdx.push(i);
      }
    }

    this.chartCurrent = cur;
    this.chartTarget = tgt;
    this.chartWeak = weakIdx;
    this.chartStrong = strongIdx;
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('← 返回')
          .fontSize(14).fontColor('#64748B').fontWeight(FontWeight.Medium)
          .onClick(() => { router.back(); })
        Blank()
        Text('知识画像')
          .fontSize(13).fontColor('#2563EB').fontWeight(FontWeight.Bold)
          .backgroundColor('#EFF6FF').borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 16 }) {
          // 雷达图
          Column({ space: 8 }) {
            Text('知识薄弱点雷达图')
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#111827')
            Text('绿线 = 你的水平 · 灰虚线 = 目标水平 · 红色标记 = 薄弱维度')
              .fontSize(12).fontColor('#6B7280')
            RadarChart({
              dimensions: this.chartDims,
              current: this.chartCurrent,
              target: this.chartTarget,
              weakIndices: this.chartWeak,
              strengthIndices: this.chartStrong
            })
          }
          .width('100%').padding(16).backgroundColor('#FFFFFF')
          .borderRadius(16).shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 4 })

          // 图例
          Row({ space: 20 }) {
            Row({ space: 4 }) {
              Text('●').fontSize(12).fontColor('#EF4444')
              Text('薄弱点').fontSize(12).fontColor('#6B7280')
            }
            Row({ space: 4 }) {
              Text('●').fontSize(12).fontColor('#2563EB')
              Text('已掌握').fontSize(12).fontColor('#6B7280')
            }
            Row({ space: 4 }) {
              Text('●').fontSize(12).fontColor('#3B82F6')
              Text('进行中').fontSize(12).fontColor('#6B7280')
            }
          }
          .width('100%').justifyContent(FlexAlign.Center)

          // 薄弱知识点卡片
          if (this.weakTags.length > 0) {
            Column({ space: 10 }) {
              Text('⚠️ 薄弱知识点')
                .fontSize(17).fontWeight(FontWeight.Bold).fontColor('#111827').width('100%')

              ForEach(this.weakTags, (tag: string, index: number) => {
                Column({ space: 6 }) {
                  Row() {
                    Text(tag).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#DC2626')
Text(index === 0 ? '严重' : '一般')
                      .fontSize(11).fontColor('#FFFFFF')
                      .backgroundColor(index === 0 ? '#EF4444' : '#F59E0B')
                      .borderRadius(10).padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  }.width('100%')
                  Text(index === 0 ? '最近3次错题' : '最近1次错题').fontSize(12).fontColor('#9CA3AF')
                  Text('建议：重点复习相关知识，做专项练习')
                    .fontSize(13).fontColor('#4B5563').lineHeight(18)
                }
                .width('100%').padding(14).backgroundColor('#FEF2F2')
                .borderRadius(12).border({ width: 1, color: '#FECACA' })
              }, (tag: string) => tag)
            }
            .width('100%').padding(16).backgroundColor('#FFFFFF')
            .borderRadius(16).shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 4 })
          }

          // 优势知识点
          if (this.strongTags.length > 0) {
            Column({ space: 10 }) {
              Text('✓ 优势知识点')
                .fontSize(17).fontWeight(FontWeight.Bold).fontColor('#111827').width('100%')

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.strongTags, (tag: string) => {
                  Text(tag).fontSize(13).fontColor('#2563EB')
                    .backgroundColor('#EFF6FF').borderRadius(14)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                }, (tag: string) => tag)
              }.width('100%')
            }
            .width('100%').padding(16).backgroundColor('#FFFFFF')
            .borderRadius(16).shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 4 })
          }

          // 底部快捷入口
          Button('💬 问知学搭子')
            .fontSize(14).fontColor('#FFFFFF')
            .backgroundColor('#2563EB').height(44).borderRadius(12).width('100%')
            .onClick(() => {
              appState.setChatPrompt('帮我分析这些薄弱点怎么补');
              router.pushUrl({ url: 'pages/ChatMain' });
            })
        }
        .width('100%').padding(16)
      }
      .layoutWeight(1).backgroundColor('#F3F6FA')
    }
    .width('100%').height('100%')
  }
}
