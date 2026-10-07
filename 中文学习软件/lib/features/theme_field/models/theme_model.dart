import 'package:equatable/equatable.dart';

/// 主题分类枚举
enum ThemeCategory {
  /// 人物
  person(1, '人物'),
  /// 自然
  nature(2, '自然'),
  /// 动物
  animal(3, '动物'),
  /// 植物
  plant(4, '植物'),
  /// 食物
  food(5, '食物'),
  /// 颜色
  color(6, '颜色'),
  /// 动作
  action(7, '动作'),
  /// 情感
  emotion(8, '情感'),
  /// 时间
  time(9, '时间'),
  /// 方位
  direction(10, '方位'),
  /// 数字
  number(11, '数字'),
  /// 其他
  other(12, '其他');

  const ThemeCategory(this.code, this.label);
  final int code;
  final String label;

  static ThemeCategory? fromCode(int code) {
    return ThemeCategory.values.where((e) => e.code == code).firstOrNull;
  }

  static ThemeCategory? fromLabel(String label) {
    return ThemeCategory.values.where((e) => e.label == label).firstOrNull;
  }
}

/// 主题词场实体
class Theme extends Equatable {
  final int id;
  final String name;
  final String description;
  final ThemeCategory category;
  final String? icon;
  final int charCount;
  final int wordCount;
  final int color;
  final String? createdAt;

  const Theme({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.icon,
    this.charCount = 0,
    this.wordCount = 0,
    this.color = 0xFF6200EE,
    this.createdAt,
  });

  /// 从数据库 Map 构造
  factory Theme.fromMap(Map<String, dynamic> map) {
    return Theme(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      category: ThemeCategory.fromCode(map['category'] as int) ?? ThemeCategory.other,
      icon: map['icon'] as String?,
      charCount: map['char_count'] as int? ?? 0,
      wordCount: map['word_count'] as int? ?? 0,
      color: map['color'] as int? ?? 0xFF6200EE,
      createdAt: map['created_at'] as String?,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.code,
      'icon': icon,
      'char_count': charCount,
      'word_count': wordCount,
      'color': color,
    };
  }

  @override
  List<Object?> get props => [id, name, category];
}
