import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// 字卡学习状态
class LearningState {
  final bool isLoading;
  final List<int> taskChars; // 任务汉字 ID 列表
  final List<Character> characters; // 汉字详情列表
  final List<WordExample> wordExamples; // 当前汉字的例词
  final Character? currentChar;
  final int currentIndex;
  final int correctCount;
  final int wrongCount;
  final bool noTask; // 是否没有任务

  const LearningState({
    this.isLoading = true,
    this.taskChars = const [],
    this.characters = const [],
    this.wordExamples = const [],
    this.currentChar,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.noTask = false,
  });

  LearningState copyWith({
    bool? isLoading,
    List<int>? taskChars,
    List<Character>? characters,
    List<WordExample>? wordExamples,
    Character? currentChar,
    int? currentIndex,
    int? correctCount,
    int? wrongCount,
    bool? noTask,
  }) {
    return LearningState(
      isLoading: isLoading ?? this.isLoading,
      taskChars: taskChars ?? this.taskChars,
      characters: characters ?? this.characters,
      wordExamples: wordExamples ?? this.wordExamples,
      currentChar: currentChar ?? this.currentChar,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      noTask: noTask ?? this.noTask,
    );
  }
}

/// 字卡学习 Provider
final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  return LearningNotifier();
});

class LearningNotifier extends StateNotifier<LearningState> {
  final UserRepository _userRepo = UserRepository();
  final CharacterRepository _charRepo = CharacterRepository();

  LearningNotifier() : super(const LearningState()) {
    loadTask();
  }

  Future<void> loadTask() async {
    state = state.copyWith(isLoading: true);

    try {
      // 获取今日任务
      var task = await _userRepo.getTodayTask();

      // 如果没有今日任务，自动生成
      if (task == null || task.taskChars.isEmpty) {
        await _generateDailyTask();
        task = await _userRepo.getTodayTask();
      }

      if (task == null || task.taskChars.isEmpty) {
        // 没有可学习的汉字
        state = state.copyWith(isLoading: false, noTask: true);
        return;
      }

      // 获取汉字详情
      final characters = <Character>[];
      for (final charId in task!.taskChars) {
        final char = await _charRepo.getById(charId);
        if (char != null) {
          characters.add(char);
        }
      }

      // 获取第一个字的例词
      List<WordExample> examples = [];
      if (characters.isNotEmpty) {
        examples = await _charRepo.getWordExamples(characters.first.id);
      }

      state = state.copyWith(
        isLoading: false,
        taskChars: task.taskChars,
        characters: characters,
        currentChar: characters.isNotEmpty ? characters.first : null,
        wordExamples: examples,
        noTask: characters.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, noTask: true);
    }
  }

  /// 生成每日学习任务
  Future<void> _generateDailyTask() async {
    try {
      // 获取用户设置
      final settings = await _userRepo.getSettings();
      final dailyTarget = settings.dailyTarget;

      // 获取未学习的汉字
      final unlearnedChars = await _charRepo.getUnlearnedChars(dailyTarget);

      if (unlearnedChars.isNotEmpty) {
        final charIds = unlearnedChars.map((c) => c.id).toList();
        await _userRepo.createTodayTask(charIds);
      }
    } catch (e) {
      // 忽略错误
    }
  }

  Future<void> loadWordExamples(int charId) async {
    final examples = await _charRepo.getWordExamples(charId);
    state = state.copyWith(wordExamples: examples);
  }

  void updateProgress(bool correct) {
    state = state.copyWith(
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      wrongCount: correct ? state.wrongCount : state.wrongCount + 1,
    );
  }
}
