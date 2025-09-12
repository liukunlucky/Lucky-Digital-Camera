import { LearningPath, LearningPathNode, UserProgress, DifficultyLevel, PathNodeType, LEARNING_PATH_CATEGORIES } from '../model/Quiz';
import { preferences } from '@kit.ArkData';

interface UserLearningStats {
  totalPaths: number;
  completedPaths: number;
  inProgressPaths: number;
  averageCompletion: number;
}

export class LearningPathService {
  private static instance: LearningPathService;
  private learningPaths: LearningPath[] = [];
  private userProgress: UserProgress[] = [];
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() {
    this.initializeData();
  }

  public static getInstance(): LearningPathService {
    if (!LearningPathService.instance) {
      LearningPathService.instance = new LearningPathService();
    }
    return LearningPathService.instance;
  }

  // 初始化数据
  private async initializeData() {
    try {
      // 初始化preferences
      this.preferencesStore = await preferences.getPreferences(getContext(), 'learning_path_data');
      
      // 加载用户进度
      await this.loadUserProgress();
      
      // 初始化示例学习路径数据
      this.initializeSampleLearningPaths();
    } catch (error) {
      console.error('LearningPathService初始化失败:', error);
    }
  }

  // 初始化示例学习路径数据
  private initializeSampleLearningPaths() {
    this.learningPaths = [
      {
        id: 'path_001',
        title: '摄影入门完整指南',
        description: '从零开始学习摄影，掌握相机操作和基础拍摄技巧',
        category: '新手入门',
        difficulty: DifficultyLevel.BEGINNER,
        nodes: [
          {
            id: 'node_001_01',
            title: '认识你的相机',
            description: '了解相机的基本构造和各部件功能',
            type: PathNodeType.ARTICLE,
            contentId: 'article_camera_basics',
            duration: 45,
            difficulty: DifficultyLevel.BEGINNER,
            prerequisites: [],
            isCompleted: false
          },
          {
            id: 'node_001_02',
            title: '曝光三要素',
            description: '掌握光圈、快门、ISO的基本概念和关系',
            type: PathNodeType.ARTICLE,
            contentId: 'article_exposure_triangle',
            duration: 60,
            difficulty: DifficultyLevel.BEGINNER,
            prerequisites: ['node_001_01'],
            isCompleted: false
          },
          {
            id: 'node_001_03',
            title: '构图基础',
            description: '学习基本的构图法则和技巧',
            type: PathNodeType.ARTICLE,
            contentId: 'article_composition_basics',
            duration: 50,
            difficulty: DifficultyLevel.BEGINNER,
            prerequisites: ['node_001_02'],
            isCompleted: false
          },
          {
            id: 'node_001_04',
            title: '实践练习',
            description: '通过练习巩固所学知识',
            type: PathNodeType.QUIZ,
            contentId: 'quiz_beginner_practice',
            duration: 30,
            difficulty: DifficultyLevel.BEGINNER,
            prerequisites: ['node_001_03'],
            isCompleted: false
          }
        ],
        estimatedDuration: 8, // 8小时
        enrolledCount: 10,
        completionRate: 0,
        tags: ['入门', '基础', '相机操作'],
        imageUrl: 'app.media.icon_camera',
        createdAt: '2024-12-01',
        updatedAt: '2024-12-01'
      },
      {
        id: 'path_002',
        title: '人像摄影专精',
        description: '深入学习人像摄影的技巧和艺术表现',
        category: '进阶提升',
        difficulty: DifficultyLevel.INTERMEDIATE,
        nodes: [
          {
            id: 'node_002_01',
            title: '人像摄影基础',
            description: '了解人像摄影的基本要求和技巧',
            type: PathNodeType.ARTICLE,
            contentId: 'article_portrait_basics',
            duration: 60,
            difficulty: DifficultyLevel.BEGINNER,
            prerequisites: [],
            isCompleted: false
          },
          {
            id: 'node_002_02',
            title: '光线与人像',
            description: '掌握人像摄影中的光线运用技巧',
            type: PathNodeType.ARTICLE,
            contentId: 'article_portrait_lighting',
            duration: 90,
            difficulty: DifficultyLevel.INTERMEDIATE,
            prerequisites: ['node_002_01'],
            isCompleted: false
          }
        ],
        estimatedDuration: 6, // 6小时
        enrolledCount: 0,
        completionRate: 0,
        tags: ['人像', '进阶', '艺术'],
        imageUrl: 'app.media.icon_user',
        createdAt: '2024-12-01',
        updatedAt: '2024-12-01'
      }
    ];
  }

  // 获取所有学习路径
  public getAllLearningPaths(): LearningPath[] {
    return this.learningPaths;
  }

  // 根据难度获取学习路径
  public getLearningPathsByDifficulty(difficulty: DifficultyLevel): LearningPath[] {
    return this.learningPaths.filter(path => path.difficulty === difficulty);
  }

  // 根据分类获取学习路径
  public getLearningPathsByCategory(category: string): LearningPath[] {
    return this.learningPaths.filter(path => path.category === category);
  }

