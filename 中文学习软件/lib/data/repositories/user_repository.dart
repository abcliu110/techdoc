import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/spaced_repetition_service.dart';
import '../models/models.dart';

/// 用户数据仓库
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SpacedRepetitionService _srService = SpacedRepetitionService();

  /// 获取用户设置
  Future<UserSettings> getSettings() async {
    final db = await _dbHelper.database;
    final maps = await db.query('user_settings', where: 'id = ?', whereArgs: [1]);
    if (maps.isEmpty) {
      return const UserSettings();
    }
    return UserSettings.fromMap(maps.first);
  }

  /// 更新用户设置
  Future<void> updateSettings(UserSettings settings) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /// 获取用户等级
  Future<UserLevel> getUserLevel() async {
    final db = await _dbHelper.database;
    final maps = await db.query('user_level', where: 'id = ?', whereArgs: [1]);
    if (maps.isEmpty) {
      return const UserLevel();
    }
    return UserLevel.fromMap(maps.first);
  }

  /// 更新用户等级
  Future<void> updateUserLevel(UserLevel level) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_level',
      level.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /// 获取学习进度
  Future<UserProgress?> getProgress(int characterId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'user_progress',
      where: 'character_id = ?',
      whereArgs: [characterId],
    );
    if (maps.isEmpty) return null;
    return UserProgress.fromMap(maps.first);
  }

  /// 获取已学习汉字数量
  Future<int> getLearnedCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_progress WHERE status > 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取已掌握汉字数量
  Future<int> getMasteredCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_progress WHERE status = 2',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取待复习汉字
  Future<List<int>> getReviewChars() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final maps = await db.query(
      'user_progress',
      where: 'next_review IS NOT NULL AND next_review <= ? AND status > 0',
      whereArgs: [today],
      columns: ['character_id'],
    );
    return maps.map((m) => m['character_id'] as int).toList();
  }

  /// 获取今日已学习的汉字
  Future<List<int>> getTodayLearnedChars() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final maps = await db.query(
      'user_progress',
      where: 'learn_date = ?',
      whereArgs: [today],
      columns: ['character_id'],
    );
    return maps.map((m) => m['character_id'] as int).toList();
  }

  /// 更新学习进度
  Future<void> updateProgress(UserProgress progress) async {
    final db = await _dbHelper.database;
    await db.insert(
      'user_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 标记汉字已学习
  Future<void> markLearned(int characterId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final progress = UserProgress(
      characterId: characterId,
      status: LearnStatus.learning,
      learnDate: today,
      nextReview: today,
      correctCount: 0,
      wrongCount: 0,
      userRating: 0,
    );
    await updateProgress(progress);
  }

  /// 标记汉字已掌握（使用SM-2间隔重复算法）
  Future<void> markMastered(int characterId, bool correct) async {
    final progress = await getProgress(characterId);
    if (progress == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final newCorrectCount = correct ? progress.correctCount + 1 : progress.correctCount;
    final newWrongCount = correct ? progress.wrongCount : progress.wrongCount + 1;

    // 根据正确次数更新状态
    LearnStatus newStatus;
    if (newCorrectCount >= 3) {
      newStatus = LearnStatus.mastered;
    } else if (newWrongCount > newCorrectCount) {
      newStatus = LearnStatus.fuzzy;
    } else {
      newStatus = LearnStatus.learning;
    }

    // 使用 SM-2 算法计算下次复习间隔
    final quality = _srService.qualityFromResponse(remembered: correct);
    final currentInterval = _getCurrentInterval(progress);
    final easeFactor = _getEaseFactor(progress);

    final (nextInterval, newEaseFactor) = _srService.calculateNextReview(
      quality: quality,
      currentInterval: currentInterval,
      easeFactor: easeFactor,
    );

    final nextReviewDate = DateTime.now().add(Duration(days: nextInterval));
    final nextReview = nextReviewDate.toIso8601String().split('T')[0];

    final updated = progress.copyWith(
      status: newStatus,
      reviewDates: [...progress.reviewDates, today],
      nextReview: nextReview,
      correctCount: newCorrectCount,
      wrongCount: newWrongCount,
      easeFactor: newEaseFactor,
    );

    await updateProgress(updated);
  }

  /// 获取当前复习间隔
  int _getCurrentInterval(UserProgress progress) {
    if (progress.reviewDates.isEmpty) return 0;
    if (progress.reviewDates.length == 1) return 1;

    // 计算相邻两次复习的间隔
    for (int i = progress.reviewDates.length - 1; i > 0; i--) {
      final prev = DateTime.parse(progress.reviewDates[i - 1]);
      final curr = DateTime.parse(progress.reviewDates[i]);
      if (i > 0) {
        return curr.difference(prev).inDays;
      }
    }
    return 1;
  }

  /// 获取难度因子
  double _getEaseFactor(UserProgress progress) {
    // 如果没有记录，使用默认值
    if (progress.easeFactor == null || progress.easeFactor == 0) {
      return SpacedRepetitionService.defaultEaseFactor;
    }
    return progress.easeFactor!;
  }

  /// 获取复习紧迫度信息
  Future<Map<String, dynamic>> getReviewUrgency() async {
    final reviewChars = await getReviewChars();
    final now = DateTime.now();

    int overdueCount = 0;
    int todayCount = 0;
    int soonCount = 0;

    final db = await _dbHelper.database;
    for (final charId in reviewChars) {
      final maps = await db.query(
        'user_progress',
        where: 'character_id = ?',
        whereArgs: [charId],
      );
      if (maps.isNotEmpty) {
        final nextReview = maps.first['next_review'] as String?;
        if (nextReview != null) {
          final reviewDate = DateTime.parse(nextReview);
          final urgency = _srService.calculateUrgency(
            nextReviewDate: reviewDate,
            now: now,
          );

          if (urgency >= 100) overdueCount++;
          if (urgency >= 80 && urgency < 100) todayCount++;
          if (urgency >= 40 && urgency < 80) soonCount++;
        }
      }
    }

    return {
      'total': reviewChars.length,
      'overdue': overdueCount,
      'today': todayCount,
      'soon': soonCount,
      'estimateMinutes': SpacedRepetitionService.estimateReviewTime(reviewChars.length),
    };
  }

  /// 获取今日任务
  Future<DailyTask?> getTodayTask() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final maps = await db.query(
      'daily_tasks',
      where: 'task_date = ?',
      whereArgs: [today],
    );
    if (maps.isEmpty) return null;
    return DailyTask.fromMap(maps.first);
  }

  /// 创建今日任务
  Future<DailyTask> createTodayTask(List<int> charIds) async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    final task = DailyTask(
      id: 0,
      taskDate: today,
      taskChars: charIds,
      completedChars: [],
      totalCount: charIds.length,
      completedCount: 0,
      duration: 0,
      accuracy: 0.0,
    );

    await db.insert(
      'daily_tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 重新查询获取完整数据
    final maps = await db.query(
      'daily_tasks',
      where: 'task_date = ?',
      whereArgs: [today],
    );
    return DailyTask.fromMap(maps.first);
  }

  /// 更新任务进度
  Future<void> updateTaskProgress(DailyTask task) async {
    final db = await _dbHelper.database;
    await db.update(
      'daily_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// 获取本周学习记录
  Future<List<DailyTask>> getWeekTasks() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = weekStart.toIso8601String().split('T')[0];

    final maps = await db.query(
      'daily_tasks',
      where: 'task_date >= ?',
      whereArgs: [weekStartStr],
      orderBy: 'task_date ASC',
    );
    return maps.map((m) => DailyTask.fromMap(m)).toList();
  }

  /// 重置所有学习进度
  Future<void> resetAllProgress() async {
    final db = await _dbHelper.database;
    await db.delete('user_progress');
    await db.delete('daily_tasks');
    await db.update(
      'user_level',
      {'current_level': 1, 'learned_count': 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
