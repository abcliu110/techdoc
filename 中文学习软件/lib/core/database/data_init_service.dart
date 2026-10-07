import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import '../constants/init_data.dart';

/// 数据初始化服务
class DataInitService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 初始化数据库数据
  Future<void> initializeData() async {
    try {
      final db = await _dbHelper.database;
      debugPrint('数据库连接成功，开始插入数据...');

      // 检查字符数据是否已存在
      final charCount = await db.rawQuery('SELECT COUNT(*) as count FROM characters');
      final existingCharCount = charCount.first['count'] as int;
      debugPrint('当前字符数量: $existingCharCount');

      if (existingCharCount > 0) {
        debugPrint('数据库已有 $existingCharCount 条汉字数据，跳过初始化');
        return;
      }

      // 逐个插入汉字数据（不使用事务，便于调试）
      int insertedCount = 0;
      for (final char in initialCharacters) {
        try {
          await db.insert('characters', char.toMap());
          insertedCount++;
        } catch (e) {
          debugPrint('插入字符 ${char.character} 失败: $e');
        }
      }
      debugPrint('已插入 $insertedCount 个汉字');

      // 插入字族数据
      for (final family in initialFamilies) {
        try {
          await db.insert('character_families', family.toMap());
        } catch (e) {
          debugPrint('插入字族 ${family.phoneticChar} 失败: $e');
        }
      }

      // 插入字族成员关联数据
      for (final member in initialFamilyMembers) {
        try {
          await db.insert('family_members', {
            'family_id': member[0],
            'character_id': member[1],
            'position': member[2],
          });
        } catch (e) {
          debugPrint('插入成员失败: $e');
        }
      }

      // 插入例词数据
      for (final example in initialWordExamples) {
        try {
          await db.insert('word_examples', example.toMap());
        } catch (e) {
          debugPrint('插入例词失败: $e');
        }
      }

      // 验证插入结果
      final finalCount = await db.rawQuery('SELECT COUNT(*) as count FROM characters');
      debugPrint('最终字符数量: ${finalCount.first['count']}');
      debugPrint('数据初始化完成：${initialCharacters.length}个汉字');
    } catch (e, stackTrace) {
      debugPrint('数据初始化失败: $e');
      debugPrint('堆栈: $stackTrace');
    }
  }
}
