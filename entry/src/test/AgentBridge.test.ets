import { describe, it, expect } from '@ohos/hypium';
import { AgentBridge } from '../main/ets/services/AgentBridge';
import { ChatNavigation } from '../main/ets/services/ChatNavigation';
import { ChatMessage } from '../main/ets/models/ChatModels';
import { appState } from '../main/ets/data/AppState';

export default function agentBridgeTest() {
  describe('agentBridgeTest', () => {
    it('matches study intents from natural Chinese wording', 0, () => {
      expect(AgentBridge.matchIntent('今天先学什么比较合适')).assertEqual('suggestion');
      expect(AgentBridge.matchIntent('帮我看看错题薄弱点')).assertEqual('weakness');
      expect(AgentBridge.matchIntent('给我匹配学习搭子')).assertEqual('partner');
      expect(AgentBridge.matchIntent('随便聊两句')).assertEqual('free_chat');
    });

    it('builds the future backend request shape with trimmed history', 0, () => {
      const history: ChatMessage[] = [];
      for (let index: number = 0; index < 24; index++) {
        history.push({
          id: `m-${index}`,
          role: index % 2 === 0 ? 'user' : 'agent',
          text: `message-${index}`,
          time: '09:00',
          status: 'done'
        });
      }

      const request = AgentBridge.buildRequest('看看我的复习计划', 'image://wrong-question', history, 'u-1');
      expect(request.intent).assertEqual('plan');
      expect(request.user_message).assertEqual('看看我的复习计划');
      expect(request.user_id).assertEqual('u-1');
      expect(request.image).assertEqual('image://wrong-question');
      expect(request.history.length).assertEqual(20);
      expect(request.history[0].text).assertEqual('message-4');
    });

    it('returns cards that map to the three A-side entry points', 0, async () => {
      const suggestion = await AgentBridge.callAgent('今天学习建议', undefined, [], 'u-1');
      const weakness = await AgentBridge.callAgent('分析错题薄弱点', 'image://wrong-question', [], 'u-1');
      const partner = await AgentBridge.callAgent('匹配搭子', undefined, [], 'u-1');

      expect(suggestion.card?.type).assertEqual('suggestion');
      expect(suggestion.card?.targetPage).assertEqual('pages/StudySuggestion');
      expect(weakness.card?.type).assertEqual('weakness');
      expect(weakness.card?.targetPage).assertEqual('pages/WrongQuestion');
      expect(partner.card?.type).assertEqual('partner');
      expect(partner.card?.targetPage).assertEqual('pages/PartnerMatch');
    });

    it('returns a completed workbench task to the chat with a next step', 0, () => {
      appState.completeChatTask('错题已加入明日复习。', '现在可以确认本周复习计划。', '复习计划', 'pages/StudyPlan');
      const handoff = appState.consumeChatHandoff();

      expect(handoff?.summary).assertEqual('错题已加入明日复习。');
      expect(handoff?.nextPrompt).assertEqual('现在可以确认本周复习计划。');
      expect(handoff?.actionLabel).assertEqual('复习计划');
      expect(handoff?.targetPage).assertEqual('pages/StudyPlan');
      expect(appState.consumeChatHandoff()).assertNull();
    });

    it('uses the chat home as the fixed return destination', 0, () => {
      expect(ChatNavigation.chatHome()).assertEqual('pages/ChatMain');
    });
  });
}
