import 'package:flutter/material.dart';

/// Tag displaying part of speech (e.g. noun, verb, adjective)
class PartOfSpeechChip extends StatelessWidget {
  final String partOfSpeech;

  const PartOfSpeechChip({super.key, required this.partOfSpeech});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        partOfSpeech.toLowerCase(),
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}
