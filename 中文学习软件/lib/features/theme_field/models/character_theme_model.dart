import 'package:equatable/equatable.dart';

/// 主题-汉字关联实体
class CharacterTheme extends Equatable {
  final int id;
  final int themeId;
  final int characterId;
  final int position;

  const CharacterTheme({
    required this.id,
    required this.themeId,
    required this.characterId,
    this.position = 0,
  });

  /// 从数据库 Map 构造
  factory CharacterTheme.fromMap(Map<String, dynamic> map) {
    return CharacterTheme(
      id: map['id'] as int,
      themeId: map['theme_id'] as int,
      characterId: map['character_id'] as int,
      position: map['position'] as int? ?? 0,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_id': themeId,
      'character_id': characterId,
      'position': position,
    };
  }

  @override
  List<Object?> get props => [id, themeId, characterId];
}
