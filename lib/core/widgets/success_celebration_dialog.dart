import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Rewarding celebration dialog with animated trophy/checkmark, particles, and motivating score feedback
class SuccessCelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String scoreText;
  final bool isSuccess;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;

  const SuccessCelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.scoreText,
    this.isSuccess = true,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String scoreText,
    bool isSuccess = true,
    required String primaryButtonLabel,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonLabel,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SuccessCelebrationDialog(
        title: title,
        message: message,
        scoreText: scoreText,
        isSuccess: isSuccess,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  State<SuccessCelebrationDialog> createState() => _SuccessCelebrationDialogState();
}

class _SuccessCelebrationDialogState extends State<SuccessCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _particleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = widget.isSuccess ? AppColors.success : const Color(0xFFF59E0B);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            margin: const EdgeInsets.only(top: 40),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.elevatedShadowDark : AppColors.elevatedShadowLight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    widget.scoreText,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    if (widget.secondaryButtonLabel != null && widget.onSecondaryPressed != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onSecondaryPressed,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(widget.secondaryButtonLabel!),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onPrimaryPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(widget.primaryButtonLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating Top Animated Icon & Particles
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isSuccess)
                      CustomPaint(
                        size: const Size(120, 120),
                        painter: _CelebrationParticlesPainter(_particleAnimation.value),
                      ),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.isSuccess
                                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isSuccess ? Icons.emoji_events_rounded : Icons.star_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationParticlesPainter extends CustomPainter {
  final double progress;

  _CelebrationParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    const numParticles = 12;
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];

    for (int i = 0; i < numParticles; i++) {
      final angle = (i * 2 * math.pi) / numParticles;
      final distance = 40 + (progress * 25);
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      final radius = (1.0 - progress) * 4.0;

      paint.color = colors[i % colors.length].withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
