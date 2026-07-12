import {
  CourseInfo,
  OverlapResult,
  PartnerMatch,
  StudySuggestion,
  TimeRange,
  UserProfile,
  WrongAnalysisResult
} from '../models/AgentModels';

export class LocalAgentService {
  static generateStudySuggestions(user: UserProfile, course: CourseInfo): StudySuggestion {
    let score: number = 0;

    if (course.exam.daysLeft <= 7) {
      score += 50;
    }

    if (course.recentStatus.status === '近期复习不足') {
      score += 30;
    }

    if (user.knowledge.weakness.length > 0) {
      score += 20;
    }

    if (score >= 80) {
      return {
        course: course.courseName,
        task: user.knowledge.weakness[0],
        reason: '考试临近，需要优先补强薄弱知识点',
        duration: '30分钟',
        priority: '高'
      };
    }

    return {
      course: course.courseName,
      task: '正常复习',
      reason: '近期复习状态良好，无明显薄弱知识点',
      duration: '30分钟',
      priority: '中'
    };
  }

  static analyzeWrongQuestion(imageId: string): WrongAnalysisResult {
    if (imageId === 'img001') {
      return {
        course: '数据结构',
        knowledge: [
          '二叉树遍历'
        ],
        wrongType: '概念混淆',
        reason: '未理解中序遍历访问顺序',
        suggestions: [
          '复习二叉树遍历的定义和访问顺序',
          '做相关练习题巩固理解'
        ],
        tags: [
          '二叉树',
          '遍历'
        ]
      };
    }

    return {
      course: '未知',
      knowledge: [],
      wrongType: '未知',
      reason: '未知',
      suggestions: [
        '请上传正确的题目图片'
      ],
      tags: []
    };
  }

  static getOverlapScore(userTimes: string[], candidateTimes: string[]): OverlapResult {
    let maxOverlap: number = 0;
    let overlapStart: number = 0;
    let overlapEnd: number = 0;

    for (let userIndex: number = 0; userIndex < userTimes.length; userIndex++) {
      const userRange: TimeRange = LocalAgentService.parseTime(userTimes[userIndex]);

      for (let candidateIndex: number = 0; candidateIndex < candidateTimes.length; candidateIndex++) {
        const candidateRange: TimeRange = LocalAgentService.parseTime(candidateTimes[candidateIndex]);
        const overlap: number = Math.max(
          0,
          Math.min(userRange.end, candidateRange.end) - Math.max(userRange.start, candidateRange.start)
        );

        if (overlap > maxOverlap) {
          maxOverlap = overlap;
          overlapStart = Math.max(userRange.start, candidateRange.start);
          overlapEnd = Math.min(userRange.end, candidateRange.end);
        }
      }
    }

    let score: number = 0;

    if (maxOverlap >= 60) {
      score = 15;
    } else if (maxOverlap >= 30) {
      score = 10;
    } else if (maxOverlap > 0) {
      score = 5;
    }

    if (score === 0) {
      return {
        score: 0,
        start: null,
        end: null,
        duration: 0
      };
    }

    return {
      score: score,
      start: LocalAgentService.formatTime(overlapStart),
      end: LocalAgentService.formatTime(overlapEnd),
      duration: maxOverlap
    };
  }

  static matchPartner(user: UserProfile, candidate: UserProfile): PartnerMatch {
    let score: number = 0;
    const reasons: string[] = [];

    if (user.learningGoal.course.length > 0 && user.learningGoal.course === candidate.learningGoal.course) {
      score += 40;
      reasons.push('学习课程一致');
    }

    if (user.learningGoal.goal.length > 0 && user.learningGoal.goal === candidate.learningGoal.goal) {
      score += 25;
      reasons.push('学习目标一致');
    }

    const canHelpCandidate: boolean = LocalAgentService.hasCommonItem(
      user.knowledge.strength,
      candidate.knowledge.weakness
    );
    const canHelpUser: boolean = LocalAgentService.hasCommonItem(
      user.knowledge.weakness,
      candidate.knowledge.strength
    );

    if (canHelpUser && canHelpCandidate) {
      score += 20;
      reasons.push('知识能力互补');
    }

    const overlap: OverlapResult = LocalAgentService.getOverlapScore(user.time.freeTime, candidate.time.freeTime);

    if (overlap.score > 0) {
      score += overlap.score;
      reasons.push('空闲时间匹配');
    }

    let studyTime: string | null = null;

    if (overlap.start !== null && overlap.end !== null) {
      studyTime = `${overlap.start}-${overlap.end}`;
    }

    return {
      matchName: candidate.basicInfo.name,
      score: score,
      reasons: reasons,
      studyTime: studyTime,
      duration: overlap.duration
    };
  }

  static matchBestPartner(user: UserProfile, candidates: UserProfile[]): PartnerMatch | null {
    let bestMatch: PartnerMatch | null = null;
    let bestScore: number = -1;

    for (let index: number = 0; index < candidates.length; index++) {
      const result: PartnerMatch = LocalAgentService.matchPartner(user, candidates[index]);

      if (result.score > bestScore) {
        bestScore = result.score;
        bestMatch = result;
      }
    }

    return bestMatch;
  }

  private static parseTime(timeString: string): TimeRange {
    const timeParts: string[] = timeString.split('-');

    if (timeParts.length !== 2) {
      throw new Error(`时间格式错误：${timeString}`);
    }

    const startParts: string[] = timeParts[0].split(':');
    const endParts: string[] = timeParts[1].split(':');

    if (startParts.length !== 2 || endParts.length !== 2) {
      throw new Error(`时间格式错误：${timeString}`);
    }

    const startHour: number = Number(startParts[0]);
    const startMinute: number = Number(startParts[1]);
    const endHour: number = Number(endParts[0]);
    const endMinute: number = Number(endParts[1]);

    return {
      start: startHour * 60 + startMinute,
      end: endHour * 60 + endMinute
    };
  }

  private static formatTime(minutes: number): string {
    const hour: number = Math.floor(minutes / 60);
    const minute: number = minutes % 60;
    const hourText: string = hour < 10 ? `0${hour}` : hour.toString();
    const minuteText: string = minute < 10 ? `0${minute}` : minute.toString();

    return `${hourText}:${minuteText}`;
  }

  private static hasCommonItem(first: string[], second: string[]): boolean {
    for (let index: number = 0; index < first.length; index++) {
      if (second.includes(first[index])) {
        return true;
      }
    }

    return false;
  }
}