  // 获取单个学习路径
  public getLearningPathById(id: string): LearningPath | null {
    return this.learningPaths.find(path => path.id === id) || null;
  }

  // 获取用户在特定路径的进度
  public getUserProgress(pathId: string): UserProgress | null {
    return this.userProgress.find(progress => progress.pathId === pathId) || null;
  }

  // 开始学习路径
  public async startLearningPath(pathId: string): Promise<UserProgress> {
    const existingProgress = this.getUserProgress(pathId);
    if (existingProgress) {
      return existingProgress;
    }

    const path = this.getLearningPathById(pathId);
    if (!path) {
      throw new Error('学习路径不存在');
    }

    const newProgress: UserProgress = {
      userId: 'current_user',
      pathId: pathId,
      currentNodeId: path.nodes.length > 0 ? path.nodes[0].id : '',
      completedNodes: [],
      totalNodes: path.nodes.length,
      progressPercentage: 0,
      startedAt: new Date().toISOString(),
      lastAccessedAt: new Date().toISOString()
    };

    this.userProgress.push(newProgress);
    await this.saveUserProgress();

    return newProgress;
  }

  // 完成节点
  public async completeNode(pathId: string, nodeId: string): Promise<UserProgress> {
    const progress = this.getUserProgress(pathId);
    if (!progress) {
      throw new Error('未找到学习进度');
    }

    const path = this.getLearningPathById(pathId);
    if (!path) {
      throw new Error('学习路径不存在');
    }

    // 添加到已完成节点
    if (!progress.completedNodes.includes(nodeId)) {
      progress.completedNodes.push(nodeId);
    }

    // 计算完成百分比
    progress.progressPercentage = Math.round(
      (progress.completedNodes.length / path.nodes.length) * 100
    );

    // 更新当前节点（下一个未完成的节点）
    const nextNode = path.nodes.find(node => 
      !progress.completedNodes.includes(node.id)
    );
    
    if (nextNode) {
      progress.currentNodeId = nextNode.id;
    } else {
      // 所有节点都完成了
      progress.estimatedCompletionDate = new Date().toISOString();
    }

    progress.lastAccessedAt = new Date().toISOString();

    await this.saveUserProgress();
    return progress;
  }

  // 获取推荐的学习路径
  public getRecommendedPaths(): LearningPath[] {
    const userProgressPaths = this.userProgress.map(p => p.pathId);
    
    // 推荐未开始的初级路径
    const beginnerPaths = this.getLearningPathsByDifficulty(DifficultyLevel.BEGINNER)
      .filter(path => !userProgressPaths.includes(path.id));
    
    if (beginnerPaths.length > 0) {
      return beginnerPaths;
    }

    // 如果初级路径都完成了，推荐中级路径
    return this.getLearningPathsByDifficulty(DifficultyLevel.INTERMEDIATE)
      .filter(path => !userProgressPaths.includes(path.id));
  }

  // 获取用户学习统计
  public getUserLearningStats(): UserLearningStats {
    const totalPaths = this.userProgress.length;
    const completedPaths = this.userProgress.filter(p => p.progressPercentage === 100).length;
    const inProgressPaths = this.userProgress.filter(p => p.progressPercentage > 0 && p.progressPercentage < 100).length;
    const averageCompletion = totalPaths > 0 ? 
      this.userProgress.reduce((sum, p) => sum + p.progressPercentage, 0) / totalPaths : 0;

    return {
      totalPaths,
      completedPaths,
      inProgressPaths,
      averageCompletion: Math.round(averageCompletion)
    };
  }

  // 获取学习路径分类
  public getLearningPathCategories(): string[] {
    return LEARNING_PATH_CATEGORIES;
  }

  // 检查节点是否满足前置条件
  public checkNodePrerequisites(pathId: string, nodeId: string): boolean {
    const path = this.getLearningPathById(pathId);
    const progress = this.getUserProgress(pathId);
    
    if (!path || !progress) {
      return false;
    }

    const node = path.nodes.find(n => n.id === nodeId);
    if (!node || !node.prerequisites || node.prerequisites.length === 0) {
      return true;
    }

    return node.prerequisites.every(prereqId => 
      progress.completedNodes.includes(prereqId)
    );
  }

  // 保存用户进度到本地存储
  private async saveUserProgress() {
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.put('user_learning_progress', JSON.stringify(this.userProgress));
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('保存学习进度失败:', error);
    }
  }

  // 从本地存储加载用户进度
  private async loadUserProgress() {
    try {
      if (this.preferencesStore) {
        const progressStr = await this.preferencesStore.get('user_learning_progress', '[]') as string;
        this.userProgress = JSON.parse(progressStr);
      }
    } catch (error) {
      console.error('加载学习进度失败:', error);
      this.userProgress = [];
    }
  }

  // 重置用户数据（用于测试）
  public async resetUserData() {
    this.userProgress = [];
    await this.saveUserProgress();
  }
}

// 导出单例实例
export const learningPathService = LearningPathService.getInstance();