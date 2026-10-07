import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// 首页状态
class HomeState {
  final bool isLoading;
  final DailyTask? todayTask;
  final UserSettings settings;
  final int learnedCount;
  final int masteredCount;
  final List<bool> weekStatus;

  const HomeState({
    this.isLoading = true,
    this.todayTask,
    this.settings = const UserSettings(),
    this.learnedCount = 0,
    this.masteredCount = 0,
    this.weekStatus = const [false, false, false, false, false, false, false],
  });

  int get todayWeekday => DateTime.now().weekday;

  HomeState copyWith({
    bool? isLoading,
    DailyTask? todayTask,
    UserSettings? settings,
    int? learnedCount,
    int? masteredCount,
    List<bool>? weekStatus,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      todayTask: todayTask ?? this.todayTask,
      settings: settings ?? this.settings,
      learnedCount: learnedCount ?? this.learnedCount,
      masteredCount: masteredCount ?? this.masteredCount,
      weekStatus: weekStatus ?? this.weekStatus,
    );
  }
}

/// 首页 Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

class HomeNotifier extends StateNotifier<HomeState> {
  final UserRepository _userRepo = UserRepository();
  final CharacterRepository _charRepo = CharacterRepository();

  HomeNotifier() : super(const HomeState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      // 并行加载数据
      final results = await Future.wait([
        _userRepo.getSettings(),
        _userRepo.getTodayTask(),
        _userRepo.getLearnedCount(),
        _userRepo.getWeekTasks(),
      ]);

      final settings = results[0] as UserSettings;
      final todayTask = results[1] as DailyTask?;
      final learnedCount = results[2] as int;
      final weekTasks = results[3] as List<DailyTask>;

      // 构建本周学习状态
      final weekStatus = List<bool>.filled(7, false);

      for (final task in weekTasks) {
        final taskDate = DateTime.parse(task.taskDate);
        final dayIndex = taskDate.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7 && task.completedCount > 0) {
          weekStatus[dayIndex] = true;
        }
      }

      // 如果今日任务为空，创建新任务
      DailyTask? taskToUse = todayTask;
      if (taskToUse == null) {
        taskToUse = await _createTodayTask(settings.dailyTarget);
      }

      state = state.copyWith(
        isLoading: false,
        settings: settings,
        todayTask: taskToUse,
        learnedCount: learnedCount,
        weekStatus: weekStatus,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<DailyTask> _createTodayTask(int targetCount) async {
    // 获取未学习的汉字
    final unlearnedChars = await _charRepo.getUnlearnedChars(targetCount);
    final charIds = unlearnedChars.map((c) => c.id).toList();
    return await _userRepo.createTodayTask(charIds);
  }

  Future<void> refresh() async {
    await loadData();
  }
}
