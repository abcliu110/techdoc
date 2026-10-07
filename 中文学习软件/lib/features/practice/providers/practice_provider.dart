import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

class PracticeState {
  final bool isLoading;
  final Character? character;
  final List<Character> practiceChars;
  final int currentIndex;
  const PracticeState({
    this.isLoading = false,
    this.character,
    this.practiceChars = const [],
    this.currentIndex = 0,
  });
  PracticeState copyWith({
    bool? isLoading, Character? character, List<Character>? practiceChars, int? currentIndex,
  }) {
    return PracticeState(
      isLoading: isLoading ?? this.isLoading,
      character: character ?? this.character,
      practiceChars: practiceChars ?? this.practiceChars,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeState>((ref) => PracticeNotifier());

class PracticeNotifier extends StateNotifier<PracticeState> {
  final CharacterRepository _charRepo = CharacterRepository();
  PracticeNotifier() : super(const PracticeState());
  Future<void> loadPracticeChars({int count = 20}) async {
    state = state.copyWith(isLoading: true);
    try {
      final chars = await _charRepo.getHighFrequencyChars(count);
      state = state.copyWith(isLoading: false, practiceChars: chars, currentIndex: 0, character: chars.isNotEmpty ? chars.first : null);
    } catch (e) { state = state.copyWith(isLoading: false); }
  }
  void nextCharacter() {
    if (state.currentIndex < state.practiceChars.length - 1) {
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(currentIndex: nextIndex, character: state.practiceChars[nextIndex]);
    }
  }
  void previousCharacter() {
    if (state.currentIndex > 0) {
      final prevIndex = state.currentIndex - 1;
      state = state.copyWith(currentIndex: prevIndex, character: state.practiceChars[prevIndex]);
    }
  }
}
