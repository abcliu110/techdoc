import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// 桌面平台 FFI 支持
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath;

    if (kIsWeb) {
      // Web 平台使用 IndexedDB
      databaseFactory = databaseFactoryFfiWeb;
      dbPath = 'hanzi_learn.db';
      debugPrint('Web 平台初始化数据库...');
    } else {
      // 桌面/移动平台 - 初始化 FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      try {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        dbPath = path.join(documentsDirectory.path, 'hanzi_learn.db');
      } catch (e) {
        dbPath = 'hanzi_learn.db';
      }
    }

    debugPrint('数据库路径: $dbPath');

    try {
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
      );
      debugPrint('数据库初始化成功');
      return db;
    } catch (e) {
      debugPrint('数据库初始化失败: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE characters (
        id INTEGER PRIMARY KEY, character TEXT NOT NULL UNIQUE, pinyin TEXT NOT NULL, radical TEXT NOT NULL,
        strokes INTEGER NOT NULL, frequency INTEGER NOT NULL, six_book INTEGER, phonetic TEXT, semantic TEXT,
        origin_jiaguwen TEXT, origin_jinwen TEXT, origin_xiaozhuan TEXT, original_meaning TEXT,
        extended_meanings TEXT, level INTEGER NOT NULL DEFAULT 1, sources TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP)
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        character_id INTEGER PRIMARY KEY, status INTEGER NOT NULL DEFAULT 0, learn_date TEXT,
        review_dates TEXT, next_review TEXT, correct_count INTEGER DEFAULT 0, wrong_count INTEGER DEFAULT 0,
        user_rating INTEGER DEFAULT 0, ease_factor REAL)
    ''');

    await db.execute('''
      CREATE TABLE character_families (
        id INTEGER PRIMARY KEY AUTOINCREMENT, phonetic_char TEXT NOT NULL UNIQUE, phonetic_pinyin TEXT, phonetic_consistency TEXT DEFAULT '中', note TEXT)
    ''');

    await db.execute('''
      CREATE TABLE family_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT, family_id INTEGER NOT NULL, character_id INTEGER NOT NULL, position INTEGER NOT NULL)
    ''');

    await db.execute('''
      CREATE TABLE word_examples (
        id INTEGER PRIMARY KEY AUTOINCREMENT, character_id INTEGER NOT NULL, word TEXT NOT NULL, meaning TEXT, example_sentence TEXT, source TEXT)
    ''');

    await db.execute('''
      CREATE TABLE daily_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT, task_date TEXT NOT NULL UNIQUE, task_chars TEXT, completed_chars TEXT,
        total_count INTEGER DEFAULT 0, completed_count INTEGER DEFAULT 0, duration INTEGER DEFAULT 0, accuracy REAL DEFAULT 0.0)
    ''');

    await db.execute('''
      CREATE TABLE user_level (id INTEGER PRIMARY KEY DEFAULT 1, current_level INTEGER DEFAULT 1, learned_count INTEGER DEFAULT 0)
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY DEFAULT 1, daily_target INTEGER DEFAULT 15, sound_enabled INTEGER DEFAULT 1,
        notification_enabled INTEGER DEFAULT 1, parent_mode_enabled INTEGER DEFAULT 0)
    ''');

    // 主题词场表
    await db.execute('''
      CREATE TABLE themes (
        id INTEGER PRIMARY KEY, name TEXT NOT NULL, description TEXT, category INTEGER NOT NULL,
        icon TEXT, char_count INTEGER DEFAULT 0, word_count INTEGER DEFAULT 0, color INTEGER DEFAULT 4285169407,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP)
    ''');

    await db.execute('''
      CREATE TABLE character_themes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, theme_id INTEGER NOT NULL, character_id INTEGER NOT NULL,
        position INTEGER DEFAULT 0, UNIQUE(theme_id, character_id))
    ''');

    await db.execute('''
      CREATE TABLE theme_words (
        id INTEGER PRIMARY KEY, theme_id INTEGER NOT NULL, character_id INTEGER DEFAULT 0,
        word TEXT NOT NULL, pinyin TEXT, meaning TEXT, example_sentence TEXT, position INTEGER DEFAULT 0)
    ''');

    // 收藏功能表
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT, character_id INTEGER NOT NULL UNIQUE,
        collected_at TEXT NOT NULL, note TEXT, tags TEXT,
        FOREIGN KEY (character_id) REFERENCES characters(id))
    ''');

    await db.execute('''
      CREATE TABLE favorite_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT, favorite_id INTEGER NOT NULL,
        tag_name TEXT NOT NULL, FOREIGN KEY (favorite_id) REFERENCES favorites(id))
    ''');

    // 创建收藏相关索引
    await db.execute('CREATE INDEX idx_favorites_character ON favorites(character_id)');
    await db.execute('CREATE INDEX idx_favorite_tags_favorite ON favorite_tags(favorite_id)');

    // 创建索引
    await db.execute('CREATE INDEX idx_characters_frequency ON characters(frequency)');
    await db.execute('CREATE INDEX idx_characters_radical ON characters(radical)');
    await db.execute('CREATE INDEX idx_characters_strokes ON characters(strokes)');
    await db.execute('CREATE INDEX idx_characters_sixbook ON characters(six_book)');
    await db.execute('CREATE INDEX idx_user_progress_status ON user_progress(status)');
    await db.execute('CREATE INDEX idx_daily_tasks_date ON daily_tasks(task_date)');
    await db.execute('CREATE INDEX idx_themes_category ON themes(category)');
    await db.execute('CREATE INDEX idx_character_themes_theme ON character_themes(theme_id)');
    await db.execute('CREATE INDEX idx_theme_words_theme ON theme_words(theme_id)');

    // 插入初始数据
    await db.insert('user_level', {'id': 1, 'current_level': 1, 'learned_count': 0});
    await db.insert('user_settings', {
      'id': 1,
      'daily_target': 15,
      'sound_enabled': 1,
      'notification_enabled': 1,
      'parent_mode_enabled': 0
    });

    debugPrint('数据库表创建完成');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
