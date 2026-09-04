import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Reusable modern empty state view with dual-ring icon, subtle entrance animation,
/// clear typography, and action button.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData? actionIcon;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return Opacity(
              opacity: val,
              child: Transform.scale(
                scale: 0.92 + (0.08 * val),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dual-Ring Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 46,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),

                // Action Button
                if (actionLabel != null && onActionPressed != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onActionPressed,
                    icon: Icon(actionIcon ?? Icons.arrow_forward_rounded, size: 17),
                    label: Text(actionLabel!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
