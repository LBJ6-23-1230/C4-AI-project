import { CourseInfo, UserProfile, WrongQuestionRecord } from '../models/AgentModels';

export const mockCurrentUser: UserProfile = {
  userId: 'u001',
  basicInfo: {
    name: '小明',
    grade: '大二',
    major: '计算机科学与技术'
  },
  learningGoal: {
    course: '数据结构',
    goal: '期末80+'
  },
  time: {
    freeTime: [
      '20:00-22:00'
    ]
  },
  knowledge: {
    weakness: [
      '二叉树遍历',
      '递归理解'
    ],
    strength: [
      '图算法'
    ]
  }
};

export const mockCourse: CourseInfo = {
  courseId: 'c001',
  courseName: '数据结构',
  exam: {
    date: '2026-07-20',
    daysLeft: 5
  },
  priority: '高',
  recentStatus: {
    studyHours: 2,
    status: '近期复习不足'
  }
};

export const mockCandidates: UserProfile[] = [
  {
    userId: 'u002',
    basicInfo: {
      name: '小红',
      grade: '大二',
      major: '计算机科学与技术'
    },
    learningGoal: {
      course: '数据结构',
      goal: '期末80+'
    },
    time: {
      freeTime: [
        '21:00-23:00'
      ]
    },
    knowledge: {
      weakness: [
        '图算法'
      ],
      strength: [
        '递归理解'
      ]
    }
  },
  {
    userId: 'u003',
    basicInfo: {
      name: '小刚',
      grade: '大二',
      major: '计算机科学与技术'
    },
    learningGoal: {
      course: '数据结构',
      goal: '期末80+'
    },
    time: {
      freeTime: [
        '19:00-20:00'
      ]
    },
    knowledge: {
      weakness: [
        '递归理解'
      ],
      strength: [
        '二叉树遍历'
      ]
    }
  }
];

export const mockWrongQuestion: WrongQuestionRecord = {
  questionId: 'q001',
  userId: 'u001',
  input: {
    image: 'img001',
    myAnswer: 'A',
    correctAnswer: 'C'
  },
  AIAnalysis: {
    course: '数据结构',
    knowledge: [
      {
        name: '二叉树遍历',
        confidence: 0.92
      }
    ],
    wrongType: '概念混淆',
    reason: '未理解中序遍历访问顺序',
    Tag: [
      '二叉树薄弱'
    ],
    suggestion: [
      {
        studyTag: '二叉树遍历',
        task: '复习二叉树的前序、中序、后序遍历方法，理解每种遍历的访问顺序和应用场景。'
      }
    ]
  }
};
