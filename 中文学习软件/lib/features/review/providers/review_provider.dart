import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// 复习状态
class ReviewState {
  final bool isLoading;
  final List<int> reviewChars; // 待复习汉字 ID 列表
  final List<Character> characters; // 汉字详情
  final int currentIndex;

  const ReviewState({
    this.isLoading = true,
    this.reviewChars = const [],
    this.characters = const [],
    this.currentIndex = 0,
  });

  ReviewState copyWith({
    bool? isLoading,
    List<int>? reviewChars,
    List<Character>? characters,
    int? currentIndex,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviewChars: reviewChars ?? this.reviewChars,
      characters: characters ?? this.characters,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// 复习 Provider
final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier();
});

class ReviewNotifier extends StateNotifier<ReviewState> {
  final UserRepository _userRepo = UserRepository();
  final CharacterRepository _charRepo = CharacterRepository();

  ReviewNotifier() : super(const ReviewState()) {
    loadReviewChars();
  }

  Future<void> loadReviewChars() async {
    state = state.copyWith(isLoading: true);

    try {
      // 获取待复习汉字
      final reviewCharIds = await _userRepo.getReviewChars();

      // 获取汉字详情
      final characters = <Character>[];
      for (final charId in reviewCharIds) {
        final char = await _charRepo.getById(charId);
        if (char != null) {
          characters.add(char);
        }
      }

      state = state.copyWith(
        isLoading: false,
        reviewChars: reviewCharIds,
        characters: characters,
        currentIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void nextChar() {
    if (state.currentIndex < state.reviewChars.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousChar() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
}
