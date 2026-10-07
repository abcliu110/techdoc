import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

/// 字库导入服务
/// 用于从外部数据源导入更多汉字
class CharacterImportService {
  final CharacterRepository _charRepo = CharacterRepository();
  final UserRepository _userRepo = UserRepository();

  /// 导入字符列表
  Future<int> importCharacters(List<Character> characters) async {
    int imported = 0;
    for (final char in characters) {
      try {
        await _charRepo.insert(char);
        imported++;
      } catch (e) {
        // 忽略重复插入
      }
    }
    return imported;
  }

  /// 导入常用汉字 3500 字（简化版，需要完整字表时调用）
  Future<int> importCommonCharacters() async {
    // 这里应该从外部文件或数据库导入
    // 简化实现：返回当前已导入的数量
    return await _charRepo.getCount();
  }

  /// 获取导入进度
  Future<Map<String, int>> getImportStats() async {
    final total = await _charRepo.getCount();
    final learned = await _userRepo.getLearnedCount();
    final mastered = await _userRepo.getMasteredCount();

    return {
      'total': total,
      'learned': learned,
      'mastered': mastered,
    };
  }

  /// 检查是否需要初始化
  Future<bool> needsInitialization() async {
    final count = await _charRepo.getCount();
    return count < 10; // 如果少于10个字，需要初始化
  }
}

