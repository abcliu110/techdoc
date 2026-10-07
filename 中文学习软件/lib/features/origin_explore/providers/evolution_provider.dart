import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/character.dart';
import '../data/origin_repository.dart';
import '../models/origin_models.dart';
import 'origin_explore_provider.dart';

/// 演变河流状态
class EvolutionRiverState {
  /// 当前选中的汉字
  final Character? selectedCharacter;
  /// 演变时代列表（用于横向滚动）
  final List<EvolutionNode> nodes;
  /// 是否加载中
  final bool isLoading;

  const EvolutionRiverState({
    this.selectedCharacter,
    this.nodes = const [],
    this.isLoading = false,
  });

  EvolutionRiverState copyWith({
    Character? selectedCharacter,
    List<EvolutionNode>? nodes,
    bool? isLoading,
  }) {
    return EvolutionRiverState(
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      nodes: nodes ?? this.nodes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 演变河流 Notifier
class EvolutionRiverNotifier extends StateNotifier<EvolutionRiverState> {
  final OriginRepository _repository;

  EvolutionRiverNotifier(this._repository)
      : super(const EvolutionRiverState());

  /// 加载汉字的演变路径
  Future<void> loadEvolutionPath(Character character) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _repository.exploreById(character.id);
      if (result != null && result.evolutionPath != null) {
        state = EvolutionRiverState(
          selectedCharacter: character,
          nodes: result.evolutionPath!.nodes,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          selectedCharacter: character,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        selectedCharacter: character,
        isLoading: false,
      );
    }
  }

  /// 切换选中汉字
  Future<void> selectCharacter(Character character) async {
    await loadEvolutionPath(character);
  }
}

/// 演变河流 Provider
final evolutionRiverProvider =
    StateNotifierProvider<EvolutionRiverNotifier, EvolutionRiverState>((ref) {
  final repository = ref.watch(originRepositoryProvider);
  return EvolutionRiverNotifier(repository);
});

/// 演变时代列表（静态配置）
const evolutionEras = [
  EvolutionEraInfo(
    era: EvolutionEra.jiaguwen,
    color: 0xFF8B4513,
    bgColor: 0xFFFFF8DC,
    description: '甲骨文',
  ),
  EvolutionEraInfo(
    era: EvolutionEra.jinwen,
    color: 0xFFB8860B,
    bgColor: 0xFFFFFAF0,
    description: '金文',
  ),
  EvolutionEraInfo(
    era: EvolutionEra.xiaozhuan,
    color: 0xFF2F4F4F,
    bgColor: 0xFFF5F5F5,
    description: '小篆',
  ),
  EvolutionEraInfo(
    era: EvolutionEra.modern,
    color: 0xFF4A90D9,
    bgColor: 0xFFE6F2FF,
    description: '现代',
  ),
];

/// 演变时代信息
class EvolutionEraInfo {
  final EvolutionEra era;
  final int color;
  final int bgColor;
  final String description;

  const EvolutionEraInfo({
    required this.era,
    required this.color,
    required this.bgColor,
    required this.description,
  });
}

