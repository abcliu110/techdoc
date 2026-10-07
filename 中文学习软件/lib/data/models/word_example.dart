import 'package:equatable/equatable.dart';

/// 例词实体
class WordExample extends Equatable {
  final int id;
  final int characterId;
  final String word;
  final String? meaning;
  final String? exampleSentence;
  final String? source;

  const WordExample({
    required this.id,
    required this.characterId,
    required this.word,
    this.meaning,
    this.exampleSentence,
    this.source,
  });

  factory WordExample.fromMap(Map<String, dynamic> map) {
    return WordExample(
      id: map['id'] as int,
      characterId: map['character_id'] as int,
      word: map['word'] as String,
      meaning: map['meaning'] as String?,
      exampleSentence: map['example_sentence'] as String?,
      source: map['source'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character_id': characterId,
      'word': word,
      'meaning': meaning,
      'example_sentence': exampleSentence,
      'source': source,
    };
  }

  @override
  List<Object?> get props =>
      [id, characterId, word, meaning, exampleSentence, source];
}
