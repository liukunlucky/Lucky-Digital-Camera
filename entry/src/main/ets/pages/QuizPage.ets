import router from '@ohos.router';
import { Quiz, QuizQuestion, UserAnswer, DifficultyLevel, QuestionType } from '../model/Quiz';
import { quizService } from '../service/QuizService';

interface QuizParams {
  quiz?: Quiz;
}

interface QuizOption {
  id: string;
  text: string;
  isCorrect: boolean;
}

@Entry
@Component
struct QuizPage {
  @State currentQuiz: Quiz | null = null;
  @State currentQuestionIndex: number = 0;
  @State selectedOptions: string[] = [];
  @State userAnswers: UserAnswer[] = [];
  @State timeRemaining: number = 0;
  @State isQuizStarted: boolean = false;
  @State isQuizCompleted: boolean = false;
  @State showResults: boolean = false;
  @State timer: number = -1;
  @State score: number = 0;
  @State showExplanation: boolean = false;
  private quizId: string = '';

  aboutToAppear() {
    try {
      const params = router.getParams() as QuizParams | null;
      if (params?.quiz) {
        this.currentQuiz = params.quiz;
        this.quizId = params.quiz.id;
        this.timeRemaining = (params.quiz.timeLimit || 30) * 60; // 转换为秒
      }
      
      // 确保数组初始化
      if (!this.selectedOptions) {
        this.selectedOptions = [];
      }
      if (!this.userAnswers) {
        this.userAnswers = [];
      }
    } catch (error) {
      console.error('Error in aboutToAppear:', error);
    }
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  startQuiz() {
    this.isQuizStarted = true;
    this.currentQuestionIndex = 0;
    this.userAnswers = [];
    this.selectedOptions = [];
    this.startTimer();
  }

  startTimer() {
    this.timer = setInterval(() => {
      this.timeRemaining--;
      if (this.timeRemaining <= 0) {
        this.submitQuiz();
      }
    }, 1000);
  }

  selectOption(optionId: string) {
    try {
      if (!this.currentQuiz || !this.currentQuiz.questions || this.currentQuestionIndex >= this.currentQuiz.questions.length) return;
      
      const currentQuestion = this.currentQuiz.questions[this.currentQuestionIndex];
      if (!currentQuestion || !optionId) return;
      
      // 确保selectedOptions数组已初始化
      if (!this.selectedOptions) {
        this.selectedOptions = [];
      }
      
      if (currentQuestion.type === QuestionType.SINGLE_CHOICE || currentQuestion.type === QuestionType.TRUE_FALSE) {
        this.selectedOptions = [optionId];
      } else {
        // 多选题逻辑 - 创建新数组确保状态更新
        const currentSelected = [...this.selectedOptions];
        const index = currentSelected.indexOf(optionId);
        if (index > -1) {
          // 取消选择
          currentSelected.splice(index, 1);
        } else {
          // 添加选择
          currentSelected.push(optionId);
        }
        // 强制触发状态更新
        this.selectedOptions = currentSelected;
        console.log('Updated selectedOptions:', this.selectedOptions);
      }
    } catch (error) {
      console.error('Error in selectOption:', error);
    }
  }

  nextQuestion() {
    try {
      if (!this.currentQuiz || !this.currentQuiz.questions || this.currentQuestionIndex >= this.currentQuiz.questions.length) return;
      
      // 保存当前答案
      const currentQuestion = this.currentQuiz.questions[this.currentQuestionIndex];
      if (!currentQuestion) return;
      
      // 确保数组已初始化
      if (!this.selectedOptions) {
        this.selectedOptions = [];
      }
      if (!this.userAnswers) {
        this.userAnswers = [];
      }
      
      const userAnswer: UserAnswer = {
        questionId: currentQuestion.id,
        selectedOptions: [...this.selectedOptions],
        isCorrect: this.checkAnswer(currentQuestion, this.selectedOptions),
        timeSpent: 0
      };
      this.userAnswers.push(userAnswer);
      
      // 移动到下一题
      this.selectedOptions = [];
      if (this.currentQuestionIndex < this.currentQuiz.questions.length - 1) {
        this.currentQuestionIndex++;
      } else {
        this.submitQuiz();
      }
    } catch (error) {
      console.error('Error in nextQuestion:', error);
    }
  }

  checkAnswer(question: QuizQuestion, selectedOptions: string[]): boolean {
    try {
      if (!question || !question.options || !selectedOptions) return false;
      const correctOptions = question.options.filter(opt => opt && opt.isCorrect).map(opt => opt.id);
      if (selectedOptions.length !== correctOptions.length) return false;
      return selectedOptions.every(option => correctOptions.includes(option));
    } catch (error) {
      console.error('Error in checkAnswer:', error);
      return false;
    }
  }

  submitQuiz() {
    try {
      if (this.timer !== -1) {
        clearInterval(this.timer);
      }
      
      // 确保数组已初始化
      if (!this.userAnswers) {
        this.userAnswers = [];
      }
      
      // 计算分数
      const correctAnswers = this.userAnswers.filter(answer => answer && answer.isCorrect).length;
      this.score = this.userAnswers.length > 0 ? Math.round((correctAnswers / this.userAnswers.length) * 100) : 0;
      
      // 提交到服务
      if (this.currentQuiz) {
        // quizService.submitQuizResult(this.currentQuiz.id, this.userAnswers, this.score);
      }
      
      this.isQuizCompleted = true;
      this.showResults = true;
    } catch (error) {
      console.error('Error in submitQuiz:', error);
    }
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  getDifficultyColor(difficulty: DifficultyLevel): string {
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

  getDifficultyText(difficulty: DifficultyLevel): string {
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
        .onClick(() => {
          router.back();
        })

        Text(this.currentQuiz?.title || '测验')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        if (this.isQuizStarted && !this.isQuizCompleted) {
          Text(this.formatTime(this.timeRemaining))
            .fontSize(16)
            .fontColor('#F44336')
            .width(60)
            .textAlign(TextAlign.End)
        } else {
          Blank().width(40)
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      if (this.showExplanation) {
        // 显示答题解析页面
        QuizExplanationPage({
          quiz: this.currentQuiz!,
          userAnswers: this.userAnswers,
          showExplanation: $showExplanation
        })
      } else if (!this.isQuizStarted) {
        this.QuizIntroView()
      } else if (this.showResults) {
        this.QuizResultView()
      } else {
        this.QuizQuestionView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  QuizIntroView() {
    Column() {
      if (this.currentQuiz) {
        Column() {
          // 测验信息
          Row() {
            Text(this.currentQuiz.category)
              .fontSize(12)
              .fontColor('#666666')
              .backgroundColor('#F0F0F0')
              .borderRadius(8)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            
            Text(this.getDifficultyText(this.currentQuiz.difficulty))
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor(this.getDifficultyColor(this.currentQuiz.difficulty))
              .borderRadius(8)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 16 })

          Text(this.currentQuiz.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .margin({ bottom: 8 })

          Text(this.currentQuiz.description)
            .fontSize(16)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 24 })

          // 测验统计
          Row() {
            Column() {
              Text(this.currentQuiz.questions.length.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.brand_color'))
              Text('题目数量')
                .fontSize(12)
                .fontColor('#666666')
            }
            .layoutWeight(1)

            Column() {
              Text(`${this.currentQuiz.timeLimit}分钟`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.brand_color'))
              Text('时间限制')
                .fontSize(12)
                .fontColor('#666666')
            }
            .layoutWeight(1)

            Column() {
              Text(`${this.currentQuiz.timeLimit || 30}分钟`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2196F3')
              Text('预计用时')
                .fontSize(12)
                .fontColor('#666666')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 32 })

          Button('开始测验')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.brand_color'))
            .borderRadius(8)
            .onClick(() => this.startQuiz())
        }
        .width('100%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin(16)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  QuizQuestionView() {
    Column() {
      if (this.currentQuiz && this.currentQuestionIndex < this.currentQuiz.questions.length) {
        // 当前问题
        
        // 进度条
        Column() {
          Row() {
            Text(`第 ${this.currentQuestionIndex + 1} 题`)
              .fontSize(14)
              .fontColor('#666666')
            
            Blank()
            
            Text(`${this.currentQuestionIndex + 1}/${this.currentQuiz.questions.length}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Progress({ 
            value: this.currentQuestionIndex + 1, 
            total: this.currentQuiz.questions.length, 
            type: ProgressType.Linear 
          })
            .width('100%')
            .height(4)
            .color($r('app.color.brand_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 8 })

        // 题目内容
        Column() {
          Text(this.currentQuiz?.questions?.[this.currentQuestionIndex]?.question || '')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .margin({ bottom: 24 })

          // 选项列表
          ForEach(this.currentQuiz?.questions?.[this.currentQuestionIndex]?.options || [], (option: QuizOption) => {
            if (option && option.id) {
              Row() {
              if (this.currentQuiz?.questions?.[this.currentQuestionIndex]?.type === QuestionType.SINGLE_CHOICE || 
                  this.currentQuiz?.questions?.[this.currentQuestionIndex]?.type === QuestionType.TRUE_FALSE) {
                Radio({ value: option.id, group: 'question' })
                  .checked(this.selectedOptions.includes(option.id))
                  .onChange((isChecked: boolean) => {
                    if (isChecked && option?.id) {
                      this.selectOption(option.id);
                    }
                  })
                  .margin({ right: 12 })
              } else {
                Checkbox()
                  .select(this.selectedOptions.includes(option.id))
                  .onChange((isChecked: boolean) => {
                    if (option?.id) {
                      this.selectOption(option.id);
                    }
                  })
                  .margin({ right: 12 })
              }

              Text(option.text)
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.selectedOptions.includes(option.id) ? '#E3F2FD' : '#FFFFFF')
            .borderRadius(8)
            .border({ 
              width: 1, 
              color: this.selectedOptions.includes(option.id) ? $r('app.color.brand_color') : '#E0E0E0' 
            })
            .margin({ bottom: 12 })
            .onClick(() => {
              if (option?.id) {
                // 对于单选题和判断题，点击整行可以选择
                if (this.currentQuiz?.questions?.[this.currentQuestionIndex]?.type === QuestionType.SINGLE_CHOICE || 
                    this.currentQuiz?.questions?.[this.currentQuestionIndex]?.type === QuestionType.TRUE_FALSE) {
                  this.selectOption(option.id);
                }
                // 多选题不处理Row点击，避免与Checkbox冲突
              }
            })
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ bottom: 16 })

        // 底部按钮
        Row() {
          Button(this.currentQuestionIndex === (this.currentQuiz?.questions?.length || 0) - 1 ? '提交答案' : '下一题')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor(this.selectedOptions.length > 0 ? $r('app.color.brand_color') : '#CCCCCC')
            .borderRadius(8)
            .enabled(this.selectedOptions.length > 0)
            .onClick(() => {
              this.nextQuestion();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  QuizResultView() {
    Column() {
      Column() {
        // 分数显示
        Text(this.score.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.score >= 80 ? '#4CAF50' : this.score >= 60 ? '#FF9800' : '#F44336')
          .margin({ bottom: 8 })
        
        Text('分')
          .fontSize(20)
          .fontColor('#666666')
          .margin({ bottom: 16 })
        
        Text(this.score >= 80 ? '优秀！' : this.score >= 60 ? '良好' : '需要加强')
          .fontSize(18)
          .fontColor('#333333')
          .margin({ bottom: 24 })
        
        // 统计信息
        Row() {
          Column() {
            Text(this.userAnswers.filter(a => a.isCorrect).length.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
            Text('正确')
              .fontSize(12)
              .fontColor('#666666')
          }
          .layoutWeight(1)
          
          Column() {
            Text(this.userAnswers.filter(a => !a.isCorrect).length.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F44336')
            Text('错误')
              .fontSize(12)
              .fontColor('#666666')
          }
          .layoutWeight(1)
          
          Column() {
            Text(this.userAnswers.length.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2196F3')
            Text('总题数')
              .fontSize(12)
              .fontColor('#666666')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 32 })
        
        // 操作按钮
        Column() {
          Button('查看解析')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor($r('app.color.brand_color'))
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: $r('app.color.brand_color') })
            .borderRadius(8)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.showExplanation = true;
            })
          
          Button('重新测验')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor($r('app.color.brand_color'))
            .borderRadius(8)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.isQuizStarted = false;
              this.isQuizCompleted = false;
              this.showResults = false;
              this.currentQuestionIndex = 0;
              this.selectedOptions = [];
              this.userAnswers = [];
              if (this.currentQuiz) {
                this.timeRemaining = (this.currentQuiz.timeLimit || 30) * 60;
              }
            })
          
          Button('返回')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin(16)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct QuizExplanationPage {
  @Prop quiz: Quiz;
  @Prop userAnswers: UserAnswer[];
  @Link showExplanation: boolean;

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
        .onClick(() => {
          this.showExplanation = false;
        })

        Text('答案解析')
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

      // 解析列表
      List() {
        ForEach(this.quiz.questions, (question: QuizQuestion, index: number) => {
          ListItem() {
            Column() {
              // 题目
              Text(`${index + 1}. ${question.question}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')
                .margin({ bottom: 12 })

              // 用户答案和正确答案
              if (this.userAnswers.find(ua => ua.questionId === question.id)) {
                Row() {
                  Text('您的答案：')
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text(this.userAnswers.find(ua => ua.questionId === question.id)?.selectedOptions.map(optionId => 
                    question.options.find(opt => opt.id === optionId)?.text || ''
                  ).join(', ') || '')
                    .fontSize(14)
                    .fontColor(this.userAnswers.find(ua => ua.questionId === question.id)?.isCorrect ? '#4CAF50' : '#F44336')
                }
                .width('100%')
                .margin({ bottom: 8 })
              }

              Row() {
                Text('正确答案：')
                  .fontSize(14)
                  .fontColor('#666666')
                
                Text(question.options.filter(opt => opt.isCorrect).map(opt => opt.text).join(', '))
                  .fontSize(14)
                  .fontColor('#4CAF50')
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 解析
              if (question.explanation) {
                Text('解析：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .width('100%')
                  .margin({ bottom: 4 })
                
                Text(question.explanation)
                  .fontSize(14)
                  .fontColor('#666666')
                  .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 12 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}