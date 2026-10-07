import 'dart:math';

/// 间隔重复算法服务 (SM-2 算法实现)
/// 基于 SuperMemo SM-2 算法，根据用户反馈调整复习间隔
class SpacedRepetitionService {
  /// 默认起始间隔（天）
  static const int defaultInterval = 1;

  /// 默认难度因子
  static const double defaultEaseFactor = 2.5;

  /// 最小难度因子
  static const double minEaseFactor = 1.3;

  /// 最大难度因子
  static const double maxEaseFactor = 2.5;

  /// 计算下次复习间隔
  ///
  /// [quality] - 回答质量 (0-5)
  ///   0: 完全忘记
  ///   1: 错误但看到答案后想起
  ///   2: 错误但容易想起
  ///   3: 正确但犹豫
  ///   4: 正确且记忆深刻
  ///   5: 完美记忆
  ///
  /// [currentInterval] - 当前间隔（天）
  /// [easeFactor] - 当前难度因子
  ///
  /// 返回: (下次间隔, 新的难度因子)
  (int, double) calculateNextReview({
    required int quality,
    required int currentInterval,
    required double easeFactor,
  }) {
    // 更新难度因子
    final newEaseFactor = _updateEaseFactor(easeFactor, quality);

    // 计算下次间隔
    int nextInterval;
    if (quality < 3) {
      // 回答不正确，重置间隔为1天
      nextInterval = defaultInterval;
    } else {
      // 回答正确，根据难度因子计算间隔
      if (currentInterval == 0) {
        nextInterval = 1;
      } else if (currentInterval == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (currentInterval * newEaseFactor).round();
      }
    }

    // 限制最大间隔为365天
    nextInterval = min(nextInterval, 365);

    return (nextInterval, newEaseFactor);
  }

  /// 更新难度因子
  double _updateEaseFactor(double currentEF, int quality) {
    // SM-2 公式: EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
    final newEF = currentEF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // 限制在 [minEaseFactor, maxEaseFactor] 范围内
    return max(minEaseFactor, min(maxEaseFactor, newEF));
  }

  /// 将"记住/没记住"转换为质量分数
  ///
  /// [remembered] - 是否记住
  /// [timeTaken] - 回答用时（秒），可选
  int qualityFromResponse({required bool remembered, int? timeTaken}) {
    if (!remembered) {
      return 1; // 错误
    }

    // 根据用时调整质量
    if (timeTaken != null) {
      if (timeTaken < 3) return 5; // 3秒内答对 - 完美
      if (timeTaken < 10) return 4; // 10秒内答对 - 良好
      return 3; // 10秒以上答对 - 一般
    }

    return 4; // 默认良好
  }

  /// 计算复习紧迫度
  ///
  /// 返回 0-100 的紧迫度分数
  /// 100 = 非常紧急（已过期）
  /// 0 = 不紧急（还很远）
  int calculateUrgency({
    required DateTime nextReviewDate,
    required DateTime now,
  }) {
    final daysUntilReview = nextReviewDate.difference(now).inDays;

    if (daysUntilReview <= 0) {
      // 已过期，紧迫度 100
      return 100;
    } else if (daysUntilReview == 1) {
      // 今天到期，紧迫度 80
      return 80;
    } else if (daysUntilReview <= 3) {
      // 3天内，紧迫度 60
      return 60;
    } else if (daysUntilReview <= 7) {
      // 一周内，紧迫度 40
      return 40;
    } else if (daysUntilReview <= 14) {
      // 两周内，紧迫度 20
      return 20;
    } else {
      // 更久，紧迫度 0
      return 0;
    }
  }

  /// 获取复习状态描述
  static String getReviewStatus(DateTime nextReviewDate, DateTime now) {
    final daysUntil = nextReviewDate.difference(now).inDays;

    if (daysUntil < 0) {
      return '已过期${-daysUntil}天';
    } else if (daysUntil == 0) {
      return '今天';
    } else if (daysUntil == 1) {
      return '明天';
    } else if (daysUntil <= 7) {
      return '${daysUntil}天后';
    } else {
      return '约${(daysUntil / 7).round()}周后';
    }
  }

  /// 估算完成所有复习需要的时间（分钟）
  static int estimateReviewTime(int reviewCount) {
    // 假设每个字复习需要约30秒
    return (reviewCount * 0.5).ceil();
  }
}
