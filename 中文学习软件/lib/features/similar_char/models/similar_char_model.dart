import 'package:equatable/equatable.dart';

/// 形近字组成员实体
class SimilarChar extends Equatable {
  /// 汉字
  final String character;

  /// 拼音
  final String pinyin;

  /// 本字解释
  final String explanation;

  /// 例词列表（最多5个常用词）
  final List<String> exampleWords;

  /// 高亮信息：描述差异位置的文字
  final String highlightInfo;

  /// 差异类型
  final String differenceType;

  const SimilarChar({
    required this.character,
    required this.pinyin,
    required this.explanation,
    this.exampleWords = const [],
    required this.highlightInfo,
    this.differenceType = '笔画差异',
  });

  factory SimilarChar.fromMap(Map<String, dynamic> map) {
    return SimilarChar(
      character: map['character'] as String,
      pinyin: map['pinyin'] as String,
      explanation: map['explanation'] as String? ?? '',
      exampleWords: map['example_words'] != null
          ? (map['example_words'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      highlightInfo: map['highlight_info'] as String? ?? '',
      differenceType: map['difference_type'] as String? ?? '笔画差异',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'character': character,
      'pinyin': pinyin,
      'explanation': explanation,
      'example_words': exampleWords.join(','),
      'highlight_info': highlightInfo,
      'difference_type': differenceType,
    };
  }

  @override
  List<Object?> get props => [character, pinyin, explanation, exampleWords, highlightInfo, differenceType];
}

/// 形近字组实体
class SimilarCharGroup extends Equatable {
  final int id;

  /// 组名称，如 "己-已-巳"
  final String groupName;

  /// 差异描述
  final String description;

  /// 组成成员
  final List<SimilarChar> chars;

  /// 难度等级：easy（简单）/ medium（中等）/ hard（困难）
  final String difficultyLevel;

  /// 分类：笔画差异 / 位置差异 / 部件差异
  final String category;

  /// 记忆口诀
  final String memoryTip;

  /// 是否已收藏
  final bool isFavorite;

  const SimilarCharGroup({
    required this.id,
    required this.groupName,
    required this.description,
    required this.chars,
    this.difficultyLevel = 'easy',
    this.category = '笔画差异',
    this.memoryTip = '',
    this.isFavorite = false,
  });

  /// 获取字符列表
  List<String> get characters => chars.map((c) => c.character).toList();

  /// 获取字符数
  int get charCount => chars.length;

  factory SimilarCharGroup.fromMap(Map<String, dynamic> map, List<SimilarChar> chars) {
    return SimilarCharGroup(
      id: map['id'] as int,
      groupName: map['group_name'] as String,
      description: map['description'] as String? ?? '',
      chars: chars,
      difficultyLevel: map['difficulty'] as String? ?? 'easy',
      category: map['category'] as String? ?? '笔画差异',
      memoryTip: map['memory_tip'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_name': groupName,
      'description': description,
      'difficulty': difficultyLevel,
      'category': category,
      'memory_tip': memoryTip,
    };
  }

  SimilarCharGroup copyWith({
    int? id,
    String? groupName,
    String? description,
    List<SimilarChar>? chars,
    String? difficultyLevel,
    String? category,
    String? memoryTip,
    bool? isFavorite,
  }) {
    return SimilarCharGroup(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      description: description ?? this.description,
      chars: chars ?? this.chars,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      category: category ?? this.category,
      memoryTip: memoryTip ?? this.memoryTip,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, groupName, description, chars, difficultyLevel, category, memoryTip, isFavorite];
}

/// 难度等级枚举
enum DifficultyLevel {
  easy('easy', '简单', '🟢'),
  medium('medium', '中等', '🟠'),
  hard('hard', '困难', '🔴');

  const DifficultyLevel(this.code, this.label, this.emoji);
  final String code;
  final String label;
  final String emoji;

  static DifficultyLevel fromCode(String code) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DifficultyLevel.easy,
    );
  }
}

/// 分类枚举
enum SimilarCategory {
  strokeDiff('笔画差异', '笔画数量或形状不同'),
  positionDiff('位置差异', '笔画位置不同'),
  componentDiff('部件差异', '部件组成不同'),
  structureDiff('结构差异', '整体结构不同');

  const SimilarCategory(this.label, this.description);
  final String label;
  final String description;

  static SimilarCategory fromLabel(String label) {
    return SimilarCategory.values.firstWhere(
      (e) => e.label == label,
      orElse: () => SimilarCategory.strokeDiff,
    );
  }
}
