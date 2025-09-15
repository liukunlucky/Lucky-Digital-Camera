import router from '@ohos.router';
import { Quiz, LearningPath, DifficultyLevel } from '../model/Quiz';
import { quizService } from '../service/QuizService';
import { learningPathService } from '../service/LearningPathService';

@Component
export struct SuggestionPage {
  private tabsController: TabsController = new TabsController();
  @State currentSection: string = 'suggestion'; // 'suggestion'、'encyclopedia'、'tutorial'、'quiz' 或 'learningPath'
  @State quizzes: Quiz[] = [];
  @State learningPaths: LearningPath[] = [];
  @State selectedQuizCategory: string = '全部';
  @State selectedPathCategory: string = '全部';
  @State quizCategories: string[] = ['全部'];
  @State pathCategories: string[] = ['全部'];
  @State suggestions: SuggestionItem[] = [
    {
      id: 1,
      title: '新手入门相机选择指南',
      summary: '从预算、用途、品牌等角度为新手推荐适合的入门相机',
      content: '对于刚接触摄影的新手来说，选择第一台相机是一个重要的决定。建议从以下几个方面考虑：\n\n1. 预算考虑\n入门级相机价格通常在3000-8000元之间，建议根据自己的经济能力合理规划。\n\n2. 用途分析\n- 日常记录：选择轻便的微单相机\n- 旅行摄影：考虑便携性和续航能力\n- 学习摄影：选择手动功能丰富的机型\n\n3. 品牌推荐\n- 佳能：操作简单，色彩还原好\n- 尼康：画质出色，性价比高\n- 索尼：技术先进，视频功能强\n\n4. 镜头考虑\n建议选择套机，18-55mm镜头能满足大部分拍摄需求。',
      readCount: 0,
      publishTime: '2024-12-15',
      category: '入门指南',
      tags: ['新手', '入门', '选购'],
      isHot: true
    },
    {
      id: 2,
      title: '全画幅vs半画幅选择攻略',
      summary: '详细对比全画幅和半画幅相机的优缺点，帮你做出正确选择',
      content: '全画幅和半画幅是购买相机时经常遇到的选择难题。\n\n全画幅优势：\n- 更好的高感表现\n- 更浅的景深效果\n- 更广的视角\n- 更好的画质表现\n\n半画幅优势：\n- 价格更便宜\n- 机身更轻便\n- 镜头焦距有增益效果\n- 适合长焦摄影\n\n选择建议：\n- 预算充足且追求画质：选择全画幅\n- 预算有限或注重便携：选择半画幅\n- 主要拍摄运动、野生动物：半画幅更合适',
      readCount: 0,
      publishTime: '2024-12-10',
      category: '技术对比',
      tags: ['全画幅', '半画幅', '对比'],
      isHot: true
    },
    {
      id: 3,
      title: '镜头选购完全指南',
      summary: '从焦段、光圈、品牌等维度全面解析镜头选购要点',
      content: '镜头是相机系统的重要组成部分，选择合适的镜头至关重要。\n\n按焦段分类：\n- 广角镜头(14-35mm)：适合风景、建筑摄影\n- 标准镜头(35-85mm)：适合人像、街拍\n- 长焦镜头(85mm+)：适合运动、野生动物\n\n光圈选择：\n- 大光圈(f/1.4-f/2.8)：虚化效果好，弱光表现佳\n- 小光圈(f/4-f/8)：景深大，适合风景摄影\n\n品牌推荐：\n- 原厂镜头：兼容性好，质量有保障\n- 副厂镜头：性价比高，如适马、腾龙\n\n购买建议：\n根据主要拍摄题材选择，建议先买标准变焦镜头。',
      readCount: 0,
      publishTime: '2024-12-05',
      category: '镜头指南',
      tags: ['镜头', '焦段', '光圈'],
      isHot: false
    },
    {
      id: 4,
      title: '相机保养维护小贴士',
      summary: '延长相机使用寿命的保养方法和注意事项',
      content: '正确的保养维护能让相机保持良好状态，延长使用寿命。\n\n日常保养：\n- 使用后及时清洁机身\n- 定期清理传感器\n- 镜头使用UV镜保护\n- 避免频繁更换镜头\n\n存放注意：\n- 干燥通风的环境\n- 避免高温高湿\n- 长期不用取出电池\n- 使用防潮箱或干燥剂\n\n清洁工具：\n- 气吹：清除灰尘\n- 清洁布：擦拭机身\n- 清洁液：去除顽固污渍\n- 清洁棒：清理细节部位\n\n专业维护：\n建议每年进行一次专业清洁和检测。',
      readCount: 0,
      publishTime: '2024-11-28',
      category: '保养维护',
      tags: ['保养', '维护', '清洁'],
      isHot: false
    },
    {
      id: 5,
      title: '2024年度最佳相机推荐',
      summary: '基于性能、价格、用户评价的年度最佳相机榜单',
      content: '经过全年的测试和用户反馈，我们为您推荐2024年度最佳相机。\n\n入门级最佳：\n- 佳能EOS R50：轻便易用，画质出色\n- 索尼A6100：对焦快速，视频功能强\n- 富士X-T30 II：复古外观，色彩优秀\n\n中端最佳：\n- 佳能EOS R6 Mark II：全能型选手\n- 索尼A7 IV：视频拍摄利器\n- 尼康Z6 III：性价比之王\n\n专业级最佳：\n- 佳能EOS R5：高像素高性能\n- 索尼A7R V：极致画质表现\n- 尼康Z9：运动摄影首选\n\n选择建议：\n根据预算和用途选择，建议到实体店试用后再决定。',
      readCount: 0,
      publishTime: '2024-12-20',
      category: '产品推荐',
      tags: ['2024', '推荐', '榜单'],
      isHot: true
    },
    {
      id: 6,
      title: '摄影配件选购指南',
      summary: '三脚架、滤镜、闪光灯等摄影配件的选购要点',
      content: '好的配件能让摄影创作事半功倍，以下是主要配件的选购建议。\n\n三脚架选择：\n- 碳纤维：轻便但价格高\n- 铝合金：性价比高，稍重\n- 承重要求：至少是相机+镜头重量的3倍\n\n滤镜系统：\n- UV镜：保护镜头，常备\n- 偏振镜：消除反光，增强对比\n- 中灰镜：长曝光必备\n- 渐变镜：平衡曝光差异\n\n闪光灯选择：\n- 机顶闪：便携，适合补光\n- 外置闪：功率大，可离机\n- 环形闪：微距摄影专用\n\n其他配件：\n- 相机包：保护设备\n- 存储卡：高速大容量\n- 备用电池：长时间拍摄必备\n- 清洁套装：维护设备',
      readCount: 0,
      publishTime: '2024-12-18',
      category: '配件指南',
      tags: ['配件', '三脚架', '滤镜'],
      isHot: false
    },
    {
      id: 7,
      title: '预算分配策略指南',
      summary: '如何在有限预算内合理分配相机、镜头、配件的支出',
      content: '摄影器材投资需要合理规划，以下是不同预算的分配建议。\n\n5000元预算：\n- 机身：60%（3000元）\n- 镜头：30%（1500元）\n- 配件：10%（500元）\n推荐：入门微单+套头+基础配件\n\n10000元预算：\n- 机身：50%（5000元）\n- 镜头：40%（4000元）\n- 配件：10%（1000元）\n推荐：中端机身+定焦镜头+专业配件\n\n20000元预算：\n- 机身：40%（8000元）\n- 镜头：50%（10000元）\n- 配件：10%（2000元）\n推荐：全画幅机身+多支镜头+全套配件\n\n升级策略：\n1. 先买机身和标准镜头\n2. 根据拍摄需求添加镜头\n3. 最后完善配件系统\n\n省钱技巧：\n- 关注促销活动\n- 考虑二手设备\n- 分期购买计划',
      readCount: 0,
      publishTime: '2024-12-12',
      category: '预算规划',
      tags: ['预算', '分配', '策略'],
      isHot: false
    },
    {
      id: 8,
      title: '二手相机购买攻略',
      summary: '如何安全购买二手相机，避免踩坑的实用技巧',
      content: '二手相机性价比高，但需要谨慎选择，以下是购买要点。\n\n检查要点：\n- 外观：划痕、磕碰、按键磨损\n- 屏幕：亮点、坏点、划痕\n- 快门：次数、声音、精度\n- 传感器：灰尘、坏点、污渍\n\n功能测试：\n- 对焦系统：速度、精度\n- 测光系统：准确性\n- 防抖功能：效果测试\n- 视频录制：画质、音质\n\n购买渠道：\n- 官方认证二手：有保障\n- 摄影论坛：价格透明\n- 线下实体店：可试用\n- 个人交易：价格最低但风险大\n\n注意事项：\n- 要求提供购买凭证\n- 检查保修状态\n- 议价空间评估\n- 付款方式选择\n\n避坑指南：\n- 价格过低要警惕\n- 拒绝远程交易\n- 仔细检查配件\n- 保留交易记录',
      readCount: 0,
      publishTime: '2024-12-08',
      category: '购买技巧',
      tags: ['二手', '检查', '避坑'],
      isHot: false
    },
    {
      id: 9,
      title: '微单vs单反终极对决',
      summary: '全面对比微单和单反相机的优劣势，帮你选择最适合的相机类型',
      content: '微单和单反是目前市场上的两大相机类型，各有优劣。\n\n微单相机优势：\n- 体积小巧，便于携带\n- 电子取景器实时预览\n- 视频功能更强大\n- 镜头群不断丰富\n- 对焦速度更快\n\n单反相机优势：\n- 续航能力更强\n- 光学取景器无延迟\n- 镜头选择更丰富\n- 操控手感更好\n- 价格相对便宜\n\n选择建议：\n- 注重便携性：选择微单\n- 专业摄影师：单反仍有优势\n- 视频创作者：微单更合适\n- 预算有限：单反性价比高\n\n未来趋势：\n微单正在逐步取代单反，成为市场主流。',
      readCount: 0,
      publishTime: '2024-12-22',
      category: '技术对比',
      tags: ['微单', '单反', '对比'],
      isHot: true
    },
    {
      id: 10,
      title: '摄影新手常见误区解析',
      summary: '避开这些常见误区，让你的摄影之路更加顺畅',
      content: '摄影新手在学习过程中容易陷入一些误区，了解这些有助于快速进步。\n\n器材误区：\n- 认为贵的就是好的\n- 过分追求像素数量\n- 忽视镜头的重要性\n- 频繁更换器材\n\n技术误区：\n- 只用自动模式拍摄\n- 过度依赖后期处理\n- 忽视构图的重要性\n- 不注意光线条件\n\n学习误区：\n- 只看不练习\n- 模仿而不思考\n- 急于求成\n- 不接受批评建议\n\n正确做法：\n- 先学会用好现有器材\n- 多练习基础技能\n- 培养摄影眼光\n- 持续学习和改进\n\n建议：\n摄影是一个需要时间积累的艺术，保持耐心和热情最重要。',
      readCount: 0,
      publishTime: '2024-12-25',
      category: '入门指南',
      tags: ['新手', '误区', '学习'],
      isHot: false
    },
    {
      id: 11,
      title: '存储卡选购完全攻略',
      summary: '如何选择合适的存储卡，确保拍摄数据安全可靠',
      content: '存储卡是相机的重要配件，选择合适的存储卡至关重要。\n\n存储卡类型：\n- SD卡：最常见，兼容性好\n- CF卡：专业级，速度快\n- XQD/CFexpress：新标准，性能强\n- microSD：小巧便携\n\n重要参数：\n- 容量：32GB-1TB可选\n- 速度等级：Class 10、UHS-I/II/III\n- 写入速度：影响连拍和视频\n- 读取速度：影响传输效率\n\n选择建议：\n- 日常拍摄：64GB Class 10\n- 专业摄影：128GB UHS-II\n- 4K视频：256GB UHS-III\n- 备份需求：双卡槽机型\n\n品牌推荐：\n- SanDisk：稳定可靠\n- Lexar：性价比高\n- Sony：原厂品质\n- Kingston：入门首选\n\n使用技巧：\n- 定期格式化\n- 避免满容量使用\n- 准备备用卡\n- 及时备份数据',
      readCount: 0,
      publishTime: '2024-12-20',
      category: '配件指南',
      tags: ['存储卡', 'SD卡', '选购'],
      isHot: false
    },
    {
      id: 12,
      title: '相机电池续航优化指南',
      summary: '延长相机电池使用时间的实用技巧和保养方法',
      content: '电池续航是影响拍摄体验的重要因素，掌握优化技巧很有必要。\n\n省电技巧：\n- 关闭不必要的功能\n- 降低屏幕亮度\n- 减少回放时间\n- 使用取景器而非屏幕\n- 关闭Wi-Fi和蓝牙\n\n电池保养：\n- 避免完全放电\n- 长期不用取出电池\n- 存放在干燥环境\n- 定期充放电循环\n- 避免高温环境\n\n备用方案：\n- 准备多块原装电池\n- 使用电池手柄\n- 携带移动电源\n- 车载充电器\n\n购买建议：\n- 优先选择原装电池\n- 副厂电池注意兼容性\n- 关注电池容量\n- 考虑充电速度\n\n使用注意：\n- 低温环境影响续航\n- 新电池需要激活\n- 定期检查电池健康\n- 及时更换老化电池',
      readCount: 0,
      publishTime: '2024-12-18',
      category: '保养维护',
      tags: ['电池', '续航', '保养'],
      isHot: false
    },
    {
      id: 13,
      title: '摄影包选购实用指南',
      summary: '如何选择合适的摄影包，保护你的珍贵器材',
      content: '一个好的摄影包能有效保护器材，提升拍摄体验。\n\n摄影包类型：\n- 双肩包：容量大，负重均匀\n- 单肩包：取用方便，适合街拍\n- 腰包：小巧轻便，日常携带\n- 拉杆箱：大容量，长途旅行\n- 防水包：户外拍摄必备\n\n选择要点：\n- 容量匹配器材数量\n- 分隔设计合理\n- 材质防水耐磨\n- 背负系统舒适\n- 快取设计便利\n\n品牌推荐：\n- Lowepro：专业摄影包品牌\n- Peak Design：设计感强\n- Think Tank：专业级选择\n- 国家地理：性价比高\n- Manfrotto：意大利品质\n\n使用技巧：\n- 合理分配重量\n- 定期清洁保养\n- 避免过度装载\n- 注意防盗安全\n\n购买建议：\n根据拍摄类型和器材数量选择，建议实地试背。',
      readCount: 0,
      publishTime: '2024-12-16',
      category: '配件指南',
      tags: ['摄影包', '保护', '携带'],
      isHot: false
    },
    {
      id: 14,
      title: '相机保险购买攻略',
      summary: '为你的摄影器材购买合适的保险，降低意外损失风险',
      content: '摄影器材价值不菲，购买保险能有效降低意外损失。\n\n保险类型：\n- 财产保险：覆盖盗抢、意外损坏\n- 旅行保险：出行期间器材保障\n- 专业保险：针对摄影师设计\n- 延保服务：厂商提供的延长保修\n\n保障范围：\n- 意外跌落损坏\n- 进水受潮\n- 盗抢丢失\n- 自然灾害\n- 第三方责任\n\n选择要点：\n- 保额覆盖器材价值\n- 免赔额合理\n- 理赔流程简便\n- 全球保障范围\n- 保费性价比\n\n购买渠道：\n- 保险公司官网\n- 器材商店代理\n- 专业摄影保险\n- 信用卡附加险\n\n注意事项：\n- 详细阅读条款\n- 保留购买凭证\n- 及时报案理赔\n- 定期更新保额',
      readCount: 0,
      publishTime: '2024-12-14',
      category: '购买技巧',
      tags: ['保险', '保障', '风险'],
      isHot: false
    },
    {
      id: 15,
      title: '摄影工作室搭建指南',
      summary: '从零开始搭建专业摄影工作室的完整攻略',
      content: '搭建摄影工作室需要综合考虑空间、设备、预算等因素。\n\n空间规划：\n- 面积：至少20平米\n- 层高：3米以上最佳\n- 采光：北向窗户理想\n- 通风：保持空气流通\n- 隔音：减少外界干扰\n\n基础设备：\n- 背景系统：无缝纸、布景\n- 灯光设备：主灯、辅灯、背景灯\n- 支架系统：灯架、背景架\n- 反光板：调节光线\n- 柔光设备：柔光箱、反光伞\n\n预算分配：\n- 5万元入门级工作室\n- 10万元专业级配置\n- 20万元高端工作室\n- 设备可分期购买\n\n装修要点：\n- 墙面选择中性色\n- 地面防滑耐磨\n- 电路负荷充足\n- 储物空间充裕\n\n运营建议：\n- 制定收费标准\n- 建立客户档案\n- 持续设备升级\n- 扩展服务项目',
      readCount: 0,
      publishTime: '2024-12-12',
      category: '专业进阶',
      tags: ['工作室', '搭建', '专业'],
      isHot: false
    },
    {
      id: 16,
      title: '相机固件升级指南',
      summary: '如何安全升级相机固件，获得最新功能和性能优化',
      content: '固件升级能为相机带来新功能和性能改进，但需要谨慎操作。\n\n升级前准备：\n- 查看当前固件版本\n- 确认升级必要性\n- 备份重要设置\n- 准备充足电量\n- 使用原装数据线\n\n升级步骤：\n1. 官网下载最新固件\n2. 格式化存储卡\n3. 复制固件到卡中\n4. 相机中执行升级\n5. 等待升级完成\n\n注意事项：\n- 升级过程不可中断\n- 确保电量充足\n- 使用稳定电源\n- 避免震动干扰\n- 升级后重置设置\n\n常见问题：\n- 升级失败处理\n- 功能异常排查\n- 设置重新配置\n- 兼容性问题\n\n升级建议：\n- 非必要不升级\n- 等待稳定版本\n- 关注用户反馈\n- 备份原固件\n\n厂商支持：\n各品牌都提供详细升级指南和技术支持。',
      readCount: 0,
      publishTime: '2024-12-10',
      category: '保养维护',
      tags: ['固件', '升级', '维护'],
      isHot: false
    }
  ];
  @State selectedCategory: string = '全部';
  @State searchText: string = '';
  @State categories: string[] = ['全部', '入门指南', '技术对比', '镜头指南', '保养维护', '产品推荐', '配件指南', '预算规划', '购买技巧'];
  @State filteredSuggestions: SuggestionItem[] = this.suggestions;
  @StorageProp('suggestionSwitchToTab') @Watch('onSwitchToTab') switchToTab: number = -1;

