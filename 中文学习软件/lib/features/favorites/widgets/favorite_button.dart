import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_provider.dart';

/// 收藏按钮组件
/// 点击切换收藏状态，带动画效果
class FavoriteButton extends ConsumerStatefulWidget {
  final int characterId;
  final double size;
  final Color? favoritedColor;
  final Color? unFavoritedColor;
  final VoidCallback? onFavoriteChanged;

  const FavoriteButton({
    super.key,
    required this.characterId,
    this.size = 24,
    this.favoritedColor,
    this.unFavoritedColor,
    this.onFavoriteChanged,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.7),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.0),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterFavoriteProvider(widget.characterId));

    return GestureDetector(
      onTap: () => _toggleFavorite(state.isFavorited),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Icon(
                state.isFavorited ? Icons.favorite : Icons.favorite_border,
                size: widget.size,
                color: state.isFavorited
                    ? (widget.favoritedColor ?? Colors.red)
                    : (widget.unFavoritedColor ?? Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(bool currentlyFavorited) async {
    if (currentlyFavorited) {
      _controller.forward(from: 0);
    }

    final notifier = ref.read(characterFavoriteProvider(widget.characterId).notifier);
    final newStatus = await notifier.toggle();

    if (mounted) {
      final message = newStatus ? '已添加到收藏' : '已取消收藏';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    widget.onFavoriteChanged?.call();
  }
}

/// 收藏状态指示器
/// 显示当前汉字是否已收藏（无点击功能）
class FavoriteIndicator extends ConsumerWidget {
  final int characterId;
  final double size;

  const FavoriteIndicator({
    super.key,
    required this.characterId,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterFavoriteProvider(characterId));

    if (state.isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Icon(
      state.isFavorited ? Icons.favorite : Icons.favorite_border,
      size: size,
      color: state.isFavorited ? Colors.red : Colors.grey.shade400,
    );
  }
}

/// 收藏数量徽章
class FavoriteBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const FavoriteBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
