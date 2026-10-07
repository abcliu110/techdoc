import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/models.dart';

/// 汉字数据仓库
class CharacterRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 根据 ID 获取汉字
  Future<Character?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Character.fromMap(maps.first);
  }

  /// 根据汉字获取
  Future<Character?> getByCharacter(String char) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'character = ?',
      whereArgs: [char],
    );
    if (maps.isEmpty) return null;
    return Character.fromMap(maps.first);
  }

  /// 根据拼音搜索
  Future<List<Character>> searchByPinyin(String pinyin) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'pinyin LIKE ?',
      whereArgs: ['%$pinyin%'],
      orderBy: 'frequency ASC',
      limit: 50,
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 根据部首搜索
  Future<List<Character>> searchByRadical(String radical) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'radical = ?',
      whereArgs: [radical],
      orderBy: 'frequency ASC',
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 根据笔画数搜索
  Future<List<Character>> searchByStrokes(int strokes) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'strokes = ?',
      whereArgs: [strokes],
      orderBy: 'frequency ASC',
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 根据六书分类搜索
  Future<List<Character>> searchBySixBook(SixBook sixBook) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'six_book = ?',
      whereArgs: [sixBook.code],
      orderBy: 'frequency ASC',
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 根据字频范围获取汉字
  Future<List<Character>> getByFrequencyRange(int start, int end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'frequency >= ? AND frequency <= ?',
      whereArgs: [start, end],
      orderBy: 'frequency ASC',
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 获取高频字
  Future<List<Character>> getHighFrequencyChars(int limit) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      orderBy: 'frequency ASC',
      limit: limit,
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 获取形声字
  Future<List<Character>> getPhoneticChars(int limit) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'six_book = ?',
      whereArgs: [SixBook.phonetic.code],
      orderBy: 'frequency ASC',
      limit: limit,
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 获取指定声旁的字族
  Future<List<Character>> getByPhonetic(String phonetic) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'phonetic = ?',
      whereArgs: [phonetic],
      orderBy: 'frequency ASC',
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 获取汉字数量
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM characters');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取例词
  Future<List<WordExample>> getWordExamples(int characterId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'word_examples',
      where: 'character_id = ?',
      whereArgs: [characterId],
    );
    return maps.map((m) => WordExample.fromMap(m)).toList();
  }

  /// 获取未学习的汉字（排除已学习的）
  Future<List<Character>> getUnlearnedChars(int limit, {int? maxFrequency}) async {
    final db = await _dbHelper.database;
    String where = 'id NOT IN (SELECT character_id FROM user_progress WHERE status > 0)';
    List<dynamic> whereArgs = [];

    if (maxFrequency != null) {
      where += ' AND frequency <= ?';
      whereArgs.add(maxFrequency);
    }

    final maps = await db.query(
      'characters',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'frequency ASC',
      limit: limit,
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 插入汉字
  Future<int> insert(Character character) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'characters',
      character.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入汉字
  Future<void> insertAll(List<Character> characters) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final char in characters) {
      batch.insert(
        'characters',
        char.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 批量插入例词
  Future<void> insertWordExamples(List<WordExample> examples) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final example in examples) {
      batch.insert(
        'word_examples',
        example.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 批量插入字族
  Future<void> insertFamilies(List<CharacterFamily> families) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final family in families) {
      batch.insert(
        'character_families',
        family.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ==================== 六书字典 ====================

  /// 按六书分类获取汉字
  Future<List<Character>> getBySixBook(SixBook sixBook) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'six_book = ?',
      whereArgs: [sixBook.code],
      orderBy: 'frequency ASC',
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 统计六书分类汉字数量
  Future<int> countBySixBook(SixBook sixBook) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM characters WHERE six_book = ?',
      [sixBook.code],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== 字族图谱 ====================

  /// 获取所有字族
  Future<List<CharacterFamily>> getAllFamilies() async {
    final db = await _dbHelper.database;
    final maps = await db.query('character_families');
    return maps.map((m) => CharacterFamily.fromMap(m)).toList();
  }

  /// 根据声旁获取字族
  Future<CharacterFamily?> getFamilyByPhonetic(String phonetic) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'character_families',
      where: 'phonetic_char = ?',
      whereArgs: [phonetic],
    );
    if (maps.isEmpty) return null;
    return CharacterFamily.fromMap(maps.first);
  }

  /// 获取字族成员ID列表
  Future<List<int>> getFamilyMembers(int familyId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'family_members',
      where: 'family_id = ?',
      whereArgs: [familyId],
      orderBy: 'position ASC',
    );
    return maps.map((m) => m['character_id'] as int).toList();
  }

  /// 根据ID列表批量获取汉字
  Future<List<Character>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await _dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final maps = await db.query(
      'characters',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  /// 插入字族成员
  Future<void> insertFamilyMember(int familyId, int characterId, int position) async {
    final db = await _dbHelper.database;
    await db.insert(
      'family_members',
      {
        'family_id': familyId,
        'character_id': characterId,
        'position': position,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入字族成员
  Future<void> insertFamilyMembers(List<Map<String, int>> members) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final member in members) {
      batch.insert(
        'family_members',
        member,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
