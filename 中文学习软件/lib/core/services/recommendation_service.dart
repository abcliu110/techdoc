import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

/// 用户级别枚举
enum UserLevel {
  /// 小学一级 (0-500)
  level1(1, 500, '小学一级'),
  /// 小学二级 (500-1000)
  level2(2, 1000, '小学二级'),
  /// 小学三级 (1000-2000)
  level3(3, 2000, '小学三级'),
  /// 小学四级 (2000-3500)
  level4(4, 3500, '小学四级'),
  /// 高级 (>3500)
  advanced(5, 9999, '高级');

  final int level;
  final int maxFrequency;
  final String label;

  const UserLevel(this.level, this.maxFrequency, this.label);

  /// 根据学习数量确定级别
  static UserLevel fromLearnedCount(int count) {
    if (count < 500) return level1;
    if (count < 1000) return level2;
    if (count < 2000) return level3;
    if (count < 3500) return level4;
    return advanced;
  }
}

/// 字族学习推荐
class FamilyRecommendation {
  final Character phoneticChar; // 声旁字
  final List<Character> familyChars; // 同族字
  final int semanticCount; // 形旁数量

  FamilyRecommendation({
    required this.phoneticChar,
    required this.familyChars,
    required this.semanticCount,
  });
}

/// 智能推荐服务
class RecommendationService {
  final CharacterRepository _charRepo = CharacterRepository();

  /// 推荐今日学习内容
  ///
  /// 策略:
  /// - 60% 优先推荐用户未学习的同族字
  /// - 40% 基于字频推荐
  /// - 确保 i+1 可理解输入原则 (80-90% 已知内容)
  Future<List<Character>> recommendDailyLearning({
    required int count,
    required UserLevel level,
    required List<int> learnedCharIds,
  }) async {
    final result = <Character>[];
    final learnedSet = learnedCharIds.toSet();

    // 1. 获取同族字推荐 (60%)
    final familyCount = (count * 0.6).ceil();
    final familyRecommendations = await _getFamilyRecommendations(
      count: familyCount,
      learnedSet: learnedSet,
    );

    for (final rec in familyRecommendations) {
      if (!learnedSet.contains(rec.id)) {
        result.add(rec);
      }
    }

    // 2. 如果还不够，补充字频推荐 (40%)
    if (result.length < count) {
      final freqCount = count - result.length;
      final freqChars = await _getFrequencyBasedRecommendations(
        count: freqCount,
        level: level,
        learnedSet: learnedSet,
      );
      result.addAll(freqChars);
    }

    return result.take(count).toList();
  }

  /// 基于字族推荐
  Future<List<Character>> _getFamilyRecommendations({
    required int count,
    required Set<int> learnedSet,
  }) async {
    // 获取已学习的形声字
    final learnedPhonetics = await _getLearnedPhonetics(learnedSet);
    final result = <Character>[];

    // 对每个已学习的声旁，寻找同族字
    for (final phonetic in learnedPhonetics) {
      final family = await _charRepo.getByPhonetic(phonetic);
      for (final char in family) {
        if (!learnedSet.contains(char.id) && !result.any((c) => c.id == char.id)) {
          result.add(char);
        }
      }
      if (result.length >= count) break;
    }

    // 如果还不够，随机选择一些未学习的形声字
    if (result.length < count) {
      final unlearned = await _charRepo.getUnlearnedChars(count * 2);
      for (final char in unlearned) {
        if (!learnedSet.contains(char.id) && !result.any((c) => c.id == char.id)) {
          result.add(char);
        }
        if (result.length >= count) break;
      }
    }

    return result;
  }

  /// 获取已学习的声旁
  Future<List<String>> _getLearnedPhonetics(Set<int> learnedSet) async {
    final phonetics = <String>[];
    for (final id in learnedSet) {
      final char = await _charRepo.getById(id);
      if (char != null && char.phonetic != null && char.phonetic!.isNotEmpty) {
        if (!phonetics.contains(char.phonetic)) {
          phonetics.add(char.phonetic!);
        }
      }
    }
    return phonetics;
  }

  /// 基于字频推荐
  Future<List<Character>> _getFrequencyBasedRecommendations({
    required int count,
    required UserLevel level,
    required Set<int> learnedSet,
  }) async {
    // 获取符合当前级别的未学习汉字
    final candidates = await _charRepo.getByFrequencyRange(
      0,
      level.maxFrequency,
    );

    final result = <Character>[];
    for (final char in candidates) {
      if (!learnedSet.contains(char.id)) {
        result.add(char);
      }
      if (result.length >= count) break;
    }

    return result;
  }

  /// 推荐同族字进行扩展学习
  Future<FamilyRecommendation?> recommendFamilyExpansion(Character char) async {
    if (char.phonetic == null || char.phonetic!.isEmpty) {
      return null;
    }

    final family = await _charRepo.getByPhonetic(char.phonetic!);
    if (family.length < 2) {
      return null;
    }

    // 计算不同的形旁数量
    final semantics = <String>{};
    for (final c in family) {
      if (c.semantic != null) {
        semantics.add(c.semantic!);
      }
    }

    return FamilyRecommendation(
      phoneticChar: char,
      familyChars: family,
      semanticCount: semantics.length,
    );
  }

  /// 获取学习进度提示
  String getProgressHint(int learnedCount, UserLevel level) {
    final progress = learnedCount / level.maxFrequency;
    final remaining = level.maxFrequency - learnedCount;

    if (progress < 0.3) {
      return '继续加油！每天学习几个新字，积少成多。';
    } else if (progress < 0.6) {
      return '已掌握 ${(progress * 100).toInt()}%！进入中级阶段。';
    } else if (progress < 1.0) {
      return '太棒了！再学 $remaining 个字就升级了！';
    } else {
      return '恭喜！你已完成 ${level.label}，可以挑战更高难度了！';
    }
  }

  /// 计算字族学习效率
  ///
  /// 学习一个声旁可以推导多个同族字，效率最高
  double calculateFamilyLearningEfficiency(Character char) {
    if (char.phonetic == null) return 0.0;
    // 预计同族字数量越多，效率越高
    // 实际实现在 getByPhonetic 后计算
    return char.frequency > 0 ? char.frequency / 100.0 : 0.5;
  }

  /// 获取下一步学习建议
  Future<String> getNextSuggestion({
    required int learnedCount,
    required int reviewCount,
    required int todayCompleted,
  }) async {
    // 检查是否应该复习
    if (reviewCount > 10 && todayCompleted < 5) {
      return '今天复习了不少内容，休息一下，明天继续学习新字！';
    }

    // 检查今日任务
    if (todayCompleted >= 10) {
      return '今日任务已完成！你可以继续复习已学内容，或者明天再来学习新字。';
    }

    // 学习建议
    if (learnedCount < 50) {
      return '建议先打牢基础，多学习常用字（高频字）。';
    } else if (learnedCount < 200) {
      return '开始关注字族学习，一个声旁可以帮你记住多个字！';
    } else if (learnedCount < 500) {
      return '试试在语境中学习，多读例句加深理解。';
    } else {
      return '你已经掌握了不少字！可以尝试自由探索，发现更多有趣的汉字规律。';
    }
  }
}
