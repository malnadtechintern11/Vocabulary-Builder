import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Micro-animated favorite button that bounces on toggle and provides immediate visual feedback
class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final String? itemName;
  final double size;
  final String? tooltip;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.itemName,
    this.size = 22,
    this.tooltip,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onToggle();

    if (widget.itemName != null && mounted) {
      final willBeFavorite = !widget.isFavorite;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                willBeFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: willBeFavorite ? AppColors.favorite : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  willBeFavorite
                      ? 'Saved "${widget.itemName}" to collection'
                      : 'Removed "${widget.itemName}" from collection',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: widget.tooltip ?? (widget.isFavorite ? 'Remove from favorites' : 'Save to favorites'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: widget.isFavorite
                    ? AppColors.favorite
                    : (isDark ? Colors.white38 : Colors.black38),
                size: widget.size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
