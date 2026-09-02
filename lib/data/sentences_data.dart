import '../models/sentence.dart';
import 'sentences/beginner_sentences.dart';
import 'sentences/intermediate_sentences.dart';
import 'sentences/advanced_sentences.dart';

/// Complete collection of 600 unique offline English sentences (200 Beginner, 200 Intermediate, 200 Advanced)
class SentencesData {
  static const List<Sentence> sentences = [
    ...beginnerSentences,
    ...intermediateSentences,
    ...advancedSentences,
  ];
}

