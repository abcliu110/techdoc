import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/theme_field_repository.dart';
import '../models/theme_model.dart';
import '../models/theme_word_model.dart';
import '../../../data/models/models.dart';

/// 主题词场仓储 Provider
final themeFieldRepositoryProvider = Provider<ThemeFieldRepository>((ref) {
  return ThemeFieldRepository();
});

/// 所有主题列表 Provider
final allThemesProvider = FutureProvider<List<Theme>>((ref) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  return repo.getAllThemes();
});

/// 主题总数 Provider
final themeCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  return repo.getThemeCount();
});

/// 选中分类
final selectedThemeCategoryProvider = StateProvider<ThemeCategory?>((ref) => null);

/// 分类后的主题列表
final filteredThemesProvider = FutureProvider<List<Theme>>((ref) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  final category = ref.watch(selectedThemeCategoryProvider);

  if (category == null) {
    return repo.getAllThemes();
  }
  return repo.getThemesByCategory(category);
});

/// 单个主题详情
final themeDetailProvider = FutureProvider.family<Theme?, int>((ref, themeId) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  return repo.getThemeById(themeId);
});

/// 主题下的主题词列表
final themeWordsProvider = FutureProvider.family<List<ThemeWord>, int>((ref, themeId) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  return repo.getWordsByTheme(themeId);
});

/// 主题关联的汉字 ID 列表
final themeCharacterIdsProvider = FutureProvider.family<List<int>, int>((ref, themeId) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  return repo.getCharacterIdsByTheme(themeId);
});

/// 主题搜索查询
final themeSearchQueryProvider = StateProvider<String>((ref) => '');

/// 主题搜索结果
final themeSearchResultsProvider = FutureProvider<List<Theme>>((ref) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  final query = ref.watch(themeSearchQueryProvider);
  if (query.isEmpty) return [];
  return repo.searchThemes(query);
});

/// 当前选中的主题
final selectedThemeProvider = StateProvider<Theme?>((ref) => null);

/// 初始化主题数据
final initThemeDataProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(themeFieldRepositoryProvider);
  await repo.initPresetThemes();
});
