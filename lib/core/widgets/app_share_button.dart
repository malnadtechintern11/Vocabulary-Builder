import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/app_share_helper.dart';

/// Top-right AppBar share action icon button with haptic touch and theme styling
class AppShareButton extends StatelessWidget {
  final Color? color;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const AppShareButton({
    super.key,
    this.color,
    this.iconSize = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryLight : AppColors.primary;

    return IconButton(
      tooltip: 'Share App',
      icon: Container(
        padding: padding ?? const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: (color ?? primary).withValues(alpha: isDark ? 0.22 : 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (color ?? primary).withValues(alpha: isDark ? 0.35 : 0.18),
            width: 1.0,
          ),
        ),
        child: Icon(
          Icons.share_rounded,
          size: iconSize,
          color: color ?? (isDark ? AppColors.primaryLight : AppColors.primary),
        ),
      ),
      onPressed: () => AppShareHelper.shareApp(context),
    );
  }
}
