import 'package:equatable/equatable.dart';
import '../../../data/models/character.dart';

/// 演变时代枚举
enum EvolutionEra {
  /// 甲骨文 (商代晚期，约公元前1200年)
  jiaguwen('甲骨文', '商', 1),
  /// 金文 (商周时期，约公元前1100-公元前256年)
  jinwen('金文', '周', 2),
  /// 小篆 (秦代，约公元前221年)
  xiaozhuan('小篆', '秦', 3),
  /// 隶书 (汉代，约公元前206年-公元220年)
  lishu('隶书', '汉', 4),
  /// 楷书 (南北朝至唐代，约公元200-900年)
  kaishu('楷书', '唐', 5),
  /// 现代字形
  modern('现代', '今', 6);

  const EvolutionEra(this.label, this.dynasty, this.order);
  final String label; // 时代名称
  final String dynasty; // 朝代简称
  final int order; // 演变顺序
}

/// 演变节点 - 汉字在某一历史时期的字形
class EvolutionNode extends Equatable {
  /// 时代
  final EvolutionEra era;
  /// 字形（SVG路径或Unicode字符）
  final String? glyph;
  /// 字形来源说明
  final String? source;
  /// 字形描述
  final String? description;

  const EvolutionNode({
    required this.era,
    this.glyph,
    this.source,
    this.description,
  });

  @override
  List<Object?> get props => [era, glyph, source, description];
}

/// 演变路径 - 汉字从古至今的完整演变历程
class EvolutionPath extends Equatable {
  /// 现代字
  final String modernChar;
  /// 演变节点列表
  final List<EvolutionNode> nodes;
  /// 演变特征描述
  final String? evolutionFeature;
  /// 原始字义
  final String? originalMeaning;

  const EvolutionPath({
    required this.modernChar,
    required this.nodes,
    this.evolutionFeature,
    this.originalMeaning,
  });

  /// 从 Character 模型构建演变路径
  factory EvolutionPath.fromCharacter(Character char) {
    final nodes = <EvolutionNode>[];

    // 甲骨文
    if (char.originJiaguwen != null && char.originJiaguwen!.isNotEmpty) {
      nodes.add(EvolutionNode(
        era: EvolutionEra.jiaguwen,
        glyph: char.originJiaguwen,
        description: '甲骨文：${char.originalMeaning ?? ""}',
      ));
    }

    // 金文
    if (char.originJinwen != null && char.originJinwen!.isNotEmpty) {
      nodes.add(EvolutionNode(
        era: EvolutionEra.jinwen,
        glyph: char.originJinwen,
        description: '金文',
      ));
    }

    // 小篆
    if (char.originXiaozhuan != null && char.originXiaozhuan!.isNotEmpty) {
      nodes.add(EvolutionNode(
        era: EvolutionEra.xiaozhuan,
        glyph: char.originXiaozhuan,
        description: '小篆',
      ));
    }

    // 现代字形节点
    nodes.add(EvolutionNode(
      era: EvolutionEra.modern,
      glyph: char.character,
      description: '现代楷书',
    ));

    return EvolutionPath(
      modernChar: char.character,
      nodes: nodes,
      originalMeaning: char.originalMeaning,
    );
  }

  @override
  List<Object?> get props => [modernChar, nodes, evolutionFeature, originalMeaning];
}

/// 形声分析 - 形声字的声旁和形旁分析
class PhoneticAnalysis extends Equatable {
  /// 现代字
  final String character;
  /// 声旁字符
  final String? phoneticChar;
  /// 声旁读音
  final String? phoneticReading;
  /// 形旁字符
  final String? semanticChar;
  /// 形旁含义
  final String? semanticMeaning;
  /// 六书分类
  final SixBook? sixBook;
  /// 形声结构说明
  final String? structureNote;

  const PhoneticAnalysis({
    required this.character,
    this.phoneticChar,
    this.phoneticReading,
    this.semanticChar,
    this.semanticMeaning,
    this.sixBook,
    this.structureNote,
  });