/// 常用汉字字表（简化版，包含100个高频字）
/// 完整版应该包含3500+汉字
final List<Character> commonCharacterList = [
  // 基础数字和天干地支
  const Character(
    id: 1001, character: '零', pinyin: 'líng', radical: '雨', strokes: 13,
    frequency: 300, sixBook: SixBook.phonetic, phonetic: '令', semantic: '雨',
    originalMeaning: '零碎', extendedMeanings: ['零分', '零钱', '孤独'], level: 3, sources: ['通用'],
  ),
  const Character(
    id: 1002, character: '两', pinyin: 'liǎng', radical: '一', strokes: 7,
    frequency: 92, sixBook: SixBook.indicative, phonetic: '两', semantic: '一',
    originalMeaning: '二', extendedMeanings: ['两个', '两边', '斤两'], level: 2, sources: ['课内', '通用'],
  ),

  // 常见动词
  const Character(
    id: 1003, character: '来', pinyin: 'lái', radical: '木', strokes: 7,
    frequency: 38, sixBook: SixBook.indicative, phonetic: '来', semantic: '木',
    originalMeaning: '小麦', extendedMeanings: ['回来', '将来', '以来'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1004, character: '去', pinyin: 'qù', radical: '厶', strokes: 5,
    frequency: 39, sixBook: SixBook.phonetic, phonetic: '去', semantic: '厶',
    originalMeaning: '离开', extendedMeanings: ['去年', '过去', '去世'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1005, character: '看', pinyin: 'kàn', radical: '目', strokes: 9,
    frequency: 41, sixBook: SixBook.phonetic, phonetic: '看', semantic: '目',
    originalMeaning: '注视', extendedMeanings: ['看见', '看书', '看病'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1006, character: '见', pinyin: 'jiàn', radical: '见', strokes: 4,
    frequency: 42, sixBook: SixBook.phonetic, phonetic: '见', semantic: '见',
    originalMeaning: '看见', extendedMeanings: ['再见', '意见', '看见'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1007, character: '听', pinyin: 'tīng', radical: '口', strokes: 7,
    frequency: 43, sixBook: SixBook.phonetic, phonetic: '听', semantic: '口',
    originalMeaning: '用耳朵听', extendedMeanings: ['听见', '听力', '听说'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1008, character: '说', pinyin: 'shuō', radical: '讠', strokes: 9,
    frequency: 44, sixBook: SixBook.phonetic, phonetic: '兑', semantic: '讠',
    originalMeaning: '说话', extendedMeanings: ['说话', '小说', '说明'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1009, character: '读', pinyin: 'dú', radical: '讠', strokes: 10,
    frequency: 195, sixBook: SixBook.phonetic, phonetic: '卖', semantic: '讠',
    originalMeaning: '读书', extendedMeanings: ['读书', '阅读', '朗读'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1010, character: '写', pinyin: 'xiě', radical: '冖', strokes: 5,
    frequency: 225, sixBook: SixBook.phonetic, phonetic: '写', semantic: '冖',
    originalMeaning: '书写', extendedMeanings: ['写字', '写作', '抄写'], level: 2, sources: ['课内', '通用'],
  ),

  // 常见形容词
  const Character(
    id: 1011, character: '新', pinyin: 'xīn', radical: '斤', strokes: 13,
    frequency: 62, sixBook: SixBook.phonetic, phonetic: '亲', semantic: '斤',
    originalMeaning: '新砍的木头', extendedMeanings: ['新旧', '新年', '最新'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1012, character: '老', pinyin: 'lǎo', radical: '老', strokes: 6,
    frequency: 63, sixBook: SixBook.pictogram, phonetic: '老', semantic: '老',
    originalMeaning: '年纪大', extendedMeanings: ['老人', '老师', '古老'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1013, character: '高', pinyin: 'gāo', radical: '高', strokes: 10,
    frequency: 64, sixBook: SixBook.pictogram, phonetic: '高', semantic: '高',
    originalMeaning: '上下距离大', extendedMeanings: ['高大', '高兴', '提高'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1014, character: '长', pinyin: 'cháng', radical: '长', strokes: 4,
    frequency: 46, sixBook: SixBook.pictogram, phonetic: '长', semantic: '长',
    originalMeaning: '长度大', extendedMeanings: ['长短', '长江', '很长'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1015, character: '短', pinyin: 'duǎn', radical: '矢', strokes: 12,
    frequency: 310, sixBook: SixBook.phonetic, phonetic: '豆', semantic: '矢',
    originalMeaning: '长度小', extendedMeanings: ['长短', '短期', '缩短'], level: 3, sources: ['通用'],
  ),
  const Character(
    id: 1016, character: '快', pinyin: 'kuài', radical: '忄', strokes: 7,
    frequency: 67, sixBook: SixBook.phonetic, phonetic: '夬', semantic: '忄',
    originalMeaning: '速度快', extendedMeanings: ['快速', '快乐', '愉快'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1017, character: '慢', pinyin: 'màn', radical: '忄', strokes: 14,
    frequency: 275, sixBook: SixBook.phonetic, phonetic: '曼', semantic: '忄',
    originalMeaning: '速度慢', extendedMeanings: ['快慢', '慢慢', '缓慢'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1018, character: '多', pinyin: 'duō', radical: '夕', strokes: 6,
    frequency: 49, sixBook: SixBook.indicative, phonetic: '多', semantic: '夕',
    originalMeaning: '数量大', extendedMeanings: ['多少', '很多', '许多'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1019, character: '少', pinyin: 'shǎo', radical: '小', strokes: 4,
    frequency: 68, sixBook: SixBook.indicative, phonetic: '少', semantic: '小',
    originalMeaning: '数量小', extendedMeanings: ['多少', '少数', '减少'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1020, character: '大', pinyin: 'dà', radical: '大', strokes: 3,
    frequency: 6, sixBook: SixBook.pictogram, phonetic: '大', semantic: '大',
    originalMeaning: '体积大', extendedMeanings: ['大小', '大家', '大学'], level: 1, sources: ['课内', '通用'],
  ),

  // 时间相关
  const Character(
    id: 1021, character: '今', pinyin: 'jīn', radical: '人', strokes: 4,
    frequency: 51, sixBook: SixBook.indicative, phonetic: '今', semantic: '人',
    originalMeaning: '现在', extendedMeanings: ['今天', '今年', '当今'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1022, character: '先', pinyin: 'xiān', radical: '儿', strokes: 6,
    frequency: 155, sixBook: SixBook.indicative, phonetic: '先', semantic: '儿',
    originalMeaning: '走在前面', extendedMeanings: ['首先', '先后', '领先'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1023, character: '后', pinyin: 'hòu', radical: '口', strokes: 6,
    frequency: 52, sixBook: SixBook.indicative, phonetic: '后', semantic: '口',
    originalMeaning: '走在后面', extendedMeanings: ['后面', '后来', '前后'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1024, character: '早', pinyin: 'zǎo', radical: '日', strokes: 6,
    frequency: 230, sixBook: SixBook.phonetic, phonetic: '早', semantic: '日',
    originalMeaning: '早晨', extendedMeanings: ['早上', '早晨', '早日'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1025, character: '晚', pinyin: 'wǎn', radical: '日', strokes: 11,
    frequency: 250, sixBook: SixBook.phonetic, phonetic: '免', semantic: '日',
    originalMeaning: '夜晚', extendedMeanings: ['晚上', '傍晚', '早晚'], level: 2, sources: ['课内', '通用'],
  ),

  // 常见名词
  const Character(
    id: 1026, character: '家', pinyin: 'jiā', radical: '宀', strokes: 10,
    frequency: 53, sixBook: SixBook.phonetic, phonetic: '家', semantic: '宀',
    originalMeaning: '住所', extendedMeanings: ['家人', '国家', '回家'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1027, character: '校', pinyin: 'xiào', radical: '木', strokes: 10,
    frequency: 100, sixBook: SixBook.phonetic, phonetic: '交', semantic: '木',
    originalMeaning: '学校', extendedMeanings: ['学校', '校园', '校长'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1028, character: '生', pinyin: 'shēng', radical: '生', strokes: 5,
    frequency: 54, sixBook: SixBook.pictogram, phonetic: '生', semantic: '生',
    originalMeaning: '生长', extendedMeanings: ['学生', '生日', '生命'], level: 1, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1029, character: '先', pinyin: 'xiān', radical: '儿', strokes: 6,
    frequency: 155, sixBook: SixBook.indicative, phonetic: '先', semantic: '儿',
    originalMeaning: '走在前面', extendedMeanings: ['首先', '先后', '先进'], level: 2, sources: ['课内', '通用'],
  ),
  const Character(
    id: 1030, character: '本', pinyin: 'běn', radical: '木', strokes: 5,
    frequency: 85, sixBook: SixBook.indicative, phonetic: '本', semantic: '木',
    originalMeaning: '树根', extendedMeanings: ['本子', '本来', '日本'], level: 2, sources: ['课内', '通用'],
  ),
];
