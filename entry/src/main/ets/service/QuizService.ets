import { Quiz, QuizQuestion, UserAnswer, QuizResult, DifficultyLevel, QuestionType, QUIZ_CATEGORIES } from '../model/Quiz';
import { preferences } from '@kit.ArkData';

interface QuizStats {
  totalQuizzes: number;
  averageScore: number;
  totalTime: number;
  bestScore: number;
  completionRate: CompletionRate;
}

interface CompletionRate {
  beginner: number;
  intermediate: number;
  advanced: number;
}

export class QuizService {
  private static instance: QuizService;
  private quizzes: Quiz[] = [];
  private userResults: QuizResult[] = [];
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() {
    this.initializeData();
  }

  public static getInstance(): QuizService {
    if (!QuizService.instance) {
      QuizService.instance = new QuizService();
    }
    return QuizService.instance;
  }

  // 初始化数据
  private async initializeData() {
    try {
      // 初始化preferences
      this.preferencesStore = await preferences.getPreferences(getContext(), 'quiz_data');
      
      // 加载用户测验结果
      await this.loadUserResults();
      
      // 初始化示例测验数据
      this.initializeSampleQuizzes();
    } catch (error) {
      console.error('QuizService初始化失败:', error);
    }
  }

  // 初始化示例测验数据
  private initializeSampleQuizzes() {
    this.quizzes = [
      {
        id: 'quiz_001',
        title: '相机基础知识测验',
        description: '测试您对相机基本概念和操作的理解程度',
        category: '相机基础',
        difficulty: DifficultyLevel.BEGINNER,
        timeLimit: 15,
        passingScore: 70,
        tags: ['基础', '入门', '相机'],
        createdAt: '2024-12-01',
        updatedAt: '2024-12-01',
        questions: [
          {
            id: 'q001',
            type: QuestionType.SINGLE_CHOICE,
            question: '以下哪个参数控制进光量的多少？',
            options: [
              { id: 'a', text: '光圈', isCorrect: true },
              { id: 'b', text: '焦距', isCorrect: false },
              { id: 'c', text: '白平衡', isCorrect: false },
              { id: 'd', text: '对焦模式', isCorrect: false }
            ],
            explanation: '光圈控制镜头的进光量大小，光圈越大（f值越小），进光量越多。',
            difficulty: DifficultyLevel.BEGINNER,
            category: '相机基础',
            tags: ['光圈', '曝光']
          },
          {
            id: 'q002',
            type: QuestionType.SINGLE_CHOICE,
            question: 'ISO感光度提高会带来什么副作用？',
            options: [
              { id: 'a', text: '画面变暗', isCorrect: false },
              { id: 'b', text: '噪点增加', isCorrect: true },
              { id: 'c', text: '色彩失真', isCorrect: false },
              { id: 'd', text: '对焦变慢', isCorrect: false }
            ],
            explanation: 'ISO感光度提高会增加画面噪点，影响画质。',
            difficulty: DifficultyLevel.BEGINNER,
            category: '相机基础',
            tags: ['ISO', '噪点']
          },
          {
            id: 'q003',
            type: QuestionType.TRUE_FALSE,
            question: '快门速度越快，拍摄的画面越亮。',
            options: [
              { id: 'true', text: '正确', isCorrect: false },
              { id: 'false', text: '错误', isCorrect: true }
            ],
            explanation: '快门速度越快，曝光时间越短，画面会越暗。',
            difficulty: DifficultyLevel.BEGINNER,
            category: '相机基础',
            tags: ['快门', '曝光']
          },
          {
            id: 'q004',
            type: QuestionType.MULTIPLE_CHOICE,
            question: '以下哪些因素会影响景深？（多选）',
            options: [
              { id: 'a', text: '光圈大小', isCorrect: true },
              { id: 'b', text: '焦距长短', isCorrect: true },
              { id: 'c', text: '拍摄距离', isCorrect: true },
              { id: 'd', text: 'ISO设置', isCorrect: false }
            ],
            explanation: '景深受光圈、焦距和拍摄距离影响，ISO不直接影响景深。',
            difficulty: DifficultyLevel.INTERMEDIATE,
            category: '相机基础',
            tags: ['景深', '光圈', '焦距']
          },
          {
            id: 'q005',
            type: QuestionType.SINGLE_CHOICE,
            question: '全画幅相机相比APS-C画幅的主要优势是？',
            options: [
              { id: 'a', text: '更轻便', isCorrect: false },
              { id: 'b', text: '更便宜', isCorrect: false },
              { id: 'c', text: '更好的高感表现', isCorrect: true },
              { id: 'd', text: '更长的焦距', isCorrect: false }
            ],
            explanation: '全画幅传感器面积更大，单个像素尺寸更大，高感表现更好。',
            difficulty: DifficultyLevel.INTERMEDIATE,
            category: '相机基础',
            tags: ['全画幅', 'APS-C', '传感器']
          }
        ]
      },
      {
        id: 'quiz_002',
        title: '镜头知识进阶测验',
        description: '深入了解镜头的特性和选择技巧',
        category: '镜头知识',
        difficulty: DifficultyLevel.INTERMEDIATE,
        timeLimit: 20,
        passingScore: 75,
        tags: ['镜头', '进阶', '选择'],
        createdAt: '2024-12-01',
        updatedAt: '2024-12-01',
        questions: [
          {
            id: 'q101',
            type: QuestionType.SINGLE_CHOICE,
            question: '85mm镜头最适合拍摄什么题材？',
            options: [
              { id: 'a', text: '风景摄影', isCorrect: false },
              { id: 'b', text: '人像摄影', isCorrect: true },
              { id: 'c', text: '建筑摄影', isCorrect: false },
              { id: 'd', text: '微距摄影', isCorrect: false }
            ],
            explanation: '85mm是经典的人像焦段，能提供自然的透视和良好的虚化效果。',
            difficulty: DifficultyLevel.INTERMEDIATE,
            category: '镜头知识',
            tags: ['85mm', '人像', '焦段']
          },
          {
            id: 'q102',
            type: QuestionType.MULTIPLE_CHOICE,
            question: '大光圈镜头的优势包括？（多选）',
            options: [
              { id: 'a', text: '更好的虚化效果', isCorrect: true },
              { id: 'b', text: '更好的弱光表现', isCorrect: true },
              { id: 'c', text: '更轻的重量', isCorrect: false },
              { id: 'd', text: '更便宜的价格', isCorrect: false }
            ],
            explanation: '大光圈能提供更好的虚化和弱光表现，但通常更重更贵。',
            difficulty: DifficultyLevel.INTERMEDIATE,
            category: '镜头知识',
            tags: ['大光圈', '虚化', '弱光']
          },
          {
            id: 'q103',
            type: QuestionType.TRUE_FALSE,
            question: '变焦镜头的画质一定比定焦镜头差。',
            options: [
              { id: 'true', text: '正确', isCorrect: false },
              { id: 'false', text: '错误', isCorrect: true }
            ],
            explanation: '现代高端变焦镜头的画质可以媲美定焦镜头，不能一概而论。',
            difficulty: DifficultyLevel.INTERMEDIATE,
            category: '镜头知识',
            tags: ['变焦', '定焦', '画质']
          }
        ]
      }
    ];
  }

