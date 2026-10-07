import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/similar_char_data.dart';
import '../models/similar_char_model.dart';

/// 形近字列表状态
class SimilarCharListState {
  final List<SimilarCharGroup> groups;
  final List<SimilarCharGroup> filteredGroups;
  final bool isLoading;
  final String? error;
  final String searchKeyword;
  final String? difficultyFilter;
  final String? categoryFilter;

  const SimilarCharListState({
    this.groups = const [],
    this.filteredGroups = const [],
    this.isLoading = false,
    this.error,
    this.searchKeyword = '',
    this.difficultyFilter,
    this.categoryFilter,
  });

  SimilarCharListState copyWith({
    List<SimilarCharGroup>? groups,
    List<SimilarCharGroup>? filteredGroups,
    bool? isLoading,
    String? error,
    String? searchKeyword,
    String? difficultyFilter,
    String? categoryFilter,
  }) {
    return SimilarCharListState(
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      difficultyFilter: difficultyFilter,
      categoryFilter: categoryFilter,
    );
  }
}

/// 形近字列表 Provider
final similarCharListProvider = StateNotifierProvider<SimilarCharListNotifier, SimilarCharListState>((ref) {
  return SimilarCharListNotifier();
});

class SimilarCharListNotifier extends StateNotifier<SimilarCharListState> {
  SimilarCharListNotifier() : super(const SimilarCharListState(isLoading: true)) {
    loadGroups();
  }

