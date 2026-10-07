import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/character_repository.dart';
import '../models/statistics_model.dart';

/// 统计状态
class StatisticsState {
  final StatisticsModel statistics;
  final bool isLoading;
  final String? error;

  const StatisticsState({
    this.statistics = const StatisticsModel(),
    this.isLoading = false,
    this.error,
  });

  StatisticsState copyWith({
    StatisticsModel? statistics,
    bool? isLoading,
    String? error,
  }) {
    return StatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 统计 Provider
final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier();
});

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final UserRepository _userRepository = UserRepository();
  final CharacterRepository _characterRepository = CharacterRepository();

  StatisticsNotifier() : super(const StatisticsState()) {
    loadStatistics();
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 获取汉字总数
      final totalCount = await _characterRepository.getCount();

      // 获取用户学习数据
      final learnedCount = await _userRepository.getLearnedCount();
      final masteredCount = await _userRepository.getMasteredCount();
      final todayLearned = await _userRepository.getTodayLearnedChars();
      final reviewChars = await _userRepository.getReviewChars();
      final weekTasks = await _userRepository.getWeekTasks();

      // 计算统计数据
      final notLearnedCount = totalCount - learnedCount;
      final learningCount = learnedCount - masteredCount;

      // 计算本周学习天数
      final weekStudyDays = weekTasks.where((t) => t.completedCount > 0).length;

      // 计算平均每日学习
      double avgDailyLearned = 0;
      if (weekStudyDays > 0) {
        final weekTotal = weekTasks.fold<int>(
          0,
          (sum, task) => sum + task.completedCount,
        );
        avgDailyLearned = weekTotal / 7;
      }

      // 计算今日学习时长
      int todayDuration = 0;
      if (weekTasks.isNotEmpty) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayTask = weekTasks.where((t) => t.taskDate == today).firstOrNull;
        todayDuration = todayTask?.duration ?? 0;
      }

      // 计算累计学习时长
      final totalDuration = weekTasks.fold<int>(
        0,
        (sum, task) => sum + task.duration,
      );

      // 计算正确率
      double accuracy = 0;
      int totalCorrect = 0;
      int totalWrong = 0;
      for (final task in weekTasks) {
        if (task.accuracy > 0 && task.completedCount > 0) {
          totalCorrect += (task.accuracy * task.completedCount).round();
          totalWrong += task.completedCount - totalCorrect;
        }
      }
      if (totalCorrect + totalWrong > 0) {
        accuracy = totalCorrect / (totalCorrect + totalWrong);
      }

      final statistics = StatisticsModel(
        totalCount: totalCount,
        learnedCount: learnedCount,
        masteredCount: masteredCount,
        notLearnedCount: notLearnedCount,
        learningCount: learningCount,
        todayLearnedCount: todayLearned.length,
        todayReviewCount: reviewChars.length,
        totalStudyDays: weekStudyDays,
        weekStudyDays: weekStudyDays,
        avgDailyLearned: avgDailyLearned,
        streakDays: weekStudyDays, // 简化处理，实际应计算连续天数
        todayDuration: todayDuration,
        totalDuration: totalDuration,
        accuracy: accuracy,
      );

      state = state.copyWith(
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载统计数据失败: $e',
      );
    }
  }

  /// 刷新统计数据
  Future<void> refresh() => loadStatistics();
}
