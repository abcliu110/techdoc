import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/character_family.dart';
import '../../../data/repositories/character_repository.dart';

/// 字族图谱状态
class FamilyState {
  final List<CharacterFamily> families;
  final CharacterFamily? selectedFamily;
  final List<int> memberIds; // 成员ID列表
  final bool isLoading;
  final String? error;

  const FamilyState({
    this.families = const [],
    this.selectedFamily,
    this.memberIds = const [],
    this.isLoading = false,
    this.error,
  });

  FamilyState copyWith({
    List<CharacterFamily>? families,
    CharacterFamily? selectedFamily,
    List<int>? memberIds,
    bool? isLoading,
    String? error,
  }) {
    return FamilyState(
      families: families ?? this.families,
      selectedFamily: selectedFamily ?? this.selectedFamily,
      memberIds: memberIds ?? this.memberIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 字族图谱 Provider
final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier();
});

class FamilyNotifier extends StateNotifier<FamilyState> {
  final CharacterRepository _charRepo = CharacterRepository();

  FamilyNotifier() : super(const FamilyState()) {
    loadFamilies();
  }

  /// 加载所有字族
  Future<void> loadFamilies() async {
    state = state.copyWith(isLoading: true);
    try {
      final families = await _charRepo.getAllFamilies();
      state = state.copyWith(families: families, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 选择字族
  Future<void> selectFamily(CharacterFamily family) async {
    state = state.copyWith(isLoading: true, selectedFamily: family);
    try {
      final members = await _charRepo.getFamilyMembers(family.id);
      state = state.copyWith(
        memberIds: members,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 按声旁搜索字族
  Future<void> searchByPhonetic(String phonetic) async {
    state = state.copyWith(isLoading: true);
    try {
      final family = await _charRepo.getFamilyByPhonetic(phonetic);
      if (family != null) {
        await selectFamily(family);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '未找到该声旁的字族',
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 清除选择
  void clearSelection() {
    state = FamilyState(families: state.families);
  }
}
