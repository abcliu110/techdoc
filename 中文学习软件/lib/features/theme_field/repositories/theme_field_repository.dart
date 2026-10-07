import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/theme_model.dart';
import '../models/character_theme_model.dart';
import '../models/theme_word_model.dart';

/// 主题词场数据仓库
class ThemeFieldRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== 主题基础操作 ====================

  /// 获取所有主题
  Future<List<Theme>> getAllThemes() async {
    final db = await _dbHelper.database;
    final maps = await db.query('themes', orderBy: 'id ASC');
    return maps.map((m) => Theme.fromMap(m)).toList();
  }

  /// 根据分类获取主题
  Future<List<Theme>> getThemesByCategory(ThemeCategory category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'themes',
      where: 'category = ?',
      whereArgs: [category.code],
      orderBy: 'id ASC',
    );
    return maps.map((m) => Theme.fromMap(m)).toList();
  }

  /// 根据 ID 获取主题
  Future<Theme?> getThemeById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'themes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Theme.fromMap(maps.first);
  }

  /// 获取主题总数
  Future<int> getThemeCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM themes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 插入主题
  Future<int> insertTheme(Theme theme) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'themes',
      theme.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入主题
  Future<void> insertThemes(List<Theme> themes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final theme in themes) {
      batch.insert(
        'themes',
        theme.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ==================== 主题汉字关联 ====================

  /// 获取主题关联的所有汉字
  Future<List<int>> getCharacterIdsByTheme(int themeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'character_themes',
      where: 'theme_id = ?',
      whereArgs: [themeId],
      orderBy: 'position ASC',
    );
    return maps.map((m) => m['character_id'] as int).toList();
  }

  /// 获取主题关联的汉字数量
  Future<int> getCharacterCountByTheme(int themeId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM character_themes WHERE theme_id = ?',
      [themeId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 添加汉字到主题
  Future<int> addCharacterToTheme(int themeId, int characterId, {int position = 0}) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'character_themes',
      {
        'theme_id': themeId,
        'character_id': characterId,
        'position': position,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 批量添加汉字到主题
  Future<void> addCharactersToTheme(int themeId, List<int> characterIds) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (int i = 0; i < characterIds.length; i++) {
      batch.insert(
        'character_themes',
        {
          'theme_id': themeId,
          'character_id': characterIds[i],
          'position': i,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 从主题移除汉字
  Future<int> removeCharacterFromTheme(int themeId, int characterId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'character_themes',
      where: 'theme_id = ? AND character_id = ?',
      whereArgs: [themeId, characterId],
    );
  }

  // ==================== 主题词 ====================

  /// 获取主题的所有词
  Future<List<ThemeWord>> getWordsByTheme(int themeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'theme_words',
      where: 'theme_id = ?',
      whereArgs: [themeId],
      orderBy: 'position ASC',
    );
    return maps.map((m) => ThemeWord.fromMap(m)).toList();
  }

  /// 获取主题词数量
  Future<int> getWordCountByTheme(int themeId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM theme_words WHERE theme_id = ?',
      [themeId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 插入主题词
  Future<int> insertThemeWord(ThemeWord word) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'theme_words',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入主题词
  Future<void> insertThemeWords(List<ThemeWord> words) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final word in words) {
      batch.insert(
        'theme_words',
        word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ==================== 初始化预设主题 ====================

  /// 初始化预设主题数据
  Future<void> initPresetThemes() async {
    final count = await getThemeCount();
    if (count > 0) return; // 已有数据，跳过

    final presetThemes = _getPresetThemes();
    await insertThemes(presetThemes);

    // 初始化预设主题词
    await _initPresetThemeWords();
  }

  /// 获取预设主题列表
  List<Theme> _getPresetThemes() {
    return [
      // 人物类
      Theme(id: 1, name: '人体部位', description: '头、手、脚等身体部位汉字', category: ThemeCategory.person, icon: 'person', color: 0xFFE91E63, charCount: 0, wordCount: 0),
      Theme(id: 2, name: '家庭称谓', description: '爸、妈、爷、奶等亲属称呼', category: ThemeCategory.person, icon: 'family', color: 0xFFFF5722, charCount: 0, wordCount: 0),
      Theme(id: 3, name: '职业身份', description: '老师、医生、工人等职业词', category: ThemeCategory.person, icon: 'work', color: 0xFF9C27B0, charCount: 0, wordCount: 0),

      // 自然类
      Theme(id: 4, name: '天气现象', description: '雨、雪、风、云等天气词', category: ThemeCategory.nature, icon: 'weather', color: 0xFF2196F3, charCount: 0, wordCount: 0),
      Theme(id: 5, name: '山水地理', description: '江、河、湖、海、山等地理词', category: ThemeCategory.nature, icon: 'landscape', color: 0xFF4CAF50, charCount: 0, wordCount: 0),

      // 动物类
      Theme(id: 6, name: '家禽家畜', description: '鸡、鸭、猪、牛等常见动物', category: ThemeCategory.animal, icon: 'pets', color: 0xFF795548, charCount: 0, wordCount: 0),
      Theme(id: 7, name: '昆虫爬行', description: '虫、蛇、蚂蚁等虫类汉字', category: ThemeCategory.animal, icon: 'bug', color: 0xFF8BC34A, charCount: 0, wordCount: 0),

      // 食物类
      Theme(id: 8, name: '五谷杂粮', description: '米、面、麦、豆等粮食词', category: ThemeCategory.food, icon: 'grain', color: 0xFFFFC107, charCount: 0, wordCount: 0),
      Theme(id: 9, name: '水果蔬菜', description: '苹、菜、瓜、果等植物类', category: ThemeCategory.food, icon: 'fruit', color: 0xFFFF9800, charCount: 0, wordCount: 0),

      // 动作类
      Theme(id: 10, name: '手部动作', description: '打、抓、拿、推等动作词', category: ThemeCategory.action, icon: 'hand', color: 0xFF00BCD4, charCount: 0, wordCount: 0),
      Theme(id: 11, name: '走跑跳跃', description: '走、跑、跳、飞等移动词', category: ThemeCategory.action, icon: 'run', color: 0xFF3F51B5, charCount: 0, wordCount: 0),

      // 颜色类
      Theme(id: 12, name: '基础色彩', description: '红、黄、蓝、绿等颜色词', category: ThemeCategory.color, icon: 'palette', color: 0xFFF44336, charCount: 0, wordCount: 0),

      // 时间类
      Theme(id: 13, name: '年月周日', description: '年、月、日、时等时间词', category: ThemeCategory.time, icon: 'calendar', color: 0xFF607D8B, charCount: 0, wordCount: 0),
      Theme(id: 14, name: '季节节气', description: '春夏秋冬及二十四节气', category: ThemeCategory.time, icon: 'season', color: 0xFF009688, charCount: 0, wordCount: 0),

      // 数字类
      Theme(id: 15, name: '基础数字', description: '一二三四五六七八九十', category: ThemeCategory.number, icon: 'numbers', color: 0xFF9E9E9E, charCount: 0, wordCount: 0),
    ];
  }

  /// 初始化预设主题词
  Future<void> _initPresetThemeWords() async {
    final presetWords = _getPresetWords();
    await insertThemeWords(presetWords);

    // 建立汉字关联
    await _initCharacterThemeRelations();
  }

  /// 获取预设主题词列表
  List<ThemeWord> _getPresetWords() {
    return [
      // 人体部位
      ThemeWord(id: 1, themeId: 1, characterId: 0, word: '头', pinyin: 'tou', meaning: '脑袋'),
      ThemeWord(id: 2, themeId: 1, characterId: 0, word: '手', pinyin: 'shou', meaning: '手掌'),
      ThemeWord(id: 3, themeId: 1, characterId: 0, word: '脚', pinyin: 'jiao', meaning: '足部'),
      ThemeWord(id: 4, themeId: 1, characterId: 0, word: '眼', pinyin: 'yan', meaning: '眼睛'),
      ThemeWord(id: 5, themeId: 1, characterId: 0, word: '耳', pinyin: 'er', meaning: '耳朵'),
      ThemeWord(id: 6, themeId: 1, characterId: 0, word: '口', pinyin: 'kou', meaning: '嘴巴'),
      ThemeWord(id: 7, themeId: 1, characterId: 0, word: '鼻', pinyin: 'bi', meaning: '鼻子'),
      ThemeWord(id: 8, themeId: 1, characterId: 0, word: '心', pinyin: 'xin', meaning: '心脏'),

      // 家庭称谓
      ThemeWord(id: 9, themeId: 2, characterId: 0, word: '爸', pinyin: 'ba', meaning: '父亲'),
      ThemeWord(id: 10, themeId: 2, characterId: 0, word: '妈', pinyin: 'ma', meaning: '母亲'),
      ThemeWord(id: 11, themeId: 2, characterId: 0, word: '爷', pinyin: 'ye', meaning: '祖父'),
      ThemeWord(id: 12, themeId: 2, characterId: 0, word: '奶', pinyin: 'nai', meaning: '祖母'),
      ThemeWord(id: 13, themeId: 2, characterId: 0, word: '哥', pinyin: 'ge', meaning: '兄长'),
      ThemeWord(id: 14, themeId: 2, characterId: 0, word: '姐', pinyin: 'jie', meaning: '姐姐'),
      ThemeWord(id: 15, themeId: 2, characterId: 0, word: '弟', pinyin: 'di', meaning: '弟弟'),
      ThemeWord(id: 16, themeId: 2, characterId: 0, word: '妹', pinyin: 'mei', meaning: '妹妹'),

      // 天气现象
      ThemeWord(id: 17, themeId: 4, characterId: 0, word: '雨', pinyin: 'yu', meaning: '降水'),
      ThemeWord(id: 18, themeId: 4, characterId: 0, word: '雪', pinyin: 'xue', meaning: '降雪'),
      ThemeWord(id: 19, themeId: 4, characterId: 0, word: '风', pinyin: 'feng', meaning: '空气流动'),
      ThemeWord(id: 20, themeId: 4, characterId: 0, word: '云', pinyin: 'yun', meaning: '云彩'),
      ThemeWord(id: 21, themeId: 4, characterId: 0, word: '雷', pinyin: 'lei', meaning: '雷电'),
      ThemeWord(id: 22, themeId: 4, characterId: 0, word: '电', pinyin: 'dian', meaning: '闪电'),

      // 山水地理
      ThemeWord(id: 23, themeId: 5, characterId: 0, word: '江', pinyin: 'jiang', meaning: '大河'),
      ThemeWord(id: 24, themeId: 5, characterId: 0, word: '河', pinyin: 'he', meaning: '水道'),
      ThemeWord(id: 25, themeId: 5, characterId: 0, word: '湖', pinyin: 'hu', meaning: '湖泊'),
      ThemeWord(id: 26, themeId: 5, characterId: 0, word: '海', pinyin: 'hai', meaning: '海洋'),
      ThemeWord(id: 27, themeId: 5, characterId: 0, word: '山', pinyin: 'shan', meaning: '高山'),
      ThemeWord(id: 28, themeId: 5, characterId: 0, word: '石', pinyin: 'shi', meaning: '石头'),

      // 颜色
      ThemeWord(id: 29, themeId: 12, characterId: 0, word: '红', pinyin: 'hong', meaning: '红色'),
      ThemeWord(id: 30, themeId: 12, characterId: 0, word: '黄', pinyin: 'huang', meaning: '黄色'),
      ThemeWord(id: 31, themeId: 12, characterId: 0, word: '蓝', pinyin: 'lan', meaning: '蓝色'),
      ThemeWord(id: 32, themeId: 12, characterId: 0, word: '绿', pinyin: 'lv', meaning: '绿色'),
      ThemeWord(id: 33, themeId: 12, characterId: 0, word: '白', pinyin: 'bai', meaning: '白色'),
      ThemeWord(id: 34, themeId: 12, characterId: 0, word: '黑', pinyin: 'hei', meaning: '黑色'),

      // 基础数字
      ThemeWord(id: 35, themeId: 15, characterId: 0, word: '一', pinyin: 'yi', meaning: '数字1'),
      ThemeWord(id: 36, themeId: 15, characterId: 0, word: '二', pinyin: 'er', meaning: '数字2'),
      ThemeWord(id: 37, themeId: 15, characterId: 0, word: '三', pinyin: 'san', meaning: '数字3'),
      ThemeWord(id: 38, themeId: 15, characterId: 0, word: '四', pinyin: 'si', meaning: '数字4'),
      ThemeWord(id: 39, themeId: 15, characterId: 0, word: '五', pinyin: 'wu', meaning: '数字5'),
      ThemeWord(id: 40, themeId: 15, characterId: 0, word: '六', pinyin: 'liu', meaning: '数字6'),
      ThemeWord(id: 41, themeId: 15, characterId: 0, word: '七', pinyin: 'qi', meaning: '数字7'),
      ThemeWord(id: 42, themeId: 15, characterId: 0, word: '八', pinyin: 'ba', meaning: '数字8'),
      ThemeWord(id: 43, themeId: 15, characterId: 0, word: '九', pinyin: 'jiu', meaning: '数字9'),
      ThemeWord(id: 44, themeId: 15, characterId: 0, word: '十', pinyin: 'shi', meaning: '数字10'),
    ];
  }

  /// 初始化汉字-主题关联
  Future<void> _initCharacterThemeRelations() async {
    final db = await _dbHelper.database;

    // 获取所有汉字，匹配主题词
    final charMaps = await db.query('characters', columns: ['id', 'character']);
    final charMap = {for (var m in charMaps) m['character'] as String: m['id'] as int};

    // 获取所有主题词
    final wordMaps = await db.query('theme_words', columns: ['id', 'word', 'theme_id']);
    final batch = db.batch();

    for (final wordMap in wordMaps) {
      final word = wordMap['word'] as String;
      final themeId = wordMap['theme_id'] as int;
      final charId = charMap[word];

      if (charId != null) {
        // 更新主题词的 character_id
        batch.update(
          'theme_words',
          {'character_id': charId},
          where: 'id = ?',
          whereArgs: [wordMap['id']],
        );

        // 建立关联
        batch.insert(
          'character_themes',
          {'theme_id': themeId, 'character_id': charId, 'position': 0},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  /// 更新主题统计信息
  Future<void> updateThemeStats(int themeId) async {
    final db = await _dbHelper.database;

    final charCount = await getCharacterCountByTheme(themeId);
    final wordCount = await getWordCountByTheme(themeId);

    await db.update(
      'themes',
      {'char_count': charCount, 'word_count': wordCount},
      where: 'id = ?',
      whereArgs: [themeId],
    );
  }

  /// 搜索主题
  Future<List<Theme>> searchThemes(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'themes',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id ASC',
    );
    return maps.map((m) => Theme.fromMap(m)).toList();
  }
}
