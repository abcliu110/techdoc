import '../models/similar_char_model.dart';

/// 预定义的高频形近字组数据
/// 这些数据覆盖了最常见的、易混淆的形近字
class SimilarCharData {
  /// 获取所有预定义形近字组
  static List<SimilarCharGroup> getAllGroups() {
    return [
      _group1_JiYiSi,
      _group2_TuShi,
      _group3_DaTaiQuan,
      _group4_RiYueBai,
      _group5_RenRu,
      _group6_GanQianYu,
      _group7_DaoLiRen,
      _group8_LeZi,
      _group9_JiEr,
      _group10_ChangGuang,
      _group11_BuShang,
      _group12_YiCha,
      _group13_WuNiao,
      _group14_WuYi,
      _group15_JinChi,
      _group16_ZhaoGua,
      _group17_ShuZhong,
      _group18_WaWan,
      _group19_ZhiZhengZu,
      _group20_LunCang,
      _group21_HouHou,
      _group22_CiLa,
      _group23_DuiShuo,
      _group24_MoWei,
      _group25_ShiLi,
      _group26_YuWang,
      _group27_ShuCi,
      _group28_ChuiShui,
      _group29_MangHuang,
      _group30_XiangHeng,
    ];
  }

  /// 获取高频易混字组（按难度筛选）
  static List<SimilarCharGroup> getByDifficulty(String difficulty) {
    return getAllGroups().where((g) => g.difficultyLevel == difficulty).toList();
  }

  /// 获取指定分类的字组
  static List<SimilarCharGroup> getByCategory(String category) {
    return getAllGroups().where((g) => g.category == category).toList();
  }