  // 获取所有测验
  public getAllQuizzes(): Quiz[] {
    return this.quizzes;
  }

  // 根据难度获取测验
  public getQuizzesByDifficulty(difficulty: DifficultyLevel): Quiz[] {
    return this.quizzes.filter(quiz => quiz.difficulty === difficulty);
  }

  // 根据分类获取测验
  public getQuizzesByCategory(category: string): Quiz[] {
    return this.quizzes.filter(quiz => quiz.category === category);
  }

  // 获取单个测验
  public getQuizById(id: string): Quiz | null {
    return this.quizzes.find(quiz => quiz.id === id) || null;
  }

  // 提交测验答案
  public async submitQuizAnswers(quizId: string, answers: UserAnswer[]): Promise<QuizResult> {
    const quiz = this.getQuizById(quizId);
    if (!quiz) {
      throw new Error('测验不存在');
    }

    // 计算分数
    let correctCount = 0;
    let totalTime = 0;

    answers.forEach(answer => {
      if (answer.isCorrect) {
        correctCount++;
      }
      totalTime += answer.timeSpent;
    });

    const score = Math.round((correctCount / quiz.questions.length) * 100);

    const result: QuizResult = {
      id: `result_${Date.now()}`,
      quizId: quizId,
      userId: 'current_user', // 实际应用中应该从用户系统获取
      answers: answers,
      score: score,
      totalQuestions: quiz.questions.length,
      correctAnswers: correctCount,
      timeSpent: totalTime,
      completedAt: new Date().toISOString(),
      difficulty: quiz.difficulty
    };

    // 保存结果
    this.userResults.push(result);
    await this.saveUserResults();

    return result;
  }