  aboutToAppear() {
    this.filterSuggestions();
    this.loadQuizzes();
    this.loadLearningPaths();
    if (this.switchToTab == 2) {
      this.currentSection = 'quiz';
      this.tabsController.changeIndex(2);
      AppStorage.setOrCreate('suggestionSwitchToTab', -1);
    }
  }

  // 监听tab切换
  onSwitchToTab() {
    if (this.switchToTab >= 0 && this.switchToTab <= 2) {
      if (this.switchToTab === 0) {
        this.currentSection = 'suggestion';
      } else if (this.switchToTab === 1) {
        this.currentSection = 'encyclopedia';
      } else if (this.switchToTab === 2) {
        this.currentSection = 'quiz';
      } else if (this.switchToTab == 3) {
        this.currentSection = 'tutorial';
      }
      this.tabsController.changeIndex(this.switchToTab);
      AppStorage.setOrCreate('suggestionSwitchToTab', -1);
    }
  }

  private loadQuizzes() {
    this.quizzes = quizService.getAllQuizzes();
    this.quizCategories = ['全部', ...quizService.getQuizCategories()];
  }

  private loadLearningPaths() {
    this.learningPaths = learningPathService.getAllLearningPaths();
    this.pathCategories = ['全部', ...learningPathService.getLearningPathCategories()];
  }

