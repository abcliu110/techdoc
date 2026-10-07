import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/favorite_repository.dart';

/// 收藏仓库 Provider
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

/// 收藏列表状态
class FavoriteListState {
  final List<Character> characters;
  final FavoriteStats stats;
  final FavoriteFilter filter;
  final bool isLoading;
  final String? error;

  const FavoriteListState({
    this.characters = const [],
    this.stats = const FavoriteStats(),
    this.filter = const FavoriteFilter(),
    this.isLoading = false,
    this.error,
  });

  FavoriteListState copyWith({
    List<Character>? characters,
    FavoriteStats? stats,
    FavoriteFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteListState(
      characters: characters ?? this.characters,
      stats: stats ?? this.stats,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 收藏列表 Provider
final favoriteListProvider =
    StateNotifierProvider<FavoriteListNotifier, FavoriteListState>((ref) {
  return FavoriteListNotifier(ref.watch(favoriteRepositoryProvider));
});

/// 收藏列表 Notifier
class FavoriteListNotifier extends StateNotifier<FavoriteListState> {
  final FavoriteRepository _repository;

  FavoriteListNotifier(this._repository) : super(const FavoriteListState()) {
    loadFavorites();
  }

  /// 加载收藏列表
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final characters = await _repository.getFavoriteCharacters(
        filter: state.filter,
      );
      final stats = await _repository.getStats();
      state = state.copyWith(
        characters: characters,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载收藏列表失败: $e',
      );
    }
  }

  /// 刷新列表
  Future<void> refresh() async {
    await loadFavorites();
  }

  /// 更新筛选条件
  Future<void> updateFilter(FavoriteFilter filter) async {
    state = state.copyWith(filter: filter);
    await loadFavorites();
  }

  /// 按难度筛选
  Future<void> filterByLevels(List<int> levels) async {
    final newFilter = state.filter.copyWith(levels: levels);
    await updateFilter(newFilter);
  }

  /// 按学习状态筛选
  Future<void> filterByStatuses(List<String> statuses) async {
    final newFilter = state.filter.copyWith(statuses: statuses);
    await updateFilter(newFilter);
  }

  /// 按主题筛选
  Future<void> filterByTheme(String? themeId) async {
    final newFilter = state.filter.copyWith(themeId: themeId);
    await updateFilter(newFilter);
  }

  /// 更新排序方式
  Future<void> updateSortOrder(FavoriteSortOrder sortOrder) async {
    final newFilter = state.filter.copyWith(sortOrder: sortOrder);
    await updateFilter(newFilter);
  }

  /// 重置筛选
  Future<void> resetFilter() async {
    state = state.copyWith(filter: const FavoriteFilter());
    await loadFavorites();
  }
}

/// 单个汉字收藏状态
class CharacterFavoriteState {
  final int characterId;
  final bool isFavorited;
  final bool isLoading;

  const CharacterFavoriteState({
    required this.characterId,
    this.isFavorited = false,
    this.isLoading = false,
  });

  CharacterFavoriteState copyWith({
    int? characterId,
    bool? isFavorited,
    bool? isLoading,
  }) {
    return CharacterFavoriteState(
      characterId: characterId ?? this.characterId,
      isFavorited: isFavorited ?? this.isFavorited,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 单个汉字收藏状态 Provider
final characterFavoriteProvider = StateNotifierProvider.family<
    CharacterFavoriteNotifier, CharacterFavoriteState, int>((ref, characterId) {
  return CharacterFavoriteNotifier(
    ref.watch(favoriteRepositoryProvider),
    characterId,
  );
});

/// 单个汉字收藏状态 Notifier
class CharacterFavoriteNotifier extends StateNotifier<CharacterFavoriteState> {
  final FavoriteRepository _repository;

  CharacterFavoriteNotifier(this._repository, int characterId)
      : super(CharacterFavoriteState(characterId: characterId)) {
    _checkFavoriteStatus();
  }

  /// 检查收藏状态
  Future<void> _checkFavoriteStatus() async {
    state = state.copyWith(isLoading: true);
    final isFavorited = await _repository.isFavorited(state.characterId);
    state = state.copyWith(isFavorited: isFavorited, isLoading: false);
  }

  /// 切换收藏状态
  Future<bool> toggle() async {
    state = state.copyWith(isLoading: true);
    final newStatus = await _repository.toggleFavorite(state.characterId);
    state = state.copyWith(isFavorited: newStatus, isLoading: false);
    return newStatus;
  }

  /// 添加收藏
  Future<void> add() async {
    if (state.isFavorited) return;
    state = state.copyWith(isLoading: true);
    await _repository.addFavorite(state.characterId);
    state = state.copyWith(isFavorited: true, isLoading: false);
  }

  /// 取消收藏
  Future<void> remove() async {
    if (!state.isFavorited) return;
    state = state.copyWith(isLoading: true);
    await _repository.removeFavorite(state.characterId);
    state = state.copyWith(isFavorited: false, isLoading: false);
  }
}

/// 收藏统计 Provider
final favoriteStatsProvider = FutureProvider<FavoriteStats>((ref) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  return repository.getStats();
});
