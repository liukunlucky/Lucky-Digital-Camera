// 测验和学习路径数据模型

// 测验题目类型
export enum QuestionType {
  SINGLE_CHOICE = 'single_choice',
  MULTIPLE_CHOICE = 'multiple_choice',
  TRUE_FALSE = 'true_false',
  FILL_BLANK = 'fill_blank'
}

// 难度等级
export enum DifficultyLevel {
  BEGINNER = 'beginner',
  INTERMEDIATE = 'intermediate',
  ADVANCED = 'advanced'
}

// 测验题目选项
export interface QuestionOption {
  id: string;
  text: string;
  isCorrect: boolean;
}

// 测验题目
export interface QuizQuestion {
  id: string;
  type: QuestionType;
  question: string;
  options: QuestionOption[];
  explanation: string;
  difficulty: DifficultyLevel;
  category: string;
  tags: string[];
  imageUrl?: string;
}

// 用户答案
export interface UserAnswer {
  questionId: string;
  selectedOptions: string[];
  isCorrect: boolean;
  timeSpent: number; // 秒
}

// 测验结果
export interface QuizResult {
  id: string;
  quizId: string;
  userId: string;
  answers: UserAnswer[];
  score: number;
  totalQuestions: number;
  correctAnswers: number;
  timeSpent: number;
  completedAt: string;
  difficulty: DifficultyLevel;
}

// 测验信息
export interface Quiz {
  id: string;
  title: string;
  description: string;
  category: string;
  difficulty: DifficultyLevel;
  questions: QuizQuestion[];
  timeLimit?: number; // 分钟
  passingScore: number; // 及格分数
  tags: string[];
  imageUrl?: string;
  createdAt: string;
  updatedAt: string;
}

// 学习路径节点类型
export enum PathNodeType {
  ARTICLE = 'article',
  VIDEO = 'video',
  QUIZ = 'quiz',
  PRACTICE = 'practice'
}

// 学习路径节点
export interface LearningPathNode {
  id: string;
  title: string;
  description: string;
  type: PathNodeType;
  contentId: string; // 关联的内容ID
  duration: number; // 预计学习时间（分钟）
  difficulty: DifficultyLevel;
  prerequisites: string[]; // 前置节点ID
  isCompleted: boolean;
  completedAt?: string;
  score?: number;
}

// 学习路径
export interface LearningPath {
  id: string;
  title: string;
  description: string;
  category: string;
  difficulty: DifficultyLevel;
  nodes: LearningPathNode[];
  estimatedDuration: number; // 总预计时间（小时）
  enrolledCount: number;
  completionRate: number;
  tags: string[];
  imageUrl?: string;
  createdAt: string;
  updatedAt: string;
}

// 用户学习进度
export interface UserProgress {
  userId: string;
  pathId: string;
  currentNodeId: string;
  completedNodes: string[];
  totalNodes: number;
  progressPercentage: number;
  startedAt: string;
  lastAccessedAt: string;
  estimatedCompletionDate?: string;
}

// 学习统计
export interface LearningStats {
  userId: string;
  totalQuizzesTaken: number;
  totalCorrectAnswers: number;
  totalQuestions: number;
  averageScore: number;
  totalStudyTime: number; // 分钟
  completedPaths: number;
  currentLevel: DifficultyLevel;
  achievements: string[];
  streakDays: number;
  lastActiveDate: string;
}

// 成就系统
export interface Achievement {
  id: string;
  title: string;
  description: string;
  iconUrl: string;
  condition: string; // 达成条件描述
  points: number;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  unlockedAt?: string;
}

// 预定义的测验分类
export const QUIZ_CATEGORIES = [
  '相机基础',
  '镜头知识',
  '曝光控制',
  '构图技巧',
  '后期处理',
  '器材选购',
  '摄影理论',
  '实战技巧'
];

// 预定义的学习路径分类
export const LEARNING_PATH_CATEGORIES = [
  '新手入门',
  '进阶提升',
  '专业技能',
  '器材精通',
  '风格培养',
  '商业摄影'
];