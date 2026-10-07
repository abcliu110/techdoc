import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// 部首信息实体
class Radical extends Equatable {
  /// 部首字符
  final String character;
  /// 部首名称（传统称呼）
  final String name;
  /// 部首笔画数
  final int strokes;
  /// 部首位置（left/right/top/bottom/surround）
  final String position;
  /// 简介说明
  final String description;

  const Radical({
    required this.character,
    required this.name,
    required this.strokes,
    required this.position,
    this.description = '',
  });

  @override
  List<Object?> get props => [character, name, strokes, position];
}

/// 部首分组（按笔画数）
class RadicalGroup extends Equatable {
  /// 笔画数
  final int strokes;
  /// 该笔画数下的部首列表
  final List<Radical> radicals;

  const RadicalGroup({
    required this.strokes,
    required this.radicals,
  });

  @override
  List<Object?> get props => [strokes, radicals];
}

/// 部首统计信息
class RadicalStats extends Equatable {
  /// 部首字符
  final String radical;
  /// 该部首下的汉字数量
  final int count;
  /// 示例汉字
  final List<Character> examples;

  const RadicalStats({
    required this.radical,
    required this.count,
    this.examples = const [],
  });

  @override
  List<Object?> get props => [radical, count];
}