  /// 根据ID获取字组
  static SimilarCharGroup? getById(int id) {
    try {
      return getAllGroups().firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 搜索形近字组
  static List<SimilarCharGroup> search(String keyword) {
    final kw = keyword.toLowerCase();
    return getAllGroups().where((g) {
      // 匹配组名
      if (g.groupName.toLowerCase().contains(kw)) return true;
      // 匹配字符
      if (g.characters.any((c) => c.contains(kw))) return true;
      // 匹配描述
      if (g.description.toLowerCase().contains(kw)) return true;
      return false;
    }).toList();
  }

  // ========== 20组高频形近字定义 ==========

  /// 1. 己-已-巳
  static final _group1_JiYiSi = SimilarCharGroup(
    id: 1,
    groupName: '己-已-巳',
    description: '三个字的口字框开口方向不同',
    chars: [
      SimilarChar(
        character: '己',
        pinyin: 'jǐ',
        explanation: '第一人称代词，自己',
        exampleWords: ['自己', '己所不欲', '克己奉公', '损己利人'],
        highlightInfo: '口字框完全开口，竖笔不出头',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '已',
        pinyin: 'yǐ',
        explanation: '副词，表示动作完成或停止',
        exampleWords: ['已经', '早已', '不能自己', '已而'],
        highlightInfo: '口字框半开口，竖笔出半头',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '巳',
        pinyin: 'sì',
        explanation: '地支第六位，用于计时',
        exampleWords: ['巳时', '巳年', '子丑寅卯辰巳'],
        highlightInfo: '口字框完全闭合，竖笔全包',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '己开口，已半封，巳全封',
  );

  /// 2. 土-士
  static final _group2_TuShi = SimilarCharGroup(
    id: 2,
    groupName: '土-士',
    description: '最后一笔横的长短不同',
    chars: [
      SimilarChar(
        character: '土',
        pinyin: 'tǔ',
        explanation: '泥土，土地',
        exampleWords: ['土地', '泥土', '国土', '土壤'],
        highlightInfo: '最后一横较长，横贯字身',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '士',
        pinyin: 'shì',
        explanation: '士兵，读书人',
        exampleWords: ['士兵', '博士', '勇士', '女士'],
        highlightInfo: '最后一横较短，不超过上方',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '土横长，士横短',
  );

  /// 3. 大-太-犬
  static final _group3_DaTaiQuan = SimilarCharGroup(
    id: 3,
    groupName: '大-太-犬',
    description: '中间笔画变化：大无点，太有点，犬有点和撇',
    chars: [
      SimilarChar(
        character: '大',
        pinyin: 'dà',
        explanation: '形容体积、面积、数量大',
        exampleWords: ['大小', '大家', '大人', '大学'],
        highlightInfo: '无点，撇捺对称',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '太',
        pinyin: 'tài',
        explanation: '程度过头，高、大',
        exampleWords: ['太阳', '太空', '太好了', '太后'],
        highlightInfo: '有点，捺带点',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '犬',
        pinyin: 'quǎn',
        explanation: '狗，犬类动物',
        exampleWords: ['犬类', '军犬', '犬马之劳', '丧家之犬'],
        highlightInfo: '有点和长撇，像狗的尾巴',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '大无点，太有点，犬有点撇',
  );

  /// 4. 日-曰-白
  static final _group4_RiYueBai = SimilarCharGroup(
    id: 4,
    groupName: '日-曰-白',
    description: '形状相似，内部线条数量不同',
    chars: [
      SimilarChar(
        character: '日',
        pinyin: 'rì',
        explanation: '太阳，白天',
        exampleWords: ['日子', '生日', '日记', '日光'],
        highlightInfo: '内部一横',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '曰',
        pinyin: 'yuē',
        explanation: '说',
        exampleWords: ['子曰', '曰若', '名曰'],
        highlightInfo: '内部两横，口形略扁',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '白',
        pinyin: 'bái',
        explanation: '白色，像雪的颜色',
        exampleWords: ['白色', '明白', '白天', '雪白'],
        highlightInfo: '有撇，内部两横',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '部件差异',
    memoryTip: '日一横，曰两横，白有撇',
  );

  /// 5. 人-入
  static final _group5_RenRu = SimilarCharGroup(
    id: 5,
    groupName: '人-入',
    description: '笔画方向相反',
    chars: [
      SimilarChar(
        character: '人',
        pinyin: 'rén',
        explanation: '人类',
        exampleWords: ['人民', '人们', '别人', '大人'],
        highlightInfo: '撇向左伸展',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '入',
        pinyin: 'rù',
        explanation: '进入',
        exampleWords: ['进入', '入口', '出入', '收入'],
        highlightInfo: '撇向右插入',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '人撇向左，入撇向右',
  );

  /// 6. 干-千-于
  static final _group6_GanQianYu = SimilarCharGroup(
    id: 6,
    groupName: '干-千-于',
    description: '笔画数量和位置不同',
    chars: [
      SimilarChar(
        character: '干',
        pinyin: 'gān',
        explanation: '干燥，做事',
        exampleWords: ['干净', '干活', '干涉', '外强中干'],
        highlightInfo: '十加二，无撇',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '千',
        pinyin: 'qiān',
        explanation: '数目字',
        exampleWords: ['千万', '千米', '千千万万', '千里迢迢'],
        highlightInfo: '十加撇，横上出头',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '于',
        pinyin: 'yú',
        explanation: '介词，表示方向',
        exampleWords: ['于是', '等于', '至于', '对于'],
        highlightInfo: '十加弯钩',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '干无撇，千有撇，于有弯钩',
  );

  /// 7. 刀-力-刃
  static final _group7_DaoLiRen = SimilarCharGroup(
    id: 7,
    groupName: '刀-力-刃',
    description: '刀的开口方向不同',
    chars: [
      SimilarChar(
        character: '刀',
        pinyin: 'dāo',
        explanation: '刀具',
        exampleWords: ['小刀', '水果刀', '刀刃', '菜刀'],
        highlightInfo: '开口向左',
        differenceType: '位置差异',
      ),
      SimilarChar(
        character: '力',
        pinyin: 'lì',
        explanation: '力量',
        exampleWords: ['努力', '力量', '能力', '动力'],
        highlightInfo: '开口向右',
        differenceType: '位置差异',
      ),
      SimilarChar(
        character: '刃',
        pinyin: 'rèn',
        explanation: '刀刃',
        exampleWords: ['刀刃', '刃口', '迎刃而解'],
        highlightInfo: '力加一点',
        differenceType: '部件差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '位置差异',
    memoryTip: '刀左开，力右开，刃有点',
  );

  /// 8. 了-子
  static final _group8_LeZi = SimilarCharGroup(
    id: 8,
    groupName: '了-子',
    description: '笔画差异',
    chars: [
      SimilarChar(
        character: '了',
        pinyin: 'le',
        explanation: '助词或动词',
        exampleWords: ['好了', '看了', '走了', '了解'],
        highlightInfo: '无横',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '子',
        pinyin: 'zǐ',
        explanation: '儿子，种子',
        exampleWords: ['孩子', '儿子', '子孙', '孔子'],
        highlightInfo: '有横',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '了无横，子有横',
  );

  /// 9. 几-儿
  static final _group9_JiEr = SimilarCharGroup(
    id: 9,
    groupName: '几-儿',
    description: '底部是否有钩',
    chars: [
      SimilarChar(
        character: '几',
        pinyin: 'jǐ',
        explanation: '小桌子，询问数量',
        exampleWords: ['几个', '几乎', '茶几', '几时'],
        highlightInfo: '底部无钩',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '儿',
        pinyin: 'ér',
        explanation: '儿子',
        exampleWords: ['儿童', '儿子', '婴儿', '花儿'],
        highlightInfo: '底部有钩',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '几无钩，儿有钩',
  );

  /// 10. 厂-广
  static final _group10_ChangGuang = SimilarCharGroup(
    id: 10,
    groupName: '厂-广',
    description: '笔画差异',
    chars: [
      SimilarChar(
        character: '厂',
        pinyin: 'chǎng',
        explanation: '工厂',
        exampleWords: ['工厂', '厂房', '厂商', '煤厂'],
        highlightInfo: '无点',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '广',
        pinyin: 'guǎng',
        explanation: '广阔，广大',
        exampleWords: ['广东', '广大', '广播', '宽广'],
        highlightInfo: '有点',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '厂无点，广有点',
  );

  /// 11. 卜-上
  static final _group11_BuShang = SimilarCharGroup(
    id: 11,
    groupName: '卜-上',
    description: '方向和位置不同',
    chars: [
      SimilarChar(
        character: '卜',
        pinyin: 'bo',
        explanation: '占卜',
        exampleWords: ['萝卜', '占卜', '卜卦'],
        highlightInfo: '竖笔向左下',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '上',
        pinyin: 'shàng',
        explanation: '上面',
        exampleWords: ['上面', '上学', '上班', '上海'],
        highlightInfo: '竖笔垂直',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '卜向左，上垂直',
  );

  /// 12. 义-叉
  static final _group12_YiCha = SimilarCharGroup(
    id: 12,
    groupName: '义-叉',
    description: '笔画交叉位置不同',
    chars: [
      SimilarChar(
        character: '义',
        pinyin: 'yì',
        explanation: '正义，意义',
        exampleWords: ['主义', '正义', '意义', '义不容辞'],
        highlightInfo: '点在上方',
        differenceType: '位置差异',
      ),
      SimilarChar(
        character: '叉',
        pinyin: 'chā',
        explanation: '叉子，交叉',
        exampleWords: ['交叉', '叉子', '刀叉', '叉腰'],
        highlightInfo: '交叉在下方',
        differenceType: '位置差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '位置差异',
    memoryTip: '义点在上，叉交叉在下',
  );

  /// 13. 乌-鸟
  static final _group13_WuNiao = SimilarCharGroup(
    id: 13,
    groupName: '乌-鸟',
    description: '是否有一点',
    chars: [
      SimilarChar(
        character: '乌',
        pinyin: 'wū',
        explanation: '乌鸦，黑色',
        exampleWords: ['乌鸦', '乌云', '乌黑', '乌龙茶'],
        highlightInfo: '无点',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '鸟',
        pinyin: 'niǎo',
        explanation: '鸟类动物',
        exampleWords: ['小鸟', '鸟类', '飞鸟', '鸟鸣'],
        highlightInfo: '有一点',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '乌无点，鸟有点',
  );

  /// 14. 勿-易
  static final _group14_WuYi = SimilarCharGroup(
    id: 14,
    groupName: '勿-易',
    description: '笔画数量不同',
    chars: [
      SimilarChar(
        character: '勿',
        pinyin: 'wù',
        explanation: '不要',
        exampleWords: ['不要', '请勿', '勿忘', '万勿'],
        highlightInfo: '多一撇',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '易',
        pinyin: 'yì',
        explanation: '容易，改变',
        exampleWords: ['容易', '交易', '简易', '不易'],
        highlightInfo: '无撇',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '笔画差异',
    memoryTip: '勿多一撇，易少一撇',
  );

  /// 15. 斤-斥
  static final _group15_JinChi = SimilarCharGroup(
    id: 15,
    groupName: '斤-斥',
    description: '是否有一点',
    chars: [
      SimilarChar(
        character: '斤',
        pinyin: 'jīn',
        explanation: '重量单位',
        exampleWords: ['公斤', '一斤', '斧斤', '斤斤计较'],
        highlightInfo: '无点',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '斥',
        pinyin: 'chì',
        explanation: '责备',
        exampleWords: ['排斥', '斥责', '充斥', '驳斥'],
        highlightInfo: '有一点',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '笔画差异',
    memoryTip: '斤无点，斥有点',
  );

  /// 16. 爪-瓜
  static final _group16_ZhaoGua = SimilarCharGroup(
    id: 16,
    groupName: '爪-瓜',
    description: '笔画形状不同',
    chars: [
      SimilarChar(
        character: '爪',
        pinyin: 'zhǎo',
        explanation: '爪子',
        exampleWords: ['爪子', '鸡爪', '爪牙', '一爪'],
        highlightInfo: '爪形，撇向下',
        differenceType: '结构差异',
      ),
      SimilarChar(
        character: '瓜',
        pinyin: 'guā',
        explanation: '瓜类',
        exampleWords: ['冬瓜', '西瓜', '瓜分', '傻瓜'],
        highlightInfo: '有瓜瓣结构',
        differenceType: '结构差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '结构差异',
    memoryTip: '爪撇向下，瓜有瓜瓣',
  );

  /// 17. 殳-夂
  static final _group17_ShuZhong = SimilarCharGroup(
    id: 17,
    groupName: '殳-夂',
    description: '笔画数量不同',
    chars: [
      SimilarChar(
        character: '殳',
        pinyin: 'shū',
        explanation: '古代兵器',
        exampleWords: ['敲门', '族殳'],
        highlightInfo: '横较多',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '夂',
        pinyin: 'zhōng',
        explanation: '从后面到来',
        exampleWords: ['夂差', '降夂'],
        highlightInfo: '横较少',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'hard',
    category: '笔画差异',
    memoryTip: '殳横多，夂横少',
  );

  /// 18. 瓦-丸
  static final _group18_WaWan = SimilarCharGroup(
    id: 18,
    groupName: '瓦-丸',
    description: '是否有点',
    chars: [
      SimilarChar(
        character: '瓦',
        pinyin: 'wǎ',
        explanation: '瓦片',
        exampleWords: ['瓦片', '瓦特', '瓦解', '砖瓦'],
        highlightInfo: '有点',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '丸',
        pinyin: 'wán',
        explanation: '丸子，药丸',
        exampleWords: ['药丸', '丸子', '丸剂', '肉丸'],
        highlightInfo: '无点',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '笔画差异',
    memoryTip: '瓦有点，丸无点',
  );

  /// 19. 止-正-足
  static final _group19_ZhiZhengZu = SimilarCharGroup(
    id: 19,
    groupName: '止-正-足',
    description: '笔画递增',
    chars: [
      SimilarChar(
        character: '止',
        pinyin: 'zhǐ',
        explanation: '停止',
        exampleWords: ['停止', '止步', '禁止', '为止'],
        highlightInfo: '一脚',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '正',
        pinyin: 'zhèng',
        explanation: '正确',
        exampleWords: ['正确', '正面', '正在', '正是'],
        highlightInfo: '两口',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '足',
        pinyin: 'zú',
        explanation: '脚',
        exampleWords: ['手足', '足球', '满足', '足球队'],
        highlightInfo: '三口',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '止一脚，正两口，足三口',
  );

  /// 20. 仑-仓
  static final _group20_LunCang = SimilarCharGroup(
    id: 20,
    groupName: '仑-仓',
    description: '是否有人字头',
    chars: [
      SimilarChar(
        character: '仑',
        pinyin: 'lún',
        explanation: '条理',
        exampleWords: ['昆仑', '仑理', '加仑'],
        highlightInfo: '无人字头',
        differenceType: '部件差异',
      ),
      SimilarChar(
        character: '仓',
        pinyin: 'cāng',
        explanation: '仓库',
        exampleWords: ['仓库', '仓位', '粮仓', '仓储'],
        highlightInfo: '有人字头',
        differenceType: '部件差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '部件差异',
    memoryTip: '仑无人，仓有人',
  );

  /// 21. 侯-候
  static final _group21_HouHou = SimilarCharGroup(
    id: 21,
    groupName: '侯-候',
    description: '中间竖是否出头',
    chars: [
      SimilarChar(
        character: '侯',
        pinyin: 'hóu',
        explanation: '古代爵位',
        exampleWords: ['诸侯', '侯爵', '侯门'],
        highlightInfo: '中间竖不出头',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '候',
        pinyin: 'hòu',
        explanation: '等待',
        exampleWords: ['时候', '等候', '问候', '候选人'],
        highlightInfo: '中间竖出头',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '笔画差异',
    memoryTip: '侯竖不出头，候竖出头',
  );

  /// 22. 刺-剌
  static final _group22_CiLa = SimilarCharGroup(
    id: 22,
    groupName: '刺-剌',
    description: '刀的位置不同',
    chars: [
      SimilarChar(
        character: '刺',
        pinyin: 'cì',
        explanation: '刺杀，刺激',
        exampleWords: ['刺杀', '刺激', '刺客', '讽刺'],
        highlightInfo: '刀在左边',
        differenceType: '部件差异',
      ),
      SimilarChar(
        character: '剌',
        pinyin: 'là',
        explanation: '乖剌',
        exampleWords: ['乖剌', '剌戾'],
        highlightInfo: '刀在下方',
        differenceType: '部件差异',
      ),
    ],
    difficultyLevel: 'hard',
    category: '部件差异',
    memoryTip: '刺刀左，剌刀下',
  );

  /// 23. 兑-说
  static final _group23_DuiShuo = SimilarCharGroup(
    id: 23,
    groupName: '兑-说',
    description: '换偏旁区别',
    chars: [
      SimilarChar(
        character: '兑',
        pinyin: 'duì',
        explanation: '兑换',
        exampleWords: ['兑换', '汇兑', '兑现', '兑付'],
        highlightInfo: '无言字旁',
        differenceType: '部件差异',
      ),
      SimilarChar(
        character: '说',
        pinyin: 'shuō',
        explanation: '说话',
        exampleWords: ['说话', '小说', '说明', '听说'],
        highlightInfo: '有言字旁',
        differenceType: '部件差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '部件差异',
    memoryTip: '兑无言旁，说有言旁',
  );

  /// 24. 末-未
  static final _group24_MoWei = SimilarCharGroup(
    id: 24,
    groupName: '末-未',
    description: '长横和短横位置不同',
    chars: [
      SimilarChar(
        character: '末',
        pinyin: 'mò',
        explanation: '末端',
        exampleWords: ['末尾', '周末', '末日', '本末倒置'],
        highlightInfo: '长横在上',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '未',
        pinyin: 'wèi',
        explanation: '没有，不曾',
        exampleWords: ['未来', '未曾', '未必', '未知'],
        highlightInfo: '长横在下',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '末长横在上，未长横在下',
  );

  /// 25. 史-吏
  static final _group25_ShiLi = SimilarCharGroup(
    id: 25,
    groupName: '史-吏',
    description: '口的位置不同',
    chars: [
      SimilarChar(
        character: '史',
        pinyin: 'shǐ',
        explanation: '历史',
        exampleWords: ['历史', '史书', '史无前例', '史学家'],
        highlightInfo: '口偏下',
        differenceType: '位置差异',
      ),
      SimilarChar(
        character: '吏',
        pinyin: 'lì',
        explanation: '官员',
        exampleWords: ['官吏', '酷吏', '墨吏'],
        highlightInfo: '口在中间',
        differenceType: '位置差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '位置差异',
    memoryTip: '史口下，吏口中',
  );

  /// 26. 玉-王
  static final _group26_YuWang = SimilarCharGroup(
    id: 26,
    groupName: '玉-王',
    description: '是否有点',
    chars: [
      SimilarChar(
        character: '玉',
        pinyin: 'yù',
        explanation: '玉石',
        exampleWords: ['玉石', '玉石', '玉米', '玉器'],
        highlightInfo: '有点',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '王',
        pinyin: 'wáng',
        explanation: '国王',
        exampleWords: ['王子', '国王', '大王', '女王'],
        highlightInfo: '无点',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '笔画差异',
    memoryTip: '玉有点，王无点',
  );

  /// 27. 束-剌
  static final _group27_ShuCi = SimilarCharGroup(
    id: 27,
    groupName: '束-剌',
    description: '竖是否出头',
    chars: [
      SimilarChar(
        character: '束',
        pinyin: 'shù',
        explanation: '束缚',
        exampleWords: ['束缚', '结束', '束手无策', '花束'],
        highlightInfo: '竖不出头',
        differenceType: '笔画差异',
      ),
      SimilarChar(
        character: '剌',
        pinyin: 'là',
        explanation: '乖剌',
        exampleWords: ['乖剌', '剌戾', '剌谬'],
        highlightInfo: '竖出头',
        differenceType: '笔画差异',
      ),
    ],
    difficultyLevel: 'hard',
    category: '笔画差异',
    memoryTip: '束竖不出头，剌竖出头',
  );

  /// 28. 垂-睡
  static final _group28_ChuiShui = SimilarCharGroup(
    id: 28,
    groupName: '垂-睡',
    description: '偏旁不同',
    chars: [
      SimilarChar(
        character: '垂',
        pinyin: 'chuí',
        explanation: '下垂',
        exampleWords: ['垂直', '垂钓', '下垂', '垂头丧气'],
        highlightInfo: '无目旁',
        differenceType: '部件差异',
      ),
      SimilarChar(
        character: '睡',
        pinyin: 'shuì',
        explanation: '睡觉',
        exampleWords: ['睡觉', '睡眠', '午睡', '睡意'],
        highlightInfo: '有目旁',
        differenceType: '部件差异',
      ),
    ],
    difficultyLevel: 'easy',
    category: '部件差异',
    memoryTip: '垂无目旁，睡有目旁',
  );

  /// 29. 盲-肓
  static final _group29_MangHuang = SimilarCharGroup(
    id: 29,
    groupName: '盲-肓',
    description: '目字位置不同',
    chars: [
      SimilarChar(
        character: '盲',
        pinyin: 'máng',
        explanation: '失明',
        exampleWords: ['盲目', '盲人', '文盲', '盲从'],
        highlightInfo: '目在上',
        differenceType: '位置差异',
      ),
      SimilarChar(
        character: '肓',
        pinyin: 'huāng',
        explanation: '膏肓',
        exampleWords: ['膏肓', '病入膏肓'],
        highlightInfo: '目在下',
        differenceType: '位置差异',
      ),
    ],
    difficultyLevel: 'hard',
    category: '位置差异',
    memoryTip: '盲目在上，肓目在下',
  );

  /// 30. 享-亨
  static final _group30_XiangHeng = SimilarCharGroup(
    id: 30,
    groupName: '享-亨',
    description: '笔画差异',
    chars: [
      SimilarChar(
        character: '享',
        pinyin: 'xiǎng',
        explanation: '享受',
        exampleWords: ['享受', '享福', '享乐', '分享'],
        highlightInfo: '子字底',
        differenceType: '部件差异',
      ),
      SimilarChar(
        character: '亨',
        pinyin: 'hēng',
        explanation: '顺利',
        exampleWords: ['大亨', '亨通', '亨利', '万事亨通'],
        highlightInfo: '竖弯钩',
        differenceType: '部件差异',
      ),
    ],
    difficultyLevel: 'medium',
    category: '部件差异',
    memoryTip: '享有子底，亨有弯钩',
  );
}
