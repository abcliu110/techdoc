import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/character.dart';
import '../data/origin_repository.dart';
import '../models/origin_models.dart';

/// 字源探索仓库 Provider
final originRepositoryProvider = Provider<OriginRepository>((ref) {
  return OriginRepository();
});

/// 当前探索的汉字
final currentCharacterProvider = StateProvider<Character?>((ref) => null);

/// 字源探索结果状态
class OriginExploreState {
  /// 探索结果
  final OriginExploreResult? result;
  /// 是否加载中
  final bool isLoading;
  /// 错误信息
  final String? error;

  const OriginExploreState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  OriginExploreState copyWith({
    OriginExploreResult? result,
    bool? isLoading,
    String? error,
  }) {
    return OriginExploreState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 字源探索 Notifier
class OriginExploreNotifier extends StateNotifier<OriginExploreState> {
  final OriginRepository _repository;

  OriginExploreNotifier(this._repository) : super(const OriginExploreState());

  /// 根据汉字探索
  Future<void> exploreByCharacter(String char) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.exploreByCharacter(char);
      if (result != null) {
        state = OriginExploreState(result: result);
      } else {
        state = state.copyWith(isLoading: false, error: '未找到汉字 "$char" 的字源数据');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '探索失败: $e');
    }
  }

  /// 根据ID探索
  Future<void> exploreById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.exploreById(id);
      if (result != null) {
        state = OriginExploreState(result: result);
      } else {
        state = state.copyWith(isLoading: false, error: '未找到该汉字的字源数据');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '探索失败: $e');
    }
  }

  /// 清空结果
  void clear() {
    state = const OriginExploreState();
  }
}

/// 字源探索 Provider
final originExploreProvider =
    StateNotifierProvider<OriginExploreNotifier, OriginExploreState>((ref) {
  final repository = ref.watch(originRepositoryProvider);
  return OriginExploreNotifier(repository);
});

/// 演变路径列表 Provider（用于演变河流页面）
final evolutionPathListProvider =
    FutureProvider<List<Character>>((ref) async {
  final repository = ref.watch(originRepositoryProvider);
  return repository.getRecommendedForEvolution(limit: 20);
});

/// 演变数据统计 Provider
final evolutionStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(originRepositoryProvider);
  return repository.getEvolutionStats();
});

/// 搜索建议列表 Provider
final searchSuggestionProvider =
    FutureProvider.family<List<Character>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(originRepositoryProvider);
  // 搜索具有演变数据的汉字
  final allChars = await repository.searchWithEvolutionData(limit: 100);
  // 过滤匹配的字
  return allChars.where((c) {
    return c.character.contains(query) ||
        c.pinyin.startsWith(query) ||
        c.pinyin.contains(query);
  }).take(10).toList();
});