  /// 从 Character 模型构建形声分析
  factory PhoneticAnalysis.fromCharacter(Character char) {
    String? note;
    if (char.sixBook == SixBook.phonetic) {
      final phonetic = char.phonetic ?? '';
      final semantic = char.semantic ?? '';
      if (phonetic.isNotEmpty && semantic.isNotEmpty) {
        note = '由"$semantic"（形旁）+ "$phonetic"（声旁）组成';
      }
    }

    return PhoneticAnalysis(
      character: char.character,
      phoneticChar: char.phonetic,
      phoneticReading: char.phonetic != null ? _getPhoneticReading(char.phonetic!) : null,
      semanticChar: char.semantic,
      semanticMeaning: _getSemanticMeaning(char.semantic),
      sixBook: char.sixBook,
      structureNote: note,
    );
  }

  /// 获取声旁读音（简化版，实际应查表）
  static String? _getPhoneticReading(String phoneticChar) {
    // 这里可以扩展为查表获取声旁的读音
    return null;
  }

  /// 获取形旁含义（简化版，实际应查表）
  static String? _getSemanticMeaning(String? semanticChar) {
    if (semanticChar == null) return null;
    // 常见形旁含义表
    final meanings = {
      '氵': '与水有关',
      '扌': '与手部动作有关',
      '木': '与树木、植物有关',
      '火': '与火、热量有关',
      '土': '与土地、泥土有关',
      '金': '与金属、坚硬有关',
      '口': '与口部、说话有关',
      '心': '与心理、情感有关',
      '女': '与女性有关',
      '子': '与小孩、后代有关',
      '宀': '与房屋、覆盖有关',
      '艹': '与植物、草木有关',
      '月': '与肉体、月亮有关',
      '目': '与眼睛、观看有关',
      '足': '与脚、行走有关',
      '言': '与言语、谈论有关',
      '走': '与行走、奔跑有关',
      '车': '与车辆、交通有关',
      '阝': '与地区、城邦有关',
      '忄': '与心理、情感有关',
      '礻': '与祭祀、神灵有关',
      '衤': '与衣物有关',
      '饣': '与食物有关',
      '马': '与马匹、奔跑有关',
      '鱼': '与鱼类有关',
      '鸟': '与鸟类有关',
      '虫': '与昆虫、爬行有关',
      '贝': '与钱财、贸易有关',
      '刂': '与刀、切割有关',
      '刀': '与刀、切割有关',
      '冫': '与冰、冷有关',
      '灬': '与火、烹煮有关',
      '疒': '与疾病有关',
      '癶': '与足、行走有关',
      '夂': '与脚步、到来有关',
      '攵': '与敲击、动作有关',
      '攴': '与敲击、动作有关',
      '殳': '与击打、兵器有关',
      '瓦': '与陶器、瓦片有关',
      '气': '与气体、气息有关',
      '毛': '与毛发、粗糙有关',
      '片': '与木板、片状有关',
      '斤': '与斧头、砍削有关',
      '斗': '与容器、度量有关',
      '耒': '与农具、耕作有关',
      '矛': '与兵器、刺杀有关',
      '耓': '与农具有关',
    };
    return meanings[semanticChar];
  }

  @override
  List<Object?> get props => [
        character,
        phoneticChar,
        phoneticReading,
        semanticChar,
        semanticMeaning,
        sixBook,
        structureNote,
      ];
}

/// 字源探索结果
class OriginExploreResult extends Equatable {
  /// 现代汉字
  final Character character;
  /// 演变路径
  final EvolutionPath? evolutionPath;
  /// 形声分析
  final PhoneticAnalysis? phoneticAnalysis;
  /// 相关字列表（同声旁或同形旁）
  final List<Character> relatedCharacters;

  const OriginExploreResult({
    required this.character,
    this.evolutionPath,
    this.phoneticAnalysis,
    this.relatedCharacters = const [],
  });

  @override
  List<Object?> get props => [character, evolutionPath, phoneticAnalysis, relatedCharacters];
}
