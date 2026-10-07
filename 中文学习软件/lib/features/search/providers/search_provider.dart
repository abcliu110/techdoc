import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// 搜索状态
class SearchState {
  final bool isLoading;
  final List<Character> results;
  final String? errorMessage;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    bool? isLoading,
    List<Character>? results,
    String? errorMessage,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }
}

/// 搜索 Provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<SearchState> {
  final CharacterRepository _charRepo = CharacterRepository();

  SearchNotifier() : super(const SearchState());

  Future<void> search(String query, String type) async {
    if (query.isEmpty) {
      state = state.copyWith(results: []);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      List<Character> results = [];

      switch (type) {
        case 'pinyin':
          results = await _charRepo.searchByPinyin(query.toLowerCase());
          break;
        case 'radical':
          results = await _charRepo.searchByRadical(query);
          break;
        case 'strokes':
          final strokes = int.tryParse(query);
          if (strokes != null) {
            results = await _charRepo.searchByStrokes(strokes);
          }
          break;
        default:
          // 优先按汉字搜索
          final char = await _charRepo.getByCharacter(query);
          if (char != null) {
            results = [char];
          } else {
            // 按拼音搜索
            results = await _charRepo.searchByPinyin(query.toLowerCase());
          }
      }

      state = state.copyWith(
        isLoading: false,
        results: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchBySixBook(SixBook sixBook) async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await _charRepo.searchBySixBook(sixBook);
      state = state.copyWith(
        isLoading: false,
        results: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearResults() {
    state = const SearchState();
  }
}