  /// 加载所有形近字组
  Future<void> loadGroups() async {
    try {
      state = state.copyWith(isLoading: true);
      final groups = SimilarCharData.getAllGroups();
      state = state.copyWith(
        groups: groups,
        filteredGroups: groups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 搜索形近字组
  void search(String keyword) {
    final filtered = SimilarCharData.search(keyword);
    state = state.copyWith(
      searchKeyword: keyword,
      filteredGroups: _applyFilters(filtered),
    );
  }

  /// 按难度筛选
  void filterByDifficulty(String? difficulty) {
    state = state.copyWith(
      difficultyFilter: difficulty,
      filteredGroups: _applyFilters(state.groups),
    );
  }

  /// 按分类筛选
  void filterByCategory(String? category) {
    state = state.copyWith(
      categoryFilter: category,
      filteredGroups: _applyFilters(state.groups),
    );
  }

  /// 应用所有筛选条件
  List<SimilarCharGroup> _applyFilters(List<SimilarCharGroup> groups) {
    var result = groups;

    // 应用难度筛选
    if (state.difficultyFilter != null && state.difficultyFilter!.isNotEmpty) {
      result = result.where((g) => g.difficultyLevel == state.difficultyFilter).toList();
    }

    // 应用分类筛选
    if (state.categoryFilter != null && state.categoryFilter!.isNotEmpty) {
      result = result.where((g) => g.category == state.categoryFilter).toList();
    }

    // 应用搜索关键词
    if (state.searchKeyword.isNotEmpty) {
      final kw = state.searchKeyword.toLowerCase();
      result = result.where((g) {
        if (g.groupName.toLowerCase().contains(kw)) return true;
        if (g.characters.any((c) => c.character.contains(kw))) return true;
        if (g.description.toLowerCase().contains(kw)) return true;
        return false;
      }).toList();
    }

    return result;
  }

  /// 清除所有筛选
  void clearFilters() {
    state = state.copyWith(
      searchKeyword: '',
      difficultyFilter: null,
      categoryFilter: null,
      filteredGroups: state.groups,
    );
  }

  /// 切换收藏状态
  void toggleFavorite(int groupId) {
    final updatedGroups = state.groups.map((g) {
      if (g.id == groupId) {
        return g.copyWith(isFavorite: !g.isFavorite);
      }
      return g;
    }).toList();

    state = state.copyWith(
      groups: updatedGroups,
      filteredGroups: _applyFilters(updatedGroups),
    );
  }
}

/// 当前选中的形近字组
final currentGroupProvider = StateProvider<SimilarCharGroup?>((ref) => null);

/// 当前正在查看的字符索引
final currentCharIndexProvider = StateProvider<int>((ref) => 0);

/// 练习状态
class PracticeState {
  final List<SimilarCharGroup> practiceGroups;
  final List<PracticeQuestion> questions;
  final int currentIndex;
  final int correctCount;
  final int wrongCount;
  final bool isFinished;
  final bool showAnswer;

  const PracticeState({
    this.practiceGroups = const [],
    this.questions = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.isFinished = false,
    this.showAnswer = false,
  });

  PracticeState copyWith({
    List<SimilarCharGroup>? practiceGroups,
    List<PracticeQuestion>? questions,
    int? currentIndex,
    int? correctCount,
    int? wrongCount,
    bool? isFinished,
    bool? showAnswer,
  }) {
    return PracticeState(
      practiceGroups: practiceGroups ?? this.practiceGroups,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isFinished: isFinished ?? this.isFinished,
      showAnswer: showAnswer ?? this.showAnswer,
    );
  }

  /// 获取当前题目
  PracticeQuestion? get currentQuestion {
    if (questions.isEmpty || currentIndex >= questions.length) return null;
    return questions[currentIndex];
  }

  /// 获取正确率
  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 0;
    return correctCount / total;
  }

  /// 获取总题数
  int get totalQuestions => questions.length;

  /// 获取已答题数
  int get answeredCount => currentIndex;
}

/// 练习题实体
class PracticeQuestion {
  final SimilarCharGroup group;
  final PracticeMode mode;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String? explanation;

  const PracticeQuestion({
    required this.group,
    required this.mode,
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.explanation,
  });
}

/// 练习模式枚举
enum PracticeMode {
  /// 辨识练习：给定拼音，选出正确的字
  identify('辨识练习', '给出拼音，选出正确的字'),

  /// 填空练习：给出词语，填入正确的字
  fill('填空练习', '给出词语，填入正确的字'),

  /// 找茬练习：从多字中找出指定的形近字
  find('找茬练习', '从多字中找出指定的形近字');

  const PracticeMode(this.label, this.description);
  final String label;
  final String description;
}

/// 练习 Provider
final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeState>((ref) {
  return PracticeNotifier();
});

class PracticeNotifier extends StateNotifier<PracticeState> {
  PracticeNotifier() : super(const PracticeState());

  /// 生成练习题
  void generateQuestions({
    required List<SimilarCharGroup> groups,
    required PracticeMode mode,
    int count = 10,
  }) {
    final questions = <PracticeQuestion>[];
    final selectedGroups = groups.take(count).toList();

    for (final group in selectedGroups) {
      switch (mode) {
        case PracticeMode.identify:
          // 辨识练习：选择一个字符，生成题目
          for (final char in group.chars) {
            if (char.exampleWords.isNotEmpty) {
              final wrongOptions = group.chars
                  .where((c) => c.character != char.character)
                  .map((c) => c.character)
                  .toList();
              questions.add(PracticeQuestion(
                group: group,
                mode: mode,
                question: '选出"${char.exampleWords.first}"的正确汉字',
                correctAnswer: char.character,
                options: _shuffleOptions([char.character, ...wrongOptions]),
                explanation: char.highlightInfo,
              ));
            }
          }
          break;

        case PracticeMode.fill:
          // 填空练习：选择一个词语，生成题目
          for (final char in group.chars) {
            if (char.exampleWords.isNotEmpty) {
              final word = char.exampleWords.first;
              final wrongOptions = group.chars
                  .where((c) => c.character != char.character)
                  .map((c) => c.character)
                  .toList();
              questions.add(PracticeQuestion(
                group: group,
                mode: mode,
                question: '在括号中填入正确的字：$word'.replaceFirst(char.character, '（  ）'),
                correctAnswer: char.character,
                options: _shuffleOptions([char.character, ...wrongOptions]),
                explanation: char.highlightInfo,
              ));
            }
          }
          break;

        case PracticeMode.find:
          // 找茬练习：显示多个字，找出指定的
          for (final char in group.chars) {
            final displayChars = <String>[char.character];
            // 添加其他字符
            for (final c in group.chars) {
              if (c.character != char.character && displayChars.length < 6) {
                displayChars.add(c.character);
              }
            }
            // 随机添加一些其他字符
            while (displayChars.length < 6) {
              displayChars.add(group.chars.first.character);
            }
            questions.add(PracticeQuestion(
              group: group,
              mode: mode,
              question: '在下面找到"${char.character}"字（${char.pinyin}）',
              correctAnswer: char.character,
              options: _shuffleOptions(displayChars),
              explanation: char.highlightInfo,
            ));
          }
          break;
      }
    }

    // 打乱题目顺序并限制数量
    questions.shuffle();

    state = state.copyWith(
      practiceGroups: groups,
      questions: questions.take(count * 2).toList(),
      currentIndex: 0,
      correctCount: 0,
      wrongCount: 0,
      isFinished: false,
      showAnswer: false,
    );
  }

  /// 回答问题
  void answer(String answer) {
    final currentQ = state.currentQuestion;
    if (currentQ == null) return;

    final isCorrect = answer == currentQ.correctAnswer;

    state = state.copyWith(
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      wrongCount: isCorrect ? state.wrongCount : state.wrongCount + 1,
      showAnswer: true,
    );
  }

  /// 下一题
  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showAnswer: false,
      );
    } else {
      state = state.copyWith(isFinished: true);
    }
  }

  /// 重置练习
  void reset() {
    state = const PracticeState();
  }
}

/// 打乱选项顺序
List<String> _shuffleOptions(List<String> options) {
  final shuffled = List<String>.from(options);
  shuffled.shuffle();
  return shuffled;
}