  filterSuggestions() {
    let filtered = this.suggestions;
    
    // 分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(item => item.category === this.selectedCategory);
    }
    
    // 搜索筛选
    if (this.searchText.trim() !== '') {
      const searchLower = this.searchText.toLowerCase();
      filtered = filtered.filter(item => 
        item.title.toLowerCase().includes(searchLower) ||
        item.summary.toLowerCase().includes(searchLower) ||
        item.tags.some(tag => tag.toLowerCase().includes(searchLower))
      );
    }
    
    this.filteredSuggestions = filtered;
  }

  @Builder
  TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(this.getCurrentTabIndex() === targetIndex ? 18 : 14)
        .fontWeight(this.getCurrentTabIndex() === targetIndex ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.getCurrentTabIndex() === targetIndex ? '#FF6B35' : $r('app.color.secondary_text_color'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 })
        .animation({
           duration: 150,
           curve: Curve.FastOutSlowIn
         })
      
      // 底部指示线
      Row()
        .width(this.getCurrentTabIndex() === targetIndex ? 20 : 0)
        .height(2)
        .backgroundColor('#FF6B35')
        .borderRadius(1)
        .animation({
           duration: 200,
           curve: Curve.FastOutSlowIn
         })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 6, left: 2, right: 2 })
    .backgroundColor(Color.Transparent)
  }

  getCurrentTabIndex(): number {
    if (this.currentSection === 'suggestion') {
      return 0;
    } else if (this.currentSection === 'encyclopedia') {
      return 1;
    } else if (this.currentSection === 'quiz') {
      return 2;
    } else if (this.currentSection === 'tutorial') {
      return 3;
    } else {
      return 4
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

  private formatDuration(minutes: number): string {
    if (minutes < 60) {
      return `${minutes}分钟`;
    } else {
      const hours = Math.floor(minutes / 60);
      const remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? `${hours}小时${remainingMinutes}分钟` : `${hours}小时`;
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('知识库')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.start_window_background'))
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

      // Tab导航栏
      Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
        TabContent() {
          this.SuggestionContent()
        }
        .tabBar(this.TabBuilder('指南', 0))
        
        TabContent() {
          this.EncyclopediaContent()
        }
        .tabBar(this.TabBuilder('百科', 1))
        
        TabContent() {
          this.QuizContent()
        }
        .tabBar(this.TabBuilder('测验', 2))

        TabContent() {
          this.TutorialContent()
        }
        .tabBar(this.TabBuilder('教程', 3))
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .barWidth('60%')
      .barHeight(48)
      .barBackgroundColor($r('app.color.start_window_background'))
      .animationDuration(150)
      .scrollable(true)
      .onChange((index: number) => {
        if (index === 0) {
          this.currentSection = 'suggestion';
        } else if (index === 1) {
          this.currentSection = 'encyclopedia';
        } else if (index === 2) {
          this.currentSection = 'quiz';
        } else if (index == 3) {
          this.currentSection = 'tutorial';
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SuggestionContent() {
    Column() {

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索购买建议...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.divider_color'))
          .fontSize(14)
          .onChange((value: string) => {
            this.searchText = value;
            this.filterSuggestions();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.background_color'))

      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Button(category)
              .fontSize(12)
              .fontColor(this.selectedCategory === category ? $r('app.color.surface_color') : $r('app.color.brand_color'))
              .backgroundColor(this.selectedCategory === category ? $r('app.color.brand_color') : $r('app.color.surface_color'))
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .border({
                width: 1,
                color: $r('app.color.brand_color')
              })
              .onClick(() => {
                this.selectedCategory = category;
                this.filterSuggestions();
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .backgroundColor($r('app.color.background_color'))

      // 热门推荐标签
      if (this.selectedCategory === '全部' && this.searchText === '') {
        Row() {
          Image($r('sys.symbol.flame'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.brand_color'))
            .margin({ right: 4 })
          
          Text('热门推荐')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_text_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.background_color'))
      }

      // 建议列表
      List() {
        ForEach(this.filteredSuggestions, (item: SuggestionItem) => {
          ListItem() {
            this.SuggestionCard(item)
          }
          .margin({ bottom: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SuggestionDetail',
              params: {
                suggestion: item
              }
            });
          })
        })
        
        if (this.filteredSuggestions.length === 0) {
          ListItem() {
            Column() {
              Image($r('app.media.ic_search'))
                .width(48)
                .height(48)
                .fillColor($r('app.color.tertiary_text_color'))
                .margin({ bottom: 12 })
              
              Text('暂无相关建议')
                .fontSize(16)
                .fontColor($r('app.color.secondary_text_color'))
                .margin({ bottom: 4 })
              
              Text('尝试调整搜索条件或分类筛选')
                .fontSize(12)
                .fontColor($r('app.color.tertiary_text_color'))
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  EncyclopediaContent() {
    Scroll() {
      Column() {
        this.EncyclopediaCard('相机基础知识', '了解相机的基本构造和工作原理', [
          '相机的基本组成部分包括机身、镜头、取景器、快门、光圈等。',
          '数码相机通过传感器将光信号转换为数字信号，记录图像信息。',
          '相机的核心参数包括像素、感光度(ISO)、光圈、快门速度等。'
        ])
        
        this.EncyclopediaCard('摄影术语解释', '常用摄影术语的详细解释', [
          '光圈：控制进光量的装置，用f值表示，数值越小光圈越大。',
          '快门：控制曝光时间的装置，速度越快越能凝固运动。',
          'ISO：感光度，数值越高越敏感，但噪点也会增加。',
          '景深：画面中清晰的范围，受光圈、焦距、距离影响。'
        ])
        
        this.EncyclopediaCard('相机发展历史', '从胶片到数码的相机发展历程', [
          '1839年：达盖尔发明银版摄影法，摄影术正式诞生。',
          '1888年：柯达推出第一台便携式相机，普及摄影。',
          '1975年：柯达工程师发明第一台数码相机。',
          '1990年代：数码相机开始商业化，逐步取代胶片。'
        ])
        
        this.EncyclopediaCard('镜头光学原理', '了解镜头的光学构造和成像原理', [
          '镜头由多片光学玻璃组成，通过折射聚焦光线。',
          '焦距决定视角范围，焦距越长视角越窄。',
          '光圈控制景深效果，大光圈景深浅，小光圈景深深。',
          '镜头设计需要平衡各种光学像差，追求最佳成像质量。'
        ])
        
        this.EncyclopediaCard('传感器技术', '数码相机传感器的工作原理和类型', [
          'CCD传感器：成像质量高，但功耗大，成本高。',
          'CMOS传感器：功耗低，成本低，是目前主流技术。',
          '全画幅传感器：尺寸35mm，画质最佳，价格较高。',
          'APS-C传感器：尺寸适中，性价比高，是入门首选。'
        ])
        
        this.EncyclopediaCard('色彩科学', '数码摄影中的色彩管理和处理', [
          'RGB色彩模式：通过红绿蓝三原色混合产生各种颜色。',
          '色彩空间：定义颜色范围，常见的有sRGB、Adobe RGB。',
          '白平衡：调整色温，使白色物体在不同光源下显示正确。',
          'RAW格式：保存原始数据，后期处理空间更大。'
        ])
      }
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.background_color'))
  }

  @Builder
  EncyclopediaCard(title: string, subtitle: string, content: string[]) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .width('100%')
        .margin({ bottom: 8 })
      
      Text(subtitle)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .width('100%')
        .margin({ bottom: 16 })
      
      Column() {
        ForEach(content, (item: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(14)
              .fontColor($r('app.color.brand_color'))
              .width(20)
              .margin({ right: 8 })
            
            Text(item)
              .fontSize(14)
              .fontColor($r('app.color.primary_text_color'))
              .layoutWeight(1)
              .lineHeight(20)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }

  @Builder
  SuggestionCard(suggestion: SuggestionItem) {
    Column() {
      // 顶部标签行
      Row() {
        // 分类标签
         Text(suggestion.category)
           .fontSize(10)
           .fontColor($r('app.color.tag_text_primary'))
           .backgroundColor($r('app.color.tag_background_primary'))
           .borderRadius(8)
           .padding({ left: 7, right: 7, top: 4, bottom: 4 })
        
        // 热门标签
        if (suggestion.isHot) {
          Row() {
             Image($r('app.media.icon_hot'))
               .width(10)
               .height(10)
               .fillColor($r('app.color.brand_color'))
               .margin({ right: 2 })
             
             Text('热门')
               .fontSize(10)
               .fontColor($r('app.color.tag_text_secondary'))
           }
           .backgroundColor($r('app.color.tag_background_secondary'))
           .borderRadius(8)
           .padding({ left: 7, right: 7, top: 4, bottom: 4 })
           .margin({ left: 6 })
        }
        
        Blank()
        
        Text(suggestion.publishTime)
          .fontSize(10)
          .fontColor($r('app.color.tertiary_text_color'))
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 标题
      Text(suggestion.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 8 })

      // 摘要
      Text(suggestion.summary)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 12 })

      // 标签
      if (suggestion.tags && suggestion.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, alignContent: FlexAlign.Start }) {
          ForEach(suggestion.tags.slice(0, 3), (tag: string) => {
             Text(`#${tag}`)
               .fontSize(11)
               .fontColor($r('app.color.tag_text_accent'))
               .backgroundColor($r('app.color.tag_background_accent'))
               .borderRadius(6)
               .padding({ left: 6, right: 6, top: 2, bottom: 2 })
               .margin({ right: 6, bottom: 4 })
           })
        }
        .width('100%')
        .margin({ bottom: 8 })
      }

      // 底部信息
      Row() {
        Row() {
          Image($r('app.media.icon_eye'))
            .width(12)
            .height(12)
            .fillColor($r('app.color.tertiary_text_color'))
            .margin({ right: 4 })
          
          Text(`${suggestion.readCount}`)
            .fontSize(12)
            .fontColor($r('app.color.tertiary_text_color'))
        }

        Blank()

        Row() {
           Image($r('app.media.ic_arrow_right'))
             .width(12)
             .height(12)
             .fillColor($r('app.color.brand_color'))
           
           Text('查看详情')
             .fontSize(12)
             .fontColor($r('app.color.brand_color'))
             .margin({ left: 4 })
         }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }

  @Builder
  TutorialContent() {
    TutorialContentComponent()
  }

  @Builder
  QuizContent() {
    Column() {
      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.quizCategories, (category: string) => {
            Button(category)
              .fontSize(12)
              .fontColor(this.selectedQuizCategory === category ? $r('app.color.surface_color') : $r('app.color.brand_color'))
              .backgroundColor(this.selectedQuizCategory === category ? $r('app.color.brand_color') : $r('app.color.surface_color'))
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .border({
                width: 1,
                color: $r('app.color.brand_color')
              })
              .onClick(() => {
                this.selectedQuizCategory = category;
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.background_color'))

      // 测验列表
      List() {
        ForEach(this.quizzes.filter(quiz => 
          this.selectedQuizCategory === '全部' || quiz.category === this.selectedQuizCategory
        ), (quiz: Quiz) => {
          ListItem() {
            this.QuizCard(quiz)
          }
          .margin({ bottom: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/QuizPage',
              params: {
                quiz: quiz
              }
            });
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  QuizCard(quiz: Quiz) {
    Column() {
      // 顶部信息
      Row() {
        Text(quiz.category)
          .fontSize(10)
          .fontColor($r('app.color.tag_text_primary'))
          .backgroundColor($r('app.color.tag_background_primary'))
          .borderRadius(8)
          .padding({ left: 7, right: 7, top: 4, bottom: 4 })
        
        Text(this.getDifficultyText(quiz.difficulty))
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.getDifficultyColor(quiz.difficulty))
          .borderRadius(8)
          .padding({ left: 7, right: 7, top: 4, bottom: 4 })
          .margin({ left: 6 })
        
        Blank()
        
        Text(`${quiz.questions.length}题`)
          .fontSize(10)
          .fontColor($r('app.color.tertiary_text_color'))
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 标题
      Text(quiz.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 8 })

      // 描述
      Text(quiz.description)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 12 })

      // 底部信息
      Row() {
        Row() {
          Image($r('app.media.icon_time'))
            .width(12)
            .height(12)
            .fillColor($r('app.color.tertiary_text_color'))
            .margin({ right: 4 })
          
          Text(`${quiz.timeLimit || 30}分钟`)
            .fontSize(12)
            .fontColor($r('app.color.tertiary_text_color'))
        }

        Blank()

        Row() {
          Image($r('app.media.ic_arrow_right'))
            .width(12)
            .height(12)
            .fillColor($r('app.color.brand_color'))
          
          Text('开始测验')
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
            .margin({ left: 4 })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }

  @Builder
  LearningPathContent() {
    Column() {
      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.pathCategories, (category: string) => {
            Button(category)
              .fontSize(12)
              .fontColor(this.selectedPathCategory === category ? $r('app.color.surface_color') : $r('app.color.brand_color'))
              .backgroundColor(this.selectedPathCategory === category ? $r('app.color.brand_color') : $r('app.color.surface_color'))
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .border({
                width: 1,
                color: $r('app.color.brand_color')
              })
              .onClick(() => {
                this.selectedPathCategory = category;
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.background_color'))

      // 学习路径列表
      List() {
        ForEach(this.learningPaths.filter(path => 
          this.selectedPathCategory === '全部' || path.category === this.selectedPathCategory
        ), (path: LearningPath) => {
          ListItem() {
            this.LearningPathCard(path)
          }
          .margin({ bottom: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/LearningPathPage',
              params: {
                pathId: path.id
              }
            });
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
      .backgroundColor($r('app.color.background_color'))
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  LearningPathCard(path: LearningPath) {
    Column() {
      // 顶部信息
      Row() {
        Text(path.category)
          .fontSize(10)
          .fontColor($r('app.color.tag_text_primary'))
          .backgroundColor($r('app.color.tag_background_primary'))
          .borderRadius(8)
          .padding({ left: 7, right: 7, top: 4, bottom: 4 })
        
        Text(this.getDifficultyText(path.difficulty))
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.getDifficultyColor(path.difficulty))
          .borderRadius(8)
          .padding({ left: 7, right: 7, top: 4, bottom: 4 })
          .margin({ left: 6 })
        
        Blank()
        
        Text(`${path.nodes.length}节点`)
          .fontSize(10)
          .fontColor($r('app.color.tertiary_text_color'))
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 标题
      Text(path.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 8 })

      // 描述
      Text(path.description)
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 12 })

      // 进度条
      Column() {
        Row() {
          Text('学习进度')
            .fontSize(12)
            .fontColor($r('app.color.secondary_text_color'))
          
          Blank()
          
          Text(`${Math.round(path.completionRate * 100)}%`)
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
        }
        .width('100%')
        .margin({ bottom: 4 })
        
        Progress({ value: path.completionRate * 100, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .color($r('app.color.brand_color'))
          .backgroundColor($r('app.color.background_color'))
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 底部信息
      Row() {
        Row() {
          Image($r('app.media.icon_time'))
            .width(12)
            .height(12)
            .fillColor($r('app.color.tertiary_text_color'))
            .margin({ right: 4 })
          
          Text(this.formatDuration(path.estimatedDuration))
            .fontSize(12)
            .fontColor($r('app.color.tertiary_text_color'))
        }

        Blank()

        Row() {
          Image($r('app.media.ic_arrow_right'))
            .width(12)
            .height(12)
            .fillColor($r('app.color.brand_color'))
          
          Text(path.completionRate > 0 ? '继续学习' : '开始学习')
            .fontSize(12)
            .fontColor($r('app.color.brand_color'))
            .margin({ left: 4 })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_color'))
    .borderRadius(12)
    .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
  }
}

@Component
struct TutorialContentComponent {
  @State isPlaying: boolean = false
  @State currentTime: number = 0
  @State totalTime: number = 0
  private videoController: VideoController = new VideoController();
  
  // 教程视频数据
  @State tutorials: TutorialItem[] = [
    {
      id: 1,
      title: '摄影基础教程',
      description: '本视频将为您介绍摄影的基础知识，包括相机的基本操作、构图技巧、光线运用等内容，适合摄影初学者观看学习。',
      videoSrc: 'video/video1.mp4',
      thumbnail: 'video/video1_cover.png'
    }
  ];
  
  // 格式化时间显示
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 教程列表
      List() {
        ForEach(this.tutorials, (tutorial: TutorialItem) => {
          ListItem() {
            Column() {
              // 视频标题
              Row() {
                Text(tutorial.title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              
              // 视频播放器容器
              Stack({ alignContent: Alignment.Center }) {
                Video({
                  src: $rawfile(tutorial.videoSrc),
                  previewUri: $rawfile(tutorial.thumbnail),
                  controller: this.videoController
                })
                  .width('100%')
                  .height(200)
                  .autoPlay(false)
                  .controls(false)
                  .borderRadius(8)
                  .backgroundColor($r('app.color.card_background_color'))
                  .onStart(() => {
                    this.isPlaying = true;
                  })
                  .onPause(() => {
                    this.isPlaying = false;
                  })
                  .onFinish(() => {
                    this.isPlaying = false;
                    this.currentTime = 0;
                  })
                  .onUpdate((event) => {
                    if (event) {
                      this.currentTime = event.time
                    }
                  })
                  .onPrepared((event) => {
                    if (event) {
                      this.totalTime = event.duration
                    }
                  })
                
                // 自定义播放控制按钮
                if (!this.isPlaying) {
                  Button() {
                    Image($r('app.media.ic_play'))
                      .width(24)
                      .height(24)
                      .fillColor(Color.White)
                  }
                  .width(60)
                  .height(60)
                  .backgroundColor('rgba(0, 0, 0, 0.6)')
                  .borderRadius(30)
                  .onClick(() => {
                    this.videoController.start();
                  })
                }
              }
              .width('100%')
              .onClick(() => {
                if (this.isPlaying) {
                  this.videoController.pause();
                } else {
                  this.videoController.start();
                }
              })
              
              // 播放进度条
              if (this.totalTime > 0) {
                Column() {
                  Row() {
                    Text(this.formatTime(this.currentTime))
                      .fontSize(12)
                      .fontColor($r('app.color.secondary_text_color'))
                    
                    Slider({
                      value: this.currentTime,
                      min: 0,
                      max: this.totalTime,
                      step: 1
                    })
                      .layoutWeight(1)
                      .margin({ left: 8, right: 8 })
                      .trackColor($r('app.color.background_color'))
                      .selectedColor($r('app.color.brand_color'))
                      .blockColor($r('app.color.brand_color'))
                      .onChange((value: number) => {
                        this.videoController.setCurrentTime(value);
                      })
                    
                    Text(this.formatTime(this.totalTime))
                      .fontSize(12)
                      .fontColor($r('app.color.secondary_text_color'))
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .margin({ top: 8 })
              }
              
              // 视频描述
              Text(tutorial.description)
                .fontSize(14)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ top: 12 })
                .lineHeight(20)
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.card_background_color'))
            .borderRadius(12)
            .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
          }
          .margin({ bottom: 16 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }
}

interface SuggestionItem {
  id: number;
  title: string;
  summary: string;
  content: string;
  readCount: number;
  publishTime: string;
  category: string;
  tags: string[];
  isHot: boolean;
}

interface TutorialItem {
  id: number;
  title: string;
  description: string;
  videoSrc: string;
  thumbnail: string;
}