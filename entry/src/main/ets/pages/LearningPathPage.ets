import { LearningPath, LearningPathNode, UserProgress, DifficultyLevel, PathNodeType } from '../model/Quiz';
import { learningPathService } from '../service/LearningPathService';
import router from '@ohos.router';

@Entry
@Component
struct LearningPathPage {
  @State currentPath: LearningPath | null = null;
  @State userProgress: UserProgress | null = null;

  @State currentNode: LearningPathNode | null = null;
  @State isModuleContentVisible: boolean = false;
  @State selectedModuleId: string = '';
  @State moduleStartTime: number = 0;
  
  private pathId: string = '';

  aboutToAppear() {
    interface PathParams {
      pathId?: string;
    }
    const params = router.getParams() as PathParams | null;
    if (params && params.pathId) {
      this.pathId = params.pathId;
      this.loadLearningPath();
    }
  }

  private loadLearningPath() {
    this.currentPath = learningPathService.getLearningPathById(this.pathId);
    this.userProgress = learningPathService.getUserProgress(this.pathId);
    
    if (this.currentPath && this.userProgress) {
      this.currentNode = this.currentPath.nodes.find(n => n.id === this.userProgress!.currentNodeId) || null;
    }
  }

  private async startLearningPath() {
    try {
      this.userProgress = await learningPathService.startLearningPath(this.pathId);
      if (this.currentPath) {
        this.currentNode = this.currentPath.nodes[0];
      }
    } catch (error) {
      console.error('开始学习路径失败:', error);
    }
  }



  private async completeCurrentNode() {
    if (!this.currentNode || !this.userProgress) {
      return;
    }

    try {
      this.userProgress = await learningPathService.completeNode(
        this.pathId,
        this.currentNode.id
      );
      
      // 更新当前节点
      if (this.currentPath) {
        this.currentNode = this.currentPath.nodes.find(n => n.id === this.userProgress!.currentNodeId) || null;
      }
      
      this.isModuleContentVisible = false;
    } catch (error) {
      console.error('完成节点失败:', error);
    }
  }

  private getDifficultyColor(difficulty: DifficultyLevel): string {
    switch (difficulty) {
      case DifficultyLevel.BEGINNER:
        return '#4CAF50';
      case DifficultyLevel.INTERMEDIATE:
        return '#FF9800';
      case DifficultyLevel.ADVANCED:
        return '#F44336';
      default:
        return '#757575';
    }
  }

  private getDifficultyText(difficulty: DifficultyLevel): string {
    switch (difficulty) {
      case DifficultyLevel.BEGINNER:
        return '初级';
      case DifficultyLevel.INTERMEDIATE:
        return '中级';
      case DifficultyLevel.ADVANCED:
        return '高级';
      default:
        return '未知';
    }
  }



  private getNodeTypeText(type: PathNodeType): string {
    switch (type) {
      case PathNodeType.ARTICLE:
        return '文章';
      case PathNodeType.VIDEO:
        return '视频';
      case PathNodeType.PRACTICE:
        return '实践';
      case PathNodeType.QUIZ:
        return '测验';
      default:
        return '内容';
    }
  }



  private getNodeTypeIcon(type: PathNodeType): Resource {
    switch (type) {
      case PathNodeType.ARTICLE:
        return $r('app.media.icon_knowledge');
      case PathNodeType.VIDEO:
        return $r('app.media.icon_add');
      case PathNodeType.PRACTICE:
        return $r('app.media.icon_add');
      case PathNodeType.QUIZ:
        return $r('app.media.icon_search');
      default:
        return $r('app.media.icon_knowledge');
    }
  }

  private formatDuration(minutes: number): string {
    if (minutes < 60) {
      return `${minutes}分钟`;
    } else {
      const hours = Math.floor(minutes / 60);
      const remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? `${hours}小时${remainingMinutes}分钟` : `${hours}小时`;
    }
  }

  private goBack() {
    router.back();
  }

  private openNode(node: LearningPathNode) {
    this.currentNode = node;
    this.isModuleContentVisible = true;
  }

  private isNodeCompleted(nodeId: string): boolean {
    return this.userProgress?.completedNodes.includes(nodeId) || false;
  }

  private isNodeAccessible(node: LearningPathNode): boolean {
    if (!this.userProgress) return false;
    
    // 检查前置条件
    if (node.prerequisites && node.prerequisites.length > 0) {
      return node.prerequisites.every(prereq => 
        this.userProgress!.completedNodes.includes(prereq)
      );
    }
    
    return true;
  }

  private getNodeStatusColor(node: LearningPathNode): string {
    if (this.isNodeCompleted(node.id)) {
      return '#4CAF50'; // 绿色 - 已完成
    } else if (this.isNodeAccessible(node)) {
      return '#2196F3'; // 蓝色 - 可访问
    } else {
      return '#BDBDBD'; // 灰色 - 锁定
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())

        Text(this.currentPath?.title || '学习路径')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      if (this.isModuleContentVisible && this.currentNode) {
        // 节点内容页面
        this.NodeContentView()
      } else {
        // 学习路径概览页面
        this.LearningPathOverview()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  LearningPathOverview() {
    Column() {
      if (this.currentPath) {
        // 路径信息卡片
        Column() {
          Row() {
            Image(this.currentPath.imageUrl)
              .width(60)
              .height(60)
              .borderRadius(8)
              .margin({ right: 16 })

            Column() {
              Text(this.currentPath.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .margin({ bottom: 4 })

              Text(this.currentPath.description)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .margin({ bottom: 8 })

              Row() {
                Text(this.getDifficultyText(this.currentPath.difficulty))
                  .fontSize(12)
                  .fontColor(this.getDifficultyColor(this.currentPath.difficulty))
                  .backgroundColor(this.getDifficultyColor(this.currentPath.difficulty) + '20')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .margin({ right: 8 })

                Text(this.formatDuration(this.currentPath.estimatedDuration))
                  .fontSize(12)
                  .fontColor('#666666')
                  .backgroundColor('#F0F0F0')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ left: 16, right: 16, top: 16, bottom: 8 })

        // 进度卡片
        if (this.userProgress) {
          Column() {
            Row() {
              Text('学习进度')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text(`${this.userProgress.progressPercentage}%`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2196F3')
            }
            .width('100%')
            .margin({ bottom: 8 })

            Progress({
              value: this.userProgress.progressPercentage,
              total: 100,
              type: ProgressType.Linear
            })
              .width('100%')
              .height(6)
              .color('#2196F3')
              .backgroundColor('#E0E0E0')
              .margin({ bottom: 12 })

            Row() {
              Text(`已完成 ${this.userProgress.completedNodes.length}/${this.currentPath.nodes.length} 个节点`)
                .fontSize(14)
                .fontColor('#666666')

              Blank()

              Text(`总节点数 ${this.userProgress.totalNodes}`)
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 8 })
        }

        // 节点列表
        List() {
          ForEach(this.currentPath.nodes, (node: LearningPathNode, index: number) => {
            ListItem() {
              Row() {
                // 节点图标和状态
                Stack() {
                  Circle({ width: 40, height: 40 })
                    .fill(this.getNodeStatusColor(node))

                  if (this.isNodeCompleted(node.id)) {
                    Image($r('app.media.icon_like'))
                      .width(20)
                      .height(20)
                      .fillColor('#FFFFFF')
                  } else if (this.isNodeAccessible(node)) {
                    Image(this.getNodeTypeIcon(node.type))
                      .width(20)
                      .height(20)
                      .fillColor('#FFFFFF')
                  } else {
                    Image($r('app.media.icon_eye'))
                      .width(20)
                      .height(20)
                      .fillColor('#FFFFFF')
                  }
                }
                .margin({ right: 16 })

                // 节点信息
                Column() {
                  Row() {
                    Text(node.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .layoutWeight(1)

                    Text(this.getNodeTypeText(node.type))
                      .fontSize(12)
                      .fontColor('#666666')
                      .backgroundColor('#F0F0F0')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(8)
                  }
                  .width('100%')
                  .margin({ bottom: 4 })

                  Text(node.description)
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('100%')
                    .margin({ bottom: 8 })

                  Row() {
                    Text(`${node.duration}分钟`)
                      .fontSize(12)
                      .fontColor('#999999')

                    Text(this.getDifficultyText(node.difficulty))
                      .fontSize(12)
                      .fontColor('#F44336')
                      .margin({ left: 8 })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                // 箭头图标
                if (this.isNodeAccessible(node)) {
                  Image($r('app.media.ic_arrow_right'))
                    .width(16)
                    .height(16)
                    .fillColor('#CCCCCC')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ left: 16, right: 16, bottom: 8 })
              .onClick(() => {
                if (this.isNodeAccessible(node)) {
                  this.openNode(node);
                }
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 8, bottom: 16 })

        // 底部操作按钮
        if (!this.userProgress) {
          Button('开始学习')
            .width('calc(100% - 32vp)')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#2196F3')
            .borderRadius(8)
            .margin({ left: 16, right: 16, bottom: 16 })
            .onClick(() => this.startLearningPath())
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NodeContentView() {
    Column() {
      if (this.currentNode) {
        // 节点标题
        Column() {
          Row() {
            Button() {
              Image($r('app.media.icon_back'))
                .width(20)
                .height(20)
                .fillColor('#666666')
            }
            .width(36)
            .height(36)
            .backgroundColor(Color.Transparent)
            .onClick(() => this.isModuleContentVisible = false)

            Column() {
              Text(this.currentNode.title)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              Text(`${this.getNodeTypeText(this.currentNode.type)} · ${this.currentNode.duration}分钟`)
                .fontSize(12)
                .fontColor('#666666')
                .width('100%')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#E0E0E0' })

        // 节点内容
        Scroll() {
          Column() {
            Text(`节点类型: ${this.getNodeTypeText(this.currentNode.type)}`)
              .fontSize(16)
              .lineHeight(24)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 20 })

            Text(this.currentNode.description)
              .fontSize(16)
              .lineHeight(24)
              .fontColor('#666666')
              .width('100%')
              .margin({ bottom: 20 })

            Text(`预计学习时间: ${this.formatDuration(this.currentNode.duration)}`)
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: 20 })

            Text(`难度等级: ${this.getDifficultyText(this.currentNode.difficulty)}`)
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: 20 })
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')

        // 底部完成按钮
        Button('完成节点')
          .width('calc(100% - 32vp)')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#4CAF50')
          .borderRadius(8)
          .margin(16)
          .onClick(() => this.completeCurrentNode())
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }


}