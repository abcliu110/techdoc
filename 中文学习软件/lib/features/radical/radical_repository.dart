import 'data/radical_data.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/character_repository.dart';
import 'models/radical_model.dart';

/// 部首仓储层
class RadicalRepository {
  final CharacterRepository _characterRepo = CharacterRepository();

  /// 获取所有部首分组（按笔画数）
  List<RadicalGroup> getAllRadicalGroups() {
    final Map<int, List<Radical>> groups = {};
    final allRadicals = RadicalData.getAllRadicals();

    for (final entry in allRadicals.entries) {
      final strokes = entry.key;
      final radicals = entry.value.map((r) => Radical(
        character: r.character,
        name: r.name,
        strokes: r.strokes,
        position: r.position,
        description: r.description,
      )).toList();

      groups[strokes] = radicals;
    }

    return groups.entries
        .map((e) => RadicalGroup(strokes: e.key, radicals: e.value))
        .toList()
      ..sort((a, b) => a.strokes.compareTo(b.strokes));
  }

  /// 获取部首详细信息
  Radical? getRadicalInfo(String character) {
    return RadicalData.getByCharacter(character);
  }

  /// 获取某部首下的所有汉字
  Future<List<Character>> getCharactersByRadical(String radical) async {
    return await _characterRepo.searchByRadical(radical);
  }

  /// 获取部首统计信息
  Future<List<RadicalStats>> getRadicalStats() async {
    final groups = getAllRadicalGroups();
    final List<RadicalStats> stats = [];

    for (final group in groups) {
      for (final radical in group.radicals) {
        final chars = await _characterRepo.searchByRadical(radical.character);
        if (chars.isNotEmpty) {
          stats.add(RadicalStats(
            radical: radical.character,
            count: chars.length,
            examples: chars.take(6).toList(),
          ));
        }
      }
    }

    return stats;
  }

  /// 搜索包含某汉字的部首
  List<Radical> searchRadicals(String query) {
    if (query.isEmpty) return [];

    final List<Radical> results = [];
    final allRadicals = RadicalData.getAllRadicals();

    for (final group in allRadicals.values) {
      for (final radical in group) {
        // 按部首字符搜索
        if (radical.character.contains(query)) {
          results.add(radical);
        }
        // 按部首名称搜索
        else if (radical.name.contains(query)) {
          results.add(radical);
        }
      }
    }

    return results;
  }

  /// 获取部首总数
  int get totalRadicalCount => RadicalData.totalCount;

  /// 获取有汉字的部首数
  Future<int> getActiveRadicalCount() async {
    final stats = await getRadicalStats();
    return stats.length;
  }
}
