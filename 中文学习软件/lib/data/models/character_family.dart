import 'package:equatable/equatable.dart';

/// 字族实体（按声旁分类）
class CharacterFamily extends Equatable {
  final int id;
  final String phoneticChar; // 声旁字
  final String phoneticPinyin; // 声旁读音
  final String phoneticConsistency; // 读音一致性：高/中/低
  final String? note; // 说明

  const CharacterFamily({
    required this.id,
    required this.phoneticChar,
    required this.phoneticPinyin,
    required this.phoneticConsistency,
    this.note,
  });

  /// 从数据库 Map 构造
  factory CharacterFamily.fromMap(Map<String, dynamic> map) {
    return CharacterFamily(
      id: map['id'] as int,
      phoneticChar: map['phonetic_char'] as String,
      phoneticPinyin: map['phonetic_pinyin'] as String? ?? '',
      phoneticConsistency: map['phonetic_consistency'] as String? ?? '中',
      note: map['note'] as String?,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phonetic_char': phoneticChar,
      'phonetic_pinyin': phoneticPinyin,
      'phonetic_consistency': phoneticConsistency,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [id, phoneticChar, phoneticPinyin, phoneticConsistency, note];
}

/// 字族成员（关联表）
class FamilyMember extends Equatable {
  final int id;
  final int familyId;
  final int characterId;
  final int position; // 在字族中的位置

  const FamilyMember({
    required this.id,
    required this.familyId,
    required this.characterId,
    required this.position,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as int,
      familyId: map['family_id'] as int,
      characterId: map['character_id'] as int,
      position: map['position'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'family_id': familyId,
      'character_id': characterId,
      'position': position,
    };
  }

  @override
  List<Object?> get props => [id, familyId, characterId, position];
}
