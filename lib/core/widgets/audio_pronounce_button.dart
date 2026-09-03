import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../services/tts_service.dart';

/// Reusable, animated speaker button for pronouncing English text anywhere in the app
class AudioPronounceButton extends ConsumerWidget {
  final String text;
  final String? id;
  final String? tooltip;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Color? activeColor;
  final Color? inactiveColor;
  final BoxConstraints? constraints;

  const AudioPronounceButton({
    super.key,
    required this.text,
    this.id,
    this.tooltip,
    this.iconSize = 20,
    this.padding = EdgeInsets.zero,
    this.activeColor,
    this.inactiveColor,
    this.constraints = const BoxConstraints(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speakId = id ?? 'text_${text.hashCode}';
    final activeSpeakingId = ref.watch(activeTtsIdProvider);
    final isSpeaking = activeSpeakingId == speakId;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveActiveColor = activeColor ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    final effectiveInactiveColor = inactiveColor ??
        (isDark ? Colors.white60 : Colors.black45);

    return Material(
      color: isSpeaking
          ? effectiveActiveColor.withValues(alpha: 0.15)
          : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
            key: ValueKey<bool>(isSpeaking),
            color: isSpeaking ? effectiveActiveColor : effectiveInactiveColor,
            size: iconSize,
          ),
        ),
        tooltip: tooltip ?? (isSpeaking ? 'Stop audio' : 'Pronounce in English'),
        padding: padding,
        constraints: constraints,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          ref.read(appTtsControllerProvider).toggleSpeak(id: speakId, text: text);
        },
      ),
    );
  }
}

/// Tonal / Chip-style button with icon and label for prominent pronunciation actions
class AudioPronounceTonalButton extends ConsumerWidget {
  final String text;
  final String? id;
  final String label;
  final String playingLabel;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const AudioPronounceTonalButton({
    super.key,
    required this.text,
    this.id,
    this.label = 'Pronounce',
    this.playingLabel = 'Playing...',
    this.fontSize = 12.5,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speakId = id ?? 'text_${text.hashCode}';
    final activeSpeakingId = ref.watch(activeTtsIdProvider);
    final isSpeaking = activeSpeakingId == speakId;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveBg = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.primaryContainerLight;

    final activeFg = Colors.white;
    final inactiveFg = isDark ? AppColors.primaryLight : AppColors.primary;

    return FilledButton.tonalIcon(
      onPressed: () {
        ref.read(appTtsControllerProvider).toggleSpeak(id: speakId, text: text);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
          key: ValueKey<bool>(isSpeaking),
          size: 18,
          color: isSpeaking ? activeFg : inactiveFg,
        ),
      ),
      label: Text(
        isSpeaking ? playingLabel : label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: isSpeaking ? activeFg : inactiveFg,
        ),
      ),
      style: FilledButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        visualDensity: VisualDensity.compact,
        backgroundColor: isSpeaking ? activeBg : inactiveBg,
        foregroundColor: isSpeaking ? activeFg : inactiveFg,
        elevation: isSpeaking ? 1.5 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSpeaking
                ? activeBg
                : (isDark
                    ? AppColors.borderDark
                    : AppColors.primaryLight.withValues(alpha: 0.2)),
            width: 1,
          ),
        ),
      ),
    );
  }
}
