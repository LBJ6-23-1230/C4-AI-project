import localUnitTest from './LocalUnit.test';
import learningFlowDataTest from './LearningFlowData.test';
import agentBridgeTest from './AgentBridge.test';

export default function testsuite() {
  localUnitTest();
  learningFlowDataTest();
  agentBridgeTest();
}
