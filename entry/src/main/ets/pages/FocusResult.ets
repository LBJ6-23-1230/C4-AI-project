import router from '@ohos.router';
import { appState } from '../data/AppState';
import { AgentFeedback, FocusSelfAssessment, FocusSession, FocusTask } from '../models/AgentModels';
import { LocalAgentService } from '../services/LocalAgentService';

@Entry
@Component
struct FocusResult {
  @State assessment: FocusSelfAssessment = 'completed';
  @State actualMinutes: number = 30;
  @State pauseCount: number = 0;
  @State interruptionCount: number = 0;
  @State saved: boolean = false;

  aboutToAppear(): void {
    if (appState.focusResultDraft !== null) {
      this.assessment = appState.focusResultDraft.selfAssessment;
      this.actualMinutes = appState.focusResultDraft.actualMinutes;
      this.pauseCount = appState.focusResultDraft.pauseCount;
      this.interruptionCount = appState.focusResultDraft.interruptionCount;
    }
  }

  private currentSession(): FocusSession {
    if (appState.focusResultDraft !== null) {
      return appState.focusResultDraft;
    }
    const focusTask: FocusTask | null = appState.activeFocusTask;
    const planned: number = focusTask?.plannedMinutes ?? 30;
    const actual: number = this.assessment === 'completed' ? planned : Math.min(this.actualMinutes, Math.max(1, planned - 1));
    return {
      taskId: `focus-${Date.now()}`, course: focusTask?.course ?? '数据结构', task: focusTask?.task ?? '理清二叉树中序遍历',
      plannedMinutes: planned, actualMinutes: actual, pauseCount: this.pauseCount, interruptionCount: this.interruptionCount,
      completionRate: Math.min(100, Math.round(actual / planned * 100)), selfAssessment: this.assessment,
      timerType: focusTask?.timerType ?? 'countdown',
      status: this.assessment === 'completed' ? 'completed' : (this.interruptionCount > 0 ? 'interrupted' : 'not_completed'),
      endedAt: new Date().toLocaleString()
    };
  }

  private save(): void {
    const session: FocusSession = this.currentSession();
    appState.saveFocusSession(session);
    const currentPlan = appState.weeklyPlan ?? LocalAgentService.generateWeeklyPlan(
      appState.courses, appState.homeworkDDLs, appState.currentUser
    );
    appState.setWeeklyPlan(LocalAgentService.adjustPlanAfterFocus(currentPlan, session));
    appState.clearFocusResultDraft();
    this.saved = true;
  }

  private timerLabel(): string {
    return this.currentSession().timerType === 'stopwatch' ? '正计时' : '倒计时';
  }

  private statusLabel(): string {
    switch (this.currentSession().status) {
      case 'completed': return '已完成';
      case 'interrupted': return '已中断';
      default: return '未完成';
    }
  }

  build() {
    Column() {
      Row() { Text('专注结果').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#2563EB'); Blank(); Text('完成后已记录').fontSize(12).fontColor('#6B7FA0') }
        .width('100%').padding(20).backgroundColor('#FFFFFF')
      Scroll() {
        Column({ space: 16 }) {
          Text(this.currentSession().completionRate >= 90 ? '这一段时间，做得很扎实。' : '这次的节奏，也值得被看见。')
            .fontSize(25).fontWeight(FontWeight.Bold).fontColor('#202522').width('100%')
          Row({ space: 10 }) {
            this.StatCard(`${this.currentSession().plannedMinutes} 分钟`, '计划时长')
            this.StatCard(`${this.currentSession().actualMinutes} 分钟`, '实际专注')
            this.StatCard(`${this.currentSession().completionRate}%`, '完成度')
          }.width('100%')
          Row({ space: 10 }) { this.StatCard(`${this.currentSession().pauseCount} 次`, '暂停'); this.StatCard(`${this.currentSession().interruptionCount} 次`, '中断') }.width('100%')
          Row({ space: 10 }) { this.StatCard(this.timerLabel(), '计时方式'); this.StatCard(this.statusLabel(), '记录状态') }.width('100%')
          Column({ space: 12 }) {
            Text('这次完成得怎么样？').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#202522').width('100%')
            Row({ space: 8 }) {
              ForEach(['completed', 'partial', 'not_completed'], (value: string) => {
                Button(this.assessmentLabel(value)).layoutWeight(1).fontSize(13).fontColor(this.assessment === value ? '#FFFFFF' : '#2563EB')
                  .backgroundColor(this.assessment === value ? '#2563EB' : '#FFFFFF').borderRadius(12)
                  .border({ width: 1, color: '#BFDBFE' }).onClick(() => this.assessment = value as FocusSelfAssessment)
              }, (value: string) => value)
            }.width('100%')
          }.width('100%').padding(18).backgroundColor('#FFFFFF').borderRadius(20).border({ width: 1, color: '#F1F5F9' })
          Column({ space: 8 }) {
            Text('小知的下一步建议').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#2563EB').width('100%')
            Text(this.currentFeedback().feedback).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#202522').lineHeight(24)
            Text(this.currentFeedback().nextSuggestion).fontSize(13).fontColor('#64748B').lineHeight(20)
          }.width('100%').padding(18).backgroundColor('#EFF6FF').borderRadius(20)
          if (this.saved) {
            Button('查看 Agent 更新后的计划').width('100%').height(52).fontColor('#FFFFFF').fontWeight(FontWeight.Bold).backgroundColor('#2563EB').borderRadius(16)
              .onClick(() => router.pushUrl({ url: 'pages/StudyPlan' }))
          } else {
            Button('保存这次记录').width('100%').height(52).fontColor('#FFFFFF').fontWeight(FontWeight.Bold).backgroundColor('#2563EB').borderRadius(16).onClick(() => this.save())
          }
        }.width('100%').padding(20)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }

  private assessmentLabel(value: string): string {
    return value === 'completed' ? '完成' : value === 'partial' ? '部分完成' : '未完成';
  }

  private currentFeedback(): AgentFeedback {
    return LocalAgentService.createFocusFeedback(this.currentSession());
  }

  @Builder
  StatCard(value: string, label: string) {
    Column({ space: 4 }) { Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#202522'); Text(label).fontSize(11).fontColor('#64748B') }
      .layoutWeight(1).alignItems(HorizontalAlign.Start).padding(14).backgroundColor('#F5F7FA').borderRadius(16)
  }
}
