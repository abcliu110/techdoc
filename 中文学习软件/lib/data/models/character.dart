import 'package:equatable/equatable.dart';

/// 六书分类枚举
enum SixBook {
  /// 象形
  pictogram(1, '象形'),
  /// 指事
  indicative(2, '指事'),
  /// 会意
  associative(3, '会意'),
  /// 形声
  phonetic(4, '形声'),
  /// 转注
  mutual(5, '转注'),
  /// 假借
  phoneticLoan(6, '假借');

  const SixBook(this.code, this.label);
  final int code;
  final String label;

  static SixBook? fromCode(int code) {
    return SixBook.values.where((e) => e.code == code).firstOrNull;
  }

  static SixBook? fromLabel(String label) {
    return SixBook.values.where((e) => e.label == label).firstOrNull;
  }
}

/// 汉字实体
class Character extends Equatable {
  final int id;
  final String character;
  final String pinyin;
  final String radical;
  final int strokes;
  final int frequency;
  final SixBook? sixBook;
  final String? phonetic; // 声旁
  final String? semantic; // 形旁
  final String? originJiaguwen; // 甲骨文
  final String? originJinwen; // 金文
  final String? originXiaozhuan; // 小篆
  final String? originalMeaning; // 本义
  final List<String> extendedMeanings; // 引申义列表
  final int level; // 难度级别 1-4
  final List<String> sources; // 来源标记

  const Character({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.radical,
    required this.strokes,
    required this.frequency,
    this.sixBook,
    this.phonetic,
    this.semantic,
    this.originJiaguwen,
    this.originJinwen,
    this.originXiaozhuan,
    this.originalMeaning,
    this.extendedMeanings = const [],
    required this.level,
    this.sources = const [],
  });

  /// 从数据库 Map 构造
  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as int,
      character: map['character'] as String,
      pinyin: map['pinyin'] as String,
      radical: map['radical'] as String,
      strokes: map['strokes'] as int,
      frequency: map['frequency'] as int,
      sixBook: map['six_book'] != null
          ? SixBook.fromCode(map['six_book'] as int)
          : null,
      phonetic: map['phonetic'] as String?,
      semantic: map['semantic'] as String?,
      originJiaguwen: map['origin_jiaguwen'] as String?,
      originJinwen: map['origin_jinwen'] as String?,
      originXiaozhuan: map['origin_xiaozhuan'] as String?,
      originalMeaning: map['original_meaning'] as String?,
      extendedMeanings: map['extended_meanings'] != null
          ? (map['extended_meanings'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
      level: map['level'] as int,
      sources: map['sources'] != null
          ? (map['sources'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'pinyin': pinyin,
      'radical': radical,
      'strokes': strokes,
      'frequency': frequency,
      'six_book': sixBook?.code,
      'phonetic': phonetic,
      'semantic': semantic,
      'origin_jiaguwen': originJiaguwen,
      'origin_jinwen': originJinwen,
      'origin_xiaozhuan': originXiaozhuan,
      'original_meaning': originalMeaning,
      'extended_meanings': extendedMeanings.join(','),
      'level': level,
      'sources': sources.join(','),
    };
  }

  @override
  List<Object?> get props => [
        id,
        character,
        pinyin,
        radical,
        strokes,
        frequency,
        sixBook,
        phonetic,
        semantic,
        level,
      ];
}
