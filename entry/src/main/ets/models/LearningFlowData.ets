export interface DemoCard {
  title: string;
  description: string;
  badge: string;
  bullets: string[];
}

export interface DemoPage {
  title: string;
  subtitle: string;
  step: string;
  primaryAction: string;
  nextUrl: string;
  cards: DemoCard[];
}

export const learningFlowPages: DemoPage[] = [
  {
    title: '首页',
    subtitle: '知学搭子为你安排今天最适合推进的一步',
    step: '1 / 6',
    primaryAction: '查看今日建议',
    nextUrl: 'pages/StudySuggestion',
    cards: [
      {
        title: '小知，晚上好',
        description: '目标：数据结构期末 80+。今晚建议先补齐二叉树遍历，再做错题复盘。',
        badge: '当前用户',
        bullets: ['空闲时间：20:00-22:00', '薄弱点：二叉树遍历、递归理解', '优势：图算法基础']
      },
      {
        title: '今日推荐任务',
        description: '复习二叉树遍历，完成 2 道同类型练习题。',
        badge: '高优先级',
        bullets: ['考试临近：5 天后', '最近错题集中在树结构', '预计投入 25 分钟']
      },
      {
        title: '两个快速入口',
        description: '演示流程中将依次进入错题分析和搭子匹配。',
        badge: '主场景',
        bullets: ['拍错题入口：识别知识点与错误类型', '找搭子入口：根据互补知识点推荐同伴']
      }
    ]
  },
  {
    title: '今日学习建议',
    subtitle: '把模糊目标拆成今晚能完成的学习动作',
    step: '2 / 6',
    primaryAction: '上传错题并分析',
    nextUrl: 'pages/WrongQuestion',
    cards: [
      {
        title: '复习二叉树遍历',
        description: '先画出前序、中序、后序遍历过程，再用递归模板写一遍。',
        badge: '25 分钟',
        bullets: ['5 分钟回顾遍历定义', '10 分钟手推 2 棵二叉树', '10 分钟完成错题订正']
      },
      {
        title: '推荐原因',
        description: '系统根据考试时间、错题集中点和可用学习时间给出优先级。',
        badge: '原因清晰',
        bullets: ['距离考试还有 5 天', '错题集中在树结构', '今晚 20:00-22:00 有连续学习时间']
      }
    ]
  },
  {
    title: '错题分析',
    subtitle: '用固定示例模拟拍照识别后的分析结果',
    step: '3 / 6',
    primaryAction: '生成学习标签',
    nextUrl: 'pages/StudyTags',
    cards: [
      {
        title: '错题缩略图',
        description: '数据结构 · binary_tree_001 · 二叉树遍历题',
        badge: '示例图片',
        bullets: ['题型：给定二叉树写出三种遍历序列', '错误答案：后序遍历节点顺序颠倒']
      },
      {
        title: '分析结果',
        description: '知识点：二叉树遍历；错误类型：递归边界理解不清。',
        badge: '待补强',
        bullets: ['原因：前序、中序、后序的访问时机混淆', '建议：先标注根节点访问位置，再补 2 道同类题']
      }
    ]
  },
  {
    title: '学习标签',
    subtitle: '把错题结果转成后续推荐和匹配可用的标签',
    step: '4 / 6',
    primaryAction: '匹配学习搭子',
    nextUrl: 'pages/PartnerMatch',
    cards: [
      {
        title: '薄弱标签',
        description: '二叉树遍历、递归调用、边界条件。',
        badge: '需要强化',
        bullets: ['先用图示理解递归栈', '再做遍历顺序口述训练', '最后完成错题二次订正']
      },
      {
        title: '可输出能力',
        description: '图算法基础较好，适合给搭子讲解路径搜索思路。',
        badge: '可互补',
        bullets: ['优势标签：图结构理解', '可帮助他人：BFS/DFS 基础题']
      }
    ]
  },
  {
    title: '搭子匹配',
    subtitle: '根据课程、目标、知识点互补和时间重合推荐同伴',
    step: '5 / 6',
    primaryAction: '查看协同计划',
    nextUrl: 'pages/StudyPlan',
    cards: [
      {
        title: '推荐搭子：小明',
        description: '匹配度 92%，同样备考数据结构，今晚 20:00 后在线。',
        badge: '92%',
        bullets: ['同为数据结构课程', '学习目标一致：期末 80+', '知识点互补：他擅长二叉树，你擅长图算法', '空闲时间重合']
      },
      {
        title: '协同建议',
        description: '用 30 分钟互讲互测，避免只看答案不复盘。',
        badge: '可执行',
        bullets: ['先互讲核心概念', '再交换错题讲解', '最后各自总结 1 条易错点']
      }
    ]
  },
  {
    title: '协同学习计划',
    subtitle: '把匹配结果落成一次可演示的学习安排',
    step: '6 / 6',
    primaryAction: '完成本轮学习',
    nextUrl: 'pages/Index',
    cards: [
      {
        title: '今晚 20:00 开始 30 分钟协同复习',
        description: '主题：二叉树遍历与图算法基础互补训练。',
        badge: '计划已生成',
        bullets: ['10 分钟：小明讲二叉树遍历顺序', '10 分钟：小知讲 DFS/BFS 思路', '5 分钟：互相讲解一道错题', '5 分钟：记录各自下一步任务']
      },
      {
        title: '本轮产出',
        description: '完成一次从建议、错题、标签、匹配到计划的完整演示闭环。',
        badge: '演示闭环',
        bullets: ['页面跳转路径固定', '每页只有一个主按钮', '后续可直接接入 B 同学服务数据']
      }
    ]
  }
];
