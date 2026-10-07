import 'package:equatable/equatable.dart';

/// 主题词实体
class ThemeWord extends Equatable {
  final int id;
  final int themeId;
  final int characterId;
  final String word;
  final String? pinyin;
  final String? meaning;
  final String? exampleSentence;
  final int position;

  const ThemeWord({
    required this.id,
    required this.themeId,
    required this.characterId,
    required this.word,
    this.pinyin,
    this.meaning,
    this.exampleSentence,
    this.position = 0,
  });

  /// 从数据库 Map 构造
  factory ThemeWord.fromMap(Map<String, dynamic> map) {
    return ThemeWord(
      id: map['id'] as int,
      themeId: map['theme_id'] as int,
      characterId: map['character_id'] as int,
      word: map['word'] as String,
      pinyin: map['pinyin'] as String?,
      meaning: map['meaning'] as String?,
      exampleSentence: map['example_sentence'] as String?,
      position: map['position'] as int? ?? 0,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_id': themeId,
      'character_id': characterId,
      'word': word,
      'pinyin': pinyin,
      'meaning': meaning,
      'example_sentence': exampleSentence,
      'position': position,
    };
  }

  @override
  List<Object?> get props => [id, themeId, characterId, word];
}
