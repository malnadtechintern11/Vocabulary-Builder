import 'package:flutter/material.dart';

/// Smooth animated progress indicator with custom easing curve, rounded caps, and optional label
class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? color;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Duration duration;
  final bool showPercentageText;
  final TextStyle? textStyle;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.color,
    this.gradient,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 600),
    this.showPercentageText = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedValue = value.clamp(0.0, 1.0);
    final defaultBg = backgroundColor ?? (theme.brightness == Brightness.dark ? Colors.white12 : const Color(0xFFE2E8F0));
    final defaultColor = color ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPercentageText) ...[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clampedValue),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, animatedVal, _) {
              final pct = (animatedVal * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  '$pct%',
                  style: textStyle ?? theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              );
            },
          ),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            width: double.infinity,
            color: defaultBg,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedValue),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, animatedVal, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedVal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: gradient == null ? defaultColor : null,
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
