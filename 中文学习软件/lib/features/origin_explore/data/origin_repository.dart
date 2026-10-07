import '../../../data/models/character.dart';
import '../../../data/repositories/character_repository.dart';
import '../models/origin_models.dart';

/// 字源探索数据仓库
class OriginRepository {
  final CharacterRepository _characterRepo = CharacterRepository();

  /// 根据汉字获取完整的字源探索数据
  Future<OriginExploreResult?> exploreByCharacter(String char) async {
    final character = await _characterRepo.getByCharacter(char);
    if (character == null) return null;

    return exploreById(character.id);
  }

  /// 根据ID获取完整的字源探索数据
  Future<OriginExploreResult?> exploreById(int id) async {
    final character = await _characterRepo.getById(id);
    if (character == null) return null;

    // 构建演变路径
    final evolutionPath = EvolutionPath.fromCharacter(character);

    // 构建形声分析
    PhoneticAnalysis? phoneticAnalysis;
    if (character.sixBook == SixBook.phonetic ||
        character.phonetic != null ||
        character.semantic != null) {
      phoneticAnalysis = PhoneticAnalysis.fromCharacter(character);
    }

    // 获取相关字
    final relatedCharacters = await _getRelatedCharacters(character);

    return OriginExploreResult(
      character: character,
      evolutionPath: evolutionPath,
      phoneticAnalysis: phoneticAnalysis,
      relatedCharacters: relatedCharacters,
    );
  }

  /// 获取相关字（同声旁或同形旁的字）
  Future<List<Character>> _getRelatedCharacters(Character char) async {
    final List<Character> related = [];

    // 找同声旁的字
    if (char.phonetic != null && char.phonetic!.isNotEmpty) {
      related.addAll(
        await _characterRepo.getByPhonetic(char.phonetic!),
      );
    }

    // 找同形旁的字
    if (char.semantic != null && char.semantic!.isNotEmpty) {
      // 搜索具有相同形旁的形声字
      final allChars = await _getCharactersBySemantic(char.semantic!);
      related.addAll(allChars);
    }

    // 去重（基于id）
    final uniqueMap = <int, Character>{};
    for (final c in related) {
      uniqueMap[c.id] = c;
    }

    // 排除自身
    uniqueMap.remove(char.id);

    // 按频率排序，取前20个
    final result = uniqueMap.values.toList()
      ..sort((a, b) => a.frequency.compareTo(b.frequency));
    return result.take(20).toList();
  }

  /// 根据形旁获取汉字
  Future<List<Character>> _getCharactersBySemantic(String semantic) async {
    // 这里需要直接从数据库查询，因为 CharacterRepository 没有这个方法
    // 暂时通过部首查询来实现
    final chars = await _characterRepo.getHighFrequencyChars(500);
    return chars.where((c) {
      // 检查字的组成部分是否包含该形旁
      if (c.character.contains(semantic)) return true;
      // 检查声旁的形旁（简化判断）
      if (c.semantic == semantic) return true;
      return false;
    }).toList();
  }

  /// 搜索具有演变数据的汉字
  Future<List<Character>> searchWithEvolutionData({int limit = 100}) async {
    final chars = await _characterRepo.getHighFrequencyChars(limit);
    return chars.where((c) {
      return c.originJiaguwen != null ||
          c.originJinwen != null ||
          c.originXiaozhuan != null;
    }).toList();
  }

  /// 搜索形声字
  Future<List<Character>> searchPhoneticCharacters({int limit = 100}) async {
    final chars = await _characterRepo.getPhoneticChars(limit);
    return chars.where((c) {
      return c.phonetic != null || c.semantic != null;
    }).toList();
  }

  /// 获取演变数据统计
  Future<Map<String, int>> getEvolutionStats() async {
    final chars = await _characterRepo.getHighFrequencyChars(500);
    int withJiaguwen = 0;
    int withJinwen = 0;
    int withXiaozhuan = 0;

    for (final c in chars) {
      if (c.originJiaguwen != null && c.originJiaguwen!.isNotEmpty) {
        withJiaguwen++;
      }
      if (c.originJinwen != null && c.originJinwen!.isNotEmpty) {
        withJinwen++;
      }
      if (c.originXiaozhuan != null && c.originXiaozhuan!.isNotEmpty) {
        withXiaozhuan++;
      }
    }

    return {
      'jiaguwen': withJiaguwen,
      'jinwen': withJinwen,
      'xiaozhuan': withXiaozhuan,
      'total': chars.length,
    };
  }

  /// 获取具有演变路径的推荐汉字
  Future<List<Character>> getRecommendedForEvolution({int limit = 10}) async {
    // 推荐具有完整演变路径的高频字
    final chars = await _characterRepo.getHighFrequencyChars(200);
    return chars.where((c) {
      // 选择有演变数据的字
      final hasEvolution =
          c.originJiaguwen != null ||
          c.originJinwen != null ||
          c.originXiaozhuan != null;
      // 选择形声字（便于形声分析）
      final isPhonetic = c.sixBook == SixBook.phonetic;
      return hasEvolution || isPhonetic;
    }).take(limit).toList();
  }
}
