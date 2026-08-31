import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/words_provider.dart';

/// Interactive Search bar with clear button
class WordSearchBar extends ConsumerStatefulWidget {
  const WordSearchBar({super.key});

  @override
  ConsumerState<WordSearchBar> createState() => _WordSearchBarState();
}

class _WordSearchBarState extends ConsumerState<WordSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(wordSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(wordSearchQueryProvider);

    return TextField(
      controller: _controller,
      onChanged: (val) {
        ref.read(wordSearchQueryProvider.notifier).state = val;
      },
      decoration: InputDecoration(
        hintText: 'Search words, meanings, or topics...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () {
                  _controller.clear();
                  ref.read(wordSearchQueryProvider.notifier).state = '';
                },
              )
            : null,
      ),
    );
  }
}
