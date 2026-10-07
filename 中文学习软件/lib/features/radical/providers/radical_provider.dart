import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../radical_repository.dart';
import '../data/radical_data.dart';
import '../models/radical_model.dart';
import '../../../data/models/models.dart';

/// 部首仓储 Provider
final radicalRepositoryProvider = Provider<RadicalRepository>((ref) {
  return RadicalRepository();
});

/// 所有部首分组 Provider
final radicalGroupsProvider = FutureProvider<List<RadicalGroup>>((ref) async {
  final repo = ref.watch(radicalRepositoryProvider);
  return repo.getAllRadicalGroups();
});

/// 部首统计信息 Provider
final radicalStatsProvider = FutureProvider<List<RadicalStats>>((ref) async {
  final repo = ref.watch(radicalRepositoryProvider);
  return repo.getRadicalStats();
});

/// 当前选中的部首
final selectedRadicalProvider = StateProvider<Radical?>((ref) => null);

/// 搜索查询
final radicalSearchQueryProvider = StateProvider<String>((ref) => '');

/// 搜索结果
final radicalSearchResultsProvider = FutureProvider<List<Radical>>((ref) async {
  final query = ref.watch(radicalSearchQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(radicalRepositoryProvider);
  return repo.searchRadicals(query);
});

/// 某部首下的汉字列表
final radicalCharactersProvider = FutureProvider.family<List<Character>, String>((ref, radical) async {
  final repo = ref.watch(radicalRepositoryProvider);
  return repo.getCharactersByRadical(radical);
});

/// 活跃部首数（有汉字的部首）
final activeRadicalCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(radicalRepositoryProvider);
  return repo.getActiveRadicalCount();
});

/// 选中Tab索引
final radicalTabIndexProvider = StateProvider<int>((ref) => 0);

/// 部首数据访问
class RadicalNotifier extends StateNotifier<List<RadicalGroup>> {
  final RadicalRepository _repo;

  RadicalNotifier(this._repo) : super([]) {
    _loadRadicals();
  }

  void _loadRadicals() {
    state = _repo.getAllRadicalGroups();
  }

  /// 搜索部首
  List<Radical> search(String query) {
    return _repo.searchRadicals(query);
  }
}

/// 部首通知器 Provider
final radicalNotifierProvider = StateNotifierProvider<RadicalNotifier, List<RadicalGroup>>((ref) {
  final repo = ref.watch(radicalRepositoryProvider);
  return RadicalNotifier(repo);
});
