import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/models.dart';

/// 收藏数据仓库
class FavoriteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 检查汉字是否已收藏
  Future<bool> isFavorited(int characterId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'favorites',
      where: 'character_id = ?',
      whereArgs: [characterId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// 添加收藏
  Future<int> addFavorite(int characterId, {String? note, List<String>? tags}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert(
      'favorites',
      {
        'character_id': characterId,
        'collected_at': now,
        'note': note,
        'tags': tags?.join(',') ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id;
  }

  /// 取消收藏
  Future<void> removeFavorite(int characterId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'favorites',
      where: 'character_id = ?',
      whereArgs: [characterId],
    );
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(int characterId) async {
    final isFav = await isFavorited(characterId);
    if (isFav) {
      await removeFavorite(characterId);
      return false;
    } else {
      await addFavorite(characterId);
      return true;
    }
  }

  /// 获取所有收藏
  Future<List<Favorite>> getAllFavorites() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'favorites',
      orderBy: 'collected_at DESC',
    );
    return maps.map((m) => Favorite.fromMap(m)).toList();
  }

  /// 获取收藏的汉字ID列表
  Future<List<int>> getFavoriteCharacterIds() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'favorites',
      columns: ['character_id'],
      orderBy: 'collected_at DESC',
    );
    return maps.map((m) => m['character_id'] as int).toList();
  }

  /// 获取收藏的汉字列表（带Character信息）
  Future<List<Character>> getFavoriteCharacters({FavoriteFilter? filter}) async {
    final db = await _dbHelper.database;

    // 构建查询
    String sql = '''
      SELECT c.*, f.collected_at, f.note, f.tags,
             COALESCE(up.status, 0) as learn_status
      FROM characters c
      INNER JOIN favorites f ON c.id = f.character_id
      LEFT JOIN user_progress up ON c.id = up.character_id
    ''';

    List<dynamic> whereArgs = [];
    List<String> whereClauses = [];

    // 难度筛选
    if (filter != null && filter.levels.isNotEmpty) {
      final placeholders = filter.levels.map((_) => '?').join(',');
      whereClauses.add('c.level IN ($placeholders)');
      whereArgs.addAll(filter.levels);
    }

    // 学习状态筛选
    if (filter != null && filter.statuses.isNotEmpty) {
      final placeholders = filter.statuses.map((_) => '?').join(',');
      whereClauses.add('COALESCE(up.status, 0) IN ($placeholders)');
      whereArgs.addAll(filter.statuses);
    }

    // 主题筛选
    if (filter != null && filter.themeId != null) {
      sql = '''
        SELECT c.*, f.collected_at, f.note, f.tags,
               COALESCE(up.status, 0) as learn_status
        FROM characters c
        INNER JOIN favorites f ON c.id = f.character_id
        INNER JOIN character_themes ct ON c.id = ct.character_id
        LEFT JOIN user_progress up ON c.id = up.character_id
      ''';
      whereClauses.add('ct.theme_id = ?');
      whereArgs.add(filter.themeId);
    }

    if (whereClauses.isNotEmpty) {
      sql += ' WHERE ' + whereClauses.join(' AND ');
    }

    // 排序
    sql += _getOrderByClause(filter?.sortOrder ?? FavoriteSortOrder.collectedDesc);

    final maps = await db.rawQuery(sql, whereArgs);
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 获取排序子句
  String _getOrderByClause(FavoriteSortOrder sortOrder) {
    switch (sortOrder) {
      case FavoriteSortOrder.collectedDesc:
        return ' ORDER BY f.collected_at DESC';
      case FavoriteSortOrder.collectedAsc:
        return ' ORDER BY f.collected_at ASC';
      case FavoriteSortOrder.pinyin:
        return ' ORDER BY c.pinyin ASC';
      case FavoriteSortOrder.levelAsc:
        return ' ORDER BY c.level ASC, c.strokes ASC';
      case FavoriteSortOrder.levelDesc:
        return ' ORDER BY c.level DESC, c.strokes DESC';
      case FavoriteSortOrder.strokesAsc:
        return ' ORDER BY c.strokes ASC';
      case FavoriteSortOrder.strokesDesc:
        return ' ORDER BY c.strokes DESC';
    }
  }

  /// 获取收藏统计
  Future<FavoriteStats> getStats() async {
    final db = await _dbHelper.database;

    // 总收藏数
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM favorites',
    );
    final totalCount = Sqflite.firstIntValue(totalResult) ?? 0;

    // 按学习状态统计
    final statusResult = await db.rawQuery('''
      SELECT COALESCE(up.status, 0) as status, COUNT(*) as count
      FROM favorites f
      LEFT JOIN user_progress up ON f.character_id = up.character_id
      GROUP BY COALESCE(up.status, 0)
    ''');

    int notLearnedCount = 0;
    int learningCount = 0;
    int masteredCount = 0;

    for (final row in statusResult) {
      final status = row['status'] as int;
      final count = row['count'] as int;
      if (status == 0) notLearnedCount = count;
      if (status == 1 || status == 3) learningCount += count;
      if (status == 2) masteredCount = count;
    }

    // 按难度统计
    final levelResult = await db.rawQuery('''
      SELECT c.level, COUNT(*) as count
      FROM favorites f
      INNER JOIN characters c ON f.character_id = c.id
      GROUP BY c.level
    ''');

    int level1Count = 0;
    int level2Count = 0;
    int level3Count = 0;
    int level4Count = 0;

    for (final row in levelResult) {
      final level = row['level'] as int;
      final count = row['count'] as int;
      switch (level) {
        case 1:
          level1Count = count;
          break;
        case 2:
          level2Count = count;
          break;
        case 3:
          level3Count = count;
          break;
        case 4:
          level4Count = count;
          break;
      }
    }

    return FavoriteStats(
      totalCount: totalCount,
      notLearnedCount: notLearnedCount,
      learningCount: learningCount,
      masteredCount: masteredCount,
      level1Count: level1Count,
      level2Count: level2Count,
      level3Count: level3Count,
      level4Count: level4Count,
    );
  }

  /// 获取收藏数量
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM favorites',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取收藏的汉字（带收藏信息）
  Future<List<Map<String, dynamic>>> getFavoriteWithInfo() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT c.*, f.collected_at, f.note, f.tags,
             COALESCE(up.status, 0) as learn_status
      FROM characters c
      INNER JOIN favorites f ON c.id = f.character_id
      LEFT JOIN user_progress up ON c.id = up.character_id
      ORDER BY f.collected_at DESC
    ''');
    return maps;
  }

  /// 更新收藏备注
  Future<void> updateNote(int characterId, String? note) async {
    final db = await _dbHelper.database;
    await db.update(
      'favorites',
      {'note': note},
      where: 'character_id = ?',
      whereArgs: [characterId],
    );
  }

  /// 更新收藏标签
  Future<void> updateTags(int characterId, List<String> tags) async {
    final db = await _dbHelper.database;
    await db.update(
      'favorites',
      {'tags': tags.join(',')},
      where: 'character_id = ?',
      whereArgs: [characterId],
    );
  }

  /// 获取需要复习的收藏汉字
  Future<List<int>> getFavoritesForReview() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    final maps = await db.rawQuery('''
      SELECT f.character_id
      FROM favorites f
      LEFT JOIN user_progress up ON f.character_id = up.character_id
      WHERE up.status > 0 AND up.next_review <= ?
      ORDER BY up.next_review ASC
    ''', [today]);

    return maps.map((m) => m['character_id'] as int).toList();
  }
}
