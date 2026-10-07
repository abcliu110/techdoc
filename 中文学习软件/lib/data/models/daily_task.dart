import 'package:equatable/equatable.dart';

/// 每日任务
class DailyTask extends Equatable {
  final int id;
  final String taskDate; // 任务日期 YYYY-MM-DD
  final List<int> taskChars; // 今日任务汉字 ID 列表
  final List<int> completedChars; // 已完成汉字 ID 列表
  final int totalCount;
  final int completedCount;
  final int duration; // 学习时长（分钟）
  final double accuracy; // 正确率

  const DailyTask({
    required this.id,
    required this.taskDate,
    this.taskChars = const [],
    this.completedChars = const [],
    this.totalCount = 0,
    this.completedCount = 0,
    this.duration = 0,
    this.accuracy = 0.0,
  });

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'] as int,
      taskDate: map['task_date'] as String,
      taskChars: map['task_chars'] != null && (map['task_chars'] as String).isNotEmpty
          ? (map['task_chars'] as String)
              .split(',')
              .map((s) => int.tryParse(s) ?? 0)
              .where((i) => i > 0)
              .toList()
          : [],
      completedChars:
          map['completed_chars'] != null && (map['completed_chars'] as String).isNotEmpty
              ? (map['completed_chars'] as String)
                  .split(',')
                  .map((s) => int.tryParse(s) ?? 0)
                  .where((i) => i > 0)
                  .toList()
              : [],
      totalCount: map['total_count'] as int? ?? 0,
      completedCount: map['completed_count'] as int? ?? 0,
      duration: map['duration'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_date': taskDate,
      'task_chars': taskChars.join(','),
      'completed_chars': completedChars.join(','),
      'total_count': totalCount,
      'completed_count': completedCount,
      'duration': duration,
      'accuracy': accuracy,
    };
  }

  DailyTask copyWith({
    int? id,
    String? taskDate,
    List<int>? taskChars,
    List<int>? completedChars,
    int? totalCount,
    int? completedCount,
    int? duration,
    double? accuracy,
  }) {
    return DailyTask(
      id: id ?? this.id,
      taskDate: taskDate ?? this.taskDate,
      taskChars: taskChars ?? this.taskChars,
      completedChars: completedChars ?? this.completedChars,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      duration: duration ?? this.duration,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskDate,
        taskChars,
        completedChars,
        totalCount,
        completedCount,
        duration,
        accuracy,
      ];
}

/// 用户等级
class UserLevel extends Equatable {
  final int id;
  final int currentLevel; // 1-4
  final int learnedCount; // 已学字数

  const UserLevel({
    this.id = 1,
    this.currentLevel = 1,
    this.learnedCount = 0,
  });

  /// 根据已学字数计算等级
  static int calculateLevel(int count) {
    if (count < 500) return 1;
    if (count < 1000) return 2;
    if (count < 2000) return 3;
    return 4;
  }

  factory UserLevel.fromMap(Map<String, dynamic> map) {
    return UserLevel(
      id: map['id'] as int,
      currentLevel: map['current_level'] as int? ?? 1,
      learnedCount: map['learned_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_level': currentLevel,
      'learned_count': learnedCount,
    };
  }

  @override
  List<Object?> get props => [id, currentLevel, learnedCount];
}

/// 用户设置
class UserSettings extends Equatable {
  final int id;
  final int dailyTarget; // 每日目标字数
  final bool soundEnabled;
  final bool notificationEnabled;
  final bool parentModeEnabled;

  const UserSettings({
    this.id = 1,
    this.dailyTarget = 15,
    this.soundEnabled = true,
    this.notificationEnabled = true,
    this.parentModeEnabled = false,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as int,
      dailyTarget: map['daily_target'] as int? ?? 15,
      soundEnabled: (map['sound_enabled'] as int? ?? 1) == 1,
      notificationEnabled: (map['notification_enabled'] as int? ?? 1) == 1,
      parentModeEnabled: (map['parent_mode_enabled'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_target': dailyTarget,
      'sound_enabled': soundEnabled ? 1 : 0,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'parent_mode_enabled': parentModeEnabled ? 1 : 0,
    };
  }

  UserSettings copyWith({
    int? id,
    int? dailyTarget,
    bool? soundEnabled,
    bool? notificationEnabled,
    bool? parentModeEnabled,
  }) {
    return UserSettings(
      id: id ?? this.id,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      parentModeEnabled: parentModeEnabled ?? this.parentModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dailyTarget,
        soundEnabled,
        notificationEnabled,
        parentModeEnabled,
      ];
}
