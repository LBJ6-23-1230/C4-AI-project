import { describe, it, expect } from '@ohos/hypium';
import { learningFlowPages } from '../main/ets/models/LearningFlowData';

export default function learningFlowDataTest() {
  describe('learningFlowDataTest', () => {
    it('provides six ordered demo pages for C day two and day three', 0, () => {
      expect(learningFlowPages.length).assertEqual(6);
      expect(learningFlowPages[0].title).assertEqual('首页');
      expect(learningFlowPages[1].title).assertEqual('今日学习建议');
      expect(learningFlowPages[2].title).assertEqual('错题分析');
      expect(learningFlowPages[3].title).assertEqual('学习标签');
      expect(learningFlowPages[4].title).assertEqual('搭子匹配');
      expect(learningFlowPages[5].title).assertEqual('协同学习计划');
    });

    it('keeps one primary action per page in the fixed presentation flow', 0, () => {
      expect(learningFlowPages[0].primaryAction).assertEqual('查看今日建议');
      expect(learningFlowPages[1].primaryAction).assertEqual('上传错题并分析');
      expect(learningFlowPages[2].primaryAction).assertEqual('生成学习标签');
      expect(learningFlowPages[3].primaryAction).assertEqual('匹配学习搭子');
      expect(learningFlowPages[4].primaryAction).assertEqual('查看协同计划');
      expect(learningFlowPages[5].primaryAction).assertEqual('完成本轮学习');
    });

    it('contains the required static study scenario details', 0, () => {
      expect(learningFlowPages[0].cards[0].title).assertContain('小知');
      expect(learningFlowPages[1].cards[0].description).assertContain('二叉树遍历');
      expect(learningFlowPages[2].cards[1].description).assertContain('递归边界');
      expect(learningFlowPages[4].cards[0].description).assertContain('92%');
      expect(learningFlowPages[5].cards[0].bullets.length).assertEqual(4);
    });
  });
}
