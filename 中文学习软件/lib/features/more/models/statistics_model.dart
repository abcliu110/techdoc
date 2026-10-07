import 'package:equatable/equatable.dart';

/// 学习统计数据
class StatisticsModel extends Equatable {
  /// 汉字总数
  final int totalCount;

  /// 已学习数量
  final int learnedCount;

  /// 已掌握数量
  final int masteredCount;

  /// 未学习数量
  final int notLearnedCount;

  /// 学习中数量（模糊）
  final int learningCount;

  /// 今日已学
  final int todayLearnedCount;

  /// 今日待复习
  final int todayReviewCount;

  /// 累计学习天数
  final int totalStudyDays;

  /// 本周学习天数
  final int weekStudyDays;

  /// 平均每日学习
  final double avgDailyLearned;

  /// 连续学习天数
  final int streakDays;

  /// 今日学习时长（分钟）
  final int todayDuration;

  /// 累计学习时长（分钟）
  final int totalDuration;

  /// 正确率
  final double accuracy;

  const StatisticsModel({
    this.totalCount = 0,
    this.learnedCount = 0,
    this.masteredCount = 0,
    this.notLearnedCount = 0,
    this.learningCount = 0,
    this.todayLearnedCount = 0,
    this.todayReviewCount = 0,
    this.totalStudyDays = 0,
    this.weekStudyDays = 0,
    this.avgDailyLearned = 0,
    this.streakDays = 0,
    this.todayDuration = 0,
    this.totalDuration = 0,
    this.accuracy = 0,
  });

  /// 计算掌握率
  double get masteryRate => learnedCount > 0 ? masteredCount / learnedCount : 0;

  /// 学习进度百分比
  double get progressPercent => totalCount > 0 ? learnedCount / totalCount : 0;

  @override
  List<Object?> get props => [
        totalCount,
        learnedCount,
        masteredCount,
        notLearnedCount,
        learningCount,
        todayLearnedCount,
        todayReviewCount,
        totalStudyDays,
        weekStudyDays,
        avgDailyLearned,
        streakDays,
        todayDuration,
        totalDuration,
        accuracy,
      ];
}

/// 提醒时间设置
class ReminderTime extends Equatable {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderTime({
    this.enabled = false,
    this.hour = 20,
    this.minute = 0,
  });

  /// 获取格式化的时间字符串
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  ReminderTime copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderTime(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  List<Object?> get props => [enabled, hour, minute];
}
