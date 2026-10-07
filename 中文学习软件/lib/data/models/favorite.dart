import 'package:equatable/equatable.dart';

/// 收藏实体
class Favorite extends Equatable {
  final int id;
  final int characterId;
  final String collectedAt; // ISO8601格式
  final String? note; // 备注
  final List<String> tags; // 自定义标签

  const Favorite({
    required this.id,
    required this.characterId,
    required this.collectedAt,
    this.note,
    this.tags = const [],
  });

  /// 从数据库 Map 构造
  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as int,
      characterId: map['character_id'] as int,
      collectedAt: map['collected_at'] as String,
      note: map['note'] as String?,
      tags: map['tags'] != null
          ? (map['tags'] as String)
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
      'character_id': characterId,
      'collected_at': collectedAt,
      'note': note,
      'tags': tags.join(','),
    };
  }

  /// 创建副本
  Favorite copyWith({
    int? id,
    int? characterId,
    String? collectedAt,
    String? note,
    List<String>? tags,
  }) {
    return Favorite(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      collectedAt: collectedAt ?? this.collectedAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [id, characterId, collectedAt, note, tags];
}

/// 收藏统计
class FavoriteStats extends Equatable {
  final int totalCount;
  final int notLearnedCount;
  final int learningCount;
  final int masteredCount;
  final int level1Count;
  final int level2Count;
  final int level3Count;
  final int level4Count;

  const FavoriteStats({
    this.totalCount = 0,
    this.notLearnedCount = 0,
    this.learningCount = 0,
    this.masteredCount = 0,
    this.level1Count = 0,
    this.level2Count = 0,
    this.level3Count = 0,
    this.level4Count = 0,
  });

  /// 学习进度百分比
  double get masteryRate =>
      totalCount > 0 ? masteredCount / totalCount : 0.0;

  @override
  List<Object?> get props => [
        totalCount,
        notLearnedCount,
        learningCount,
        masteredCount,
        level1Count,
        level2Count,
        level3Count,
        level4Count,
      ];
}

/// 收藏排序方式
enum FavoriteSortOrder {
  /// 按收藏时间倒序（最新在前）
  collectedDesc('最新收藏'),
  /// 按收藏时间正序（最旧在前）
  collectedAsc('最早收藏'),
  /// 按拼音排序
  pinyin('按拼音'),
  /// 按难度升序（简单在前）
  levelAsc('难度低→高'),
  /// 按难度降序（难在前）
  levelDesc('难度高→低'),
  /// 按笔画数升序
  strokesAsc('笔画少→多'),
  /// 按笔画数降序
  strokesDesc('笔画多→少');

  const FavoriteSortOrder(this.label);
  final String label;
}

/// 收藏筛选条件
class FavoriteFilter extends Equatable {
  final List<int> levels; // 难度等级筛选
  final List<String> statuses; // 学习状态筛选
  final String? themeId; // 主题词场筛选
  final FavoriteSortOrder sortOrder;

  const FavoriteFilter({
    this.levels = const [],
    this.statuses = const [],
    this.themeId,
    this.sortOrder = FavoriteSortOrder.collectedDesc,
  });

  /// 是否启用了筛选
  bool get hasActiveFilter =>
      levels.isNotEmpty || statuses.isNotEmpty || themeId != null;

  /// 创建副本
  FavoriteFilter copyWith({
    List<int>? levels,
    List<String>? statuses,
    String? themeId,
    FavoriteSortOrder? sortOrder,
  }) {
    return FavoriteFilter(
      levels: levels ?? this.levels,
      statuses: statuses ?? this.statuses,
      themeId: themeId ?? this.themeId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// 重置筛选
  FavoriteFilter reset() => const FavoriteFilter();

  @override
  List<Object?> get props => [levels, statuses, themeId, sortOrder];
}
