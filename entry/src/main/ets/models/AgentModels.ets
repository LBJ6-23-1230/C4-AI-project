export interface BasicInfo {
  name: string;
  grade: string;
  major: string;
}

export interface LearningGoal {
  course: string;
  goal: string;
}

export interface UserTime {
  freeTime: string[];
}

export interface KnowledgeInfo {
  weakness: string[];
  strength: string[];
}

export interface UserProfile {
  userId: string;
  basicInfo: BasicInfo;
  learningGoal: LearningGoal;
  time: UserTime;
  knowledge: KnowledgeInfo;
}

export interface ExamInfo {
  date: string;
  daysLeft: number;
}

export interface RecentStatus {
  studyHours: number;
  status: string;
}

export interface CourseInfo {
  courseId: string;
  courseName: string;
  exam: ExamInfo;
  priority: string;
  recentStatus: RecentStatus;
}

export interface KnowledgeResult {
  name: string;
  confidence: number;
}

export interface WrongQuestionSuggestion {
  studyTag: string;
  task: string;
}

export interface WrongQuestionInput {
  image: string;
  myAnswer: string;
  correctAnswer: string;
}

export interface AIAnalysis {
  course: string;
  knowledge: KnowledgeResult[];
  wrongType: string;
  reason: string;
  Tag: string[];
  suggestion: WrongQuestionSuggestion[];
}

export interface WrongQuestionRecord {
  questionId: string;
  userId: string;
  input: WrongQuestionInput;
  AIAnalysis: AIAnalysis;
}

export interface StudySuggestion {
  course: string;
  task: string;
  reason: string;
  duration: string;
  priority: string;
}

export interface WrongAnalysisResult {
  course: string;
  knowledge: string[];
  wrongType: string;
  reason: string;
  suggestions: string[];
  tags: string[];
}

export interface TimeRange {
  start: number;
  end: number;
}

export interface OverlapResult {
  score: number;
  start: string | null;
  end: string | null;
  duration: number;
}

export interface PartnerMatch {
  matchName: string;
  score: number;
  reasons: string[];
  studyTime: string | null;
  duration: number;
}
