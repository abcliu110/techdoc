import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/character.dart';
import '../../../data/repositories/character_repository.dart';

/// 六书分类状态
class SixBookState {
  final List<SixBookCategory> categories;
  final SixBook? selectedCategory;
  final List<Character> characters;
  final bool isLoading;
  final String? error;

  const SixBookState({
    this.categories = const [],
    this.selectedCategory,
    this.characters = const [],
    this.isLoading = false,
    this.error,
  });

  SixBookState copyWith({
    List<SixBookCategory>? categories,
    SixBook? selectedCategory,
    List<Character>? characters,
    bool? isLoading,
    String? error,
  }) {
    return SixBookState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      characters: characters ?? this.characters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 六书分类信息
class SixBookCategory {
  final SixBook type;
  final String description;
  final String example;
  final int charCount;

  const SixBookCategory({
    required this.type,
    required this.description,
    required this.example,
    required this.charCount,
  });
}

/// 六书字典 Provider
final sixBookProvider = StateNotifierProvider<SixBookNotifier, SixBookState>((ref) {
  return SixBookNotifier();
});

class SixBookNotifier extends StateNotifier<SixBookState> {
  final CharacterRepository _charRepo = CharacterRepository();

  SixBookNotifier() : super(const SixBookState()) {
    _initCategories();
    // 异步刷新分类数量
    refreshCounts();
  }

  /// 初始化六书分类
  void _initCategories() {
    final categories = [
      SixBookCategory(
        type: SixBook.pictogram,
        description: '画物象之形，建立形-物联结',
        example: '日、月、山、水、人、口',
        charCount: 0,
      ),
      SixBookCategory(
        type: SixBook.indicative,
        description: '符号指示抽象概念',
        example: '上、下、本、末、刃、甘',
        charCount: 0,
      ),
      SixBookCategory(
        type: SixBook.associative,
        description: '两形或多形合体表意',
        example: '明、武、休、众、森',
        charCount: 0,
      ),
      SixBookCategory(
        type: SixBook.phonetic,
        description: '形旁+声旁，批量学习核心',
        example: '江、河、晴、清、情',
        charCount: 0,
      ),
      SixBookCategory(
        type: SixBook.mutual,
        description: '同义字互训',
        example: '考=老、顶=巅',
        charCount: 0,
      ),
      SixBookCategory(
        type: SixBook.phoneticLoan,
        description: '同音字借用',
        example: '莫→暮、其→箕',
        charCount: 0,
      ),
    ];
    state = state.copyWith(categories: categories);
  }

  /// 加载分类下的汉字
  Future<void> loadCharacters(SixBook type) async {
    state = state.copyWith(isLoading: true, selectedCategory: type);
    try {
      final chars = await _charRepo.getBySixBook(type);
      state = state.copyWith(characters: chars, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 刷新分类数量
  Future<void> refreshCounts() async {
    final updatedCategories = <SixBookCategory>[];
    for (final cat in state.categories) {
      final count = await _charRepo.countBySixBook(cat.type);
      updatedCategories.add(SixBookCategory(
        type: cat.type,
        description: cat.description,
        example: cat.example,
        charCount: count,
      ));
    }
    state = state.copyWith(categories: updatedCategories);
  }
}
