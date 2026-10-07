import 'package:equatable/equatable.dart';

/// 学习状态枚举
enum LearnStatus {
  /// 未学习
  notLearned(0, '未学习'),
  /// 学习中
  learning(1, '学习中'),
  /// 已掌握
  mastered(2, '已掌握'),
  /// 模糊
  fuzzy(3, '模糊'),
  /// 已遗忘
  forgotten(4, '已遗忘');

  const LearnStatus(this.code, this.label);
  final int code;
  final String label;

  static LearnStatus fromCode(int code) {
    return LearnStatus.values.where((e) => e.code == code).firstOrNull ??
        LearnStatus.notLearned;
  }
}

/// 用户学习进度
class UserProgress extends Equatable {
  final int characterId;
  final LearnStatus status;
  final String? learnDate;
  final List<String> reviewDates;
  final String? nextReview;
  final int correctCount;
  final int wrongCount;
  final int userRating; // 1-5 对应 VKS
  final double? easeFactor; // SM-2 难度因子

  const UserProgress({
    required this.characterId,
    this.status = LearnStatus.notLearned,
    this.learnDate,
    this.reviewDates = const [],
    this.nextReview,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.userRating = 0,
    this.easeFactor,
  });

  /// 从数据库 Map 构造
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      characterId: map['character_id'] as int,
      status: LearnStatus.fromCode(map['status'] as int),
      learnDate: map['learn_date'] as String?,
      reviewDates: map['review_dates'] != null
          ? (map['review_dates'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
      nextReview: map['next_review'] as String?,
      correctCount: map['correct_count'] as int? ?? 0,
      wrongCount: map['wrong_count'] as int? ?? 0,
      userRating: map['user_rating'] as int? ?? 0,
      easeFactor: map['ease_factor'] != null
          ? (map['ease_factor'] as num).toDouble()
          : null,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'character_id': characterId,
      'status': status.code,
      'learn_date': learnDate,
      'review_dates': reviewDates.join(','),
      'next_review': nextReview,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'user_rating': userRating,
      'ease_factor': easeFactor,
    };
  }

  /// 创建副本
  UserProgress copyWith({
    int? characterId,
    LearnStatus? status,
    String? learnDate,
    List<String>? reviewDates,
    String? nextReview,
    int? correctCount,
    int? wrongCount,
    int? userRating,
    double? easeFactor,
  }) {
    return UserProgress(
      characterId: characterId ?? this.characterId,
      status: status ?? this.status,
      learnDate: learnDate ?? this.learnDate,
      reviewDates: reviewDates ?? this.reviewDates,
      nextReview: nextReview ?? this.nextReview,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      userRating: userRating ?? this.userRating,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }

  @override
  List<Object?> get props => [
        characterId,
        status,
        learnDate,
        reviewDates,
        nextReview,
        correctCount,
        wrongCount,
        userRating,
        easeFactor,
      ];
}
