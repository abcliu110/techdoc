import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 差异高亮组件
/// 用于在形近字对比中突出显示差异区域
class DifferenceHighlight extends StatefulWidget {
  /// 汉字
  final String character;

  /// 差异描述
  final String highlightInfo;

  /// 高亮颜色
  final Color highlightColor;

  /// 字符大小
  final double fontSize;

  /// 是否启用脉冲动画
  final bool enablePulse;

  const DifferenceHighlight({
    super.key,
    required this.character,
    required this.highlightInfo,
    this.highlightColor = Colors.orange,
    this.fontSize = 100,
    this.enablePulse = true,
  });

  @override
  State<DifferenceHighlight> createState() => _DifferenceHighlightState();
}

class _DifferenceHighlightState extends State<DifferenceHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enablePulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 汉字展示
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                // 背景光晕效果
                boxShadow: widget.enablePulse
                    ? [
                        BoxShadow(
                          color: widget.highlightColor.withOpacity(_animation.value * 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widget.character,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // 差异标注线
        _buildHighlightIndicator(),
        const SizedBox(height: 8),
        // 差异说明文字
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.highlightColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.highlightColor.withOpacity(0.3)),
          ),
          child: Text(
            widget.highlightInfo,
            style: TextStyle(
              fontSize: 14,
              color: widget.highlightColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// 构建高亮指示器
  Widget _buildHighlightIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 2,
          color: widget.highlightColor.withOpacity(0.5),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.highlightColor,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 30,
          height: 2,
          color: widget.highlightColor.withOpacity(0.5),
        ),
      ],
    );
  }
}

/// 叠加对比组件
/// 将两个字叠加在一起，相同部分灰色，不同部分高亮
class OverlayComparison extends StatefulWidget {
  /// 第一个汉字
  final String char1;

  /// 第二个汉字
  final String char2;

  /// 字符大小
  final double fontSize;

  /// 差异颜色
  final Color differenceColor;

  /// 相同部分颜色
  final Color sameColor;

  const OverlayComparison({
    super.key,
    required this.char1,
    required this.char2,
    this.fontSize = 80,
    this.differenceColor = Colors.red,
    this.sameColor = Colors.grey,
  });

  @override
  State<OverlayComparison> createState() => _OverlayComparisonState();
}

class _OverlayComparisonState extends State<OverlayComparison> {
  bool _showDifference = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 切换按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton('叠加对比', _showDifference),
            const SizedBox(width: 12),
            _buildToggleButton('并列对比', !_showDifference),
          ],
        ),
        const SizedBox(height: 16),
        // 对比展示
        if (_showDifference)
          _buildOverlayView()
        else
          _buildSideBySideView(),
        const SizedBox(height: 12),
        // 图例
        _buildLegend(),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _showDifference = !isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayView() {
    return SizedBox(
      height: widget.fontSize + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景字（灰色）
          Text(
            widget.char1,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.sameColor.withOpacity(0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          // 前景字（高亮差异部分）
          Text(
            widget.char2,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.differenceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.char1,
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.sameColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 24),
        const Text(
          'vs',
          style: TextStyle(
            fontSize: 24,
            color: AppTheme.textHint,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          widget.char2,
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.differenceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('相同部分', widget.sameColor),
        const SizedBox(width: 24),
        _buildLegendItem('差异部分', widget.differenceColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 笔画轨迹回放组件
class StrokeAnimationWidget extends StatefulWidget {
  /// 汉字
  final String character;

  /// 字符大小
  final double fontSize;

  /// 笔画颜色
  final Color strokeColor;

  /// 播放速度（毫秒）
  final int durationMs;

  const StrokeAnimationWidget({
    super.key,
    required this.character,
    this.fontSize = 120,
    this.strokeColor = AppTheme.primaryColor,
    this.durationMs = 500,
  });

  @override
  State<StrokeAnimationWidget> createState() => _StrokeAnimationWidgetState();
}

class _StrokeAnimationWidgetState extends State<StrokeAnimationWidget> {
  double _progress = 0;
  bool _isPlaying = false;
  double _speed = 1.0; // 1.0 = 正常速度

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 汉字展示（带动画）
        Container(
          height: widget.fontSize + 40,
          decoration: BoxDecoration(
            color: AppTheme.characterCardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景参考字
                Text(
                  widget.character,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: Colors.grey.withOpacity(0.2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 动画字
                ClipRect(
                  clipper: _StrokeClipper(_progress),
                  child: Text(
                    widget.character,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: widget.strokeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 进度条
        Slider(
          value: _progress,
          onChanged: (value) => setState(() => _progress = value),
          activeColor: widget.strokeColor,
        ),
        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () => setState(() => _progress = 0),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 32,
              onPressed: _togglePlay,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () => setState(() => _progress = 1),
            ),
            const SizedBox(width: 16),
            // 速度控制
            _buildSpeedButton(0.5, '慢'),
            _buildSpeedButton(1.0, '中'),
            _buildSpeedButton(2.0, '快'),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedButton(double speed, String label) {
    final isSelected = _speed == speed;
    return GestureDetector(
      onTap: () => setState(() => _speed = speed),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animateProgress();
      }
    });
  }

  void _animateProgress() async {
    while (_isPlaying && _progress < 1) {
      await Future.delayed(Duration(milliseconds: (50 / _speed).round()));
      if (mounted && _isPlaying) {
        setState(() {
          _progress = (_progress + 0.02).clamp(0.0, 1.0);
          if (_progress >= 1) {
            _isPlaying = false;
          }
        });
      }
    }
  }
}

/// 笔画裁剪器
class _StrokeClipper extends CustomClipper<Rect> {
  final double progress;
  _StrokeClipper(this.progress);

  @override
  Rect getClip(Size size) {
    // 从上到下渐显效果
    return Rect.fromLTRB(0, 0, size.width, size.height * progress);
  }

  @override
  bool shouldReclip(covariant _StrokeClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}
