import { describe, it, expect } from '@ohos/hypium';
import { LocalAgentService } from '../main/ets/services/LocalAgentService';

export default function focusLogicTest() {
  describe('focusLogicTest', () => {
    it('breaks a low-completion task into a shorter next step', 0, () => {
      const feedback = LocalAgentService.createFocusFeedback({
        taskId: 'focus-1', course: '数据结构', task: '梳理二叉树中序遍历',
        plannedMinutes: 30, actualMinutes: 12, pauseCount: 1,
        interruptionCount: 0, completionRate: 40, selfAssessment: 'partial',
        timerType: 'countdown', status: 'not_completed',
        endedAt: '2026-07-14 21:12'
      });
      expect(feedback.level).assertEqual('adjust');
      expect(feedback.nextSuggestion).assertContain('15 分钟');
    });

    it('recommends consolidation after a completed focus session', 0, () => {
      const feedback = LocalAgentService.createFocusFeedback({
        taskId: 'focus-2', course: '数据结构', task: '完成二叉树遍历练习',
        plannedMinutes: 30, actualMinutes: 30, pauseCount: 0,
        interruptionCount: 0, completionRate: 100, selfAssessment: 'completed',
        timerType: 'countdown', status: 'completed',
        endedAt: '2026-07-14 21:30'
      });
      expect(feedback.level).assertEqual('advance');
      expect(feedback.nextSuggestion).assertContain('巩固');
    });
    it('treats strict interruptions as an adjustment session', 0, () => {
      const feedback = LocalAgentService.createFocusFeedback({
        taskId: 'focus-strict-1', course: 'Data Structure', task: 'Review binary tree traversal',
        plannedMinutes: 30, actualMinutes: 8, pauseCount: 0,
        interruptionCount: 1, completionRate: 27, selfAssessment: 'not_completed',
        timerType: 'countdown', status: 'interrupted',
        endedAt: '2026-07-15 20:10'
      });
      expect(feedback.level).assertEqual('adjust');
      expect(feedback.nextSuggestion).assertContain('15');
    });

    it('supports stopwatch sessions without a planned target', 0, () => {
      const feedback = LocalAgentService.createFocusFeedback({
        taskId: 'focus-stopwatch-1', course: 'Operating System', task: 'Read process scheduling notes',
        plannedMinutes: 0, actualMinutes: 18, pauseCount: 0,
        interruptionCount: 0, completionRate: 100, selfAssessment: 'completed',
        timerType: 'stopwatch', status: 'completed',
        endedAt: '2026-07-15 20:35'
      });
      expect(feedback.level).assertEqual('advance');
    });
  });
}