  // 获取用户测验历史
  public getUserQuizHistory(): QuizResult[] {
    return this.userResults.sort((a, b) => 
      new Date(b.completedAt).getTime() - new Date(a.completedAt).getTime()
    );
  }

  // 获取用户统计信息
  public getUserStats(): QuizStats {
    const results = this.userResults;
    
    if (results.length === 0) {
      const emptyCompletionRate: CompletionRate = {
        beginner: 0,
        intermediate: 0,
        advanced: 0
      };
      const emptyStats: QuizStats = {
        totalQuizzes: 0,
        averageScore: 0,
        totalTime: 0,
        bestScore: 0,
        completionRate: emptyCompletionRate
      };
      return emptyStats;
    }

    const totalScore = results.reduce((sum, result) => sum + result.score, 0);
    const totalTime = results.reduce((sum, result) => sum + result.timeSpent, 0);
    const bestScore = Math.max(...results.map(result => result.score));

    // 计算各难度完成率
    const beginnerQuizzes = this.getQuizzesByDifficulty(DifficultyLevel.BEGINNER);
    const intermediateQuizzes = this.getQuizzesByDifficulty(DifficultyLevel.INTERMEDIATE);
    const advancedQuizzes = this.getQuizzesByDifficulty(DifficultyLevel.ADVANCED);
    
    const beginnerCompleted = results.filter(result => result.difficulty === DifficultyLevel.BEGINNER);
    const intermediateCompleted = results.filter(result => result.difficulty === DifficultyLevel.INTERMEDIATE);
    const advancedCompleted = results.filter(result => result.difficulty === DifficultyLevel.ADVANCED);
    
    const completionRate: CompletionRate = {
      beginner: beginnerQuizzes.length > 0 ? (beginnerCompleted.length / beginnerQuizzes.length) * 100 : 0,
      intermediate: intermediateQuizzes.length > 0 ? (intermediateCompleted.length / intermediateQuizzes.length) * 100 : 0,
      advanced: advancedQuizzes.length > 0 ? (advancedCompleted.length / advancedQuizzes.length) * 100 : 0
    };

    const stats: QuizStats = {
      totalQuizzes: results.length,
      averageScore: Math.round(totalScore / results.length),
      totalTime: Math.round(totalTime / 60), // 转换为分钟
      bestScore: bestScore,
      completionRate: completionRate
    };
    return stats;
  }

  // 检查答案是否正确
  public checkAnswer(questionId: string, selectedOptions: string[]): boolean {
    for (const quiz of this.quizzes) {
      const question = quiz.questions.find(q => q.id === questionId);
      if (question) {
        const correctOptions = question.options
          .filter(option => option.isCorrect)
          .map(option => option.id)
          .sort();
        
        return JSON.stringify(selectedOptions.sort()) === JSON.stringify(correctOptions);
      }
    }
    return false;
  }

  // 获取测验分类
  public getQuizCategories(): string[] {
    return QUIZ_CATEGORIES;
  }

  // 保存用户结果到本地存储
  private async saveUserResults() {
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.put('user_quiz_results', JSON.stringify(this.userResults));
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('保存测验结果失败:', error);
    }
  }

  // 从本地存储加载用户结果
  private async loadUserResults() {
    try {
      if (this.preferencesStore) {
        const resultsStr = await this.preferencesStore.get('user_quiz_results', '[]') as string;
        this.userResults = JSON.parse(resultsStr);
      }
    } catch (error) {
      console.error('加载测验结果失败:', error);
      this.userResults = [];
    }
  }

  // 重置用户数据（用于测试）
  public async resetUserData() {
    this.userResults = [];
    await this.saveUserResults();
  }
}

// 导出单例实例
export const quizService = QuizService.getInstance();