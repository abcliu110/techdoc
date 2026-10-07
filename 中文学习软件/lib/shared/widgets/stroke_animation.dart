import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 笔画动画组件
/// 展示汉字笔画的书写动画
class StrokeAnimationWidget extends StatefulWidget {
  final String character;
  final double fontSize;
  final Duration strokeDuration;
  final Duration pauseDuration;
  final bool autoPlay;
  final VoidCallback? onAnimationComplete;

  const StrokeAnimationWidget({
    super.key,
    required this.character,
    this.fontSize = 200,
    this.strokeDuration = const Duration(milliseconds: 500),
    this.pauseDuration = const Duration(milliseconds: 200),
    this.autoPlay = true,
    this.onAnimationComplete,
  });

  @override
  State<StrokeAnimationWidget> createState() => _StrokeAnimationWidgetState();
}

class _StrokeAnimationWidgetState extends State<StrokeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.strokeDuration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.autoPlay) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _playAnimation();
      });
    }
  }

  Future<void> _playAnimation() async {
    if (!mounted) return;
    _controller.forward();
    await Future.delayed(widget.strokeDuration);
    widget.onAnimationComplete?.call();
  }

  Future<void> replay() async {
    if (!mounted) return;
    _controller.reset();
    await Future.delayed(widget.pauseDuration);
    _controller.forward();
    await Future.delayed(widget.strokeDuration);
    widget.onAnimationComplete?.call();
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
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 灰色底字（显示完整汉字）
                Opacity(
                  opacity: 0.2,
                  child: Text(
                    widget.character,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                // 彩色字（动画效果）
                Opacity(
                  opacity: _animation.value,
                  child: Text(
                    widget.character,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                _controller.reset();
                _playAnimation();
              },
              icon: const Icon(Icons.replay),
              label: const Text('重播'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 描红练习组件
/// 允许用户在手写区域描红汉字
class TracingPracticeWidget extends StatefulWidget {
  final String character;
  final double fontSize;
  final ValueChanged<List<List<Offset>>>? onStrokesChanged;

  const TracingPracticeWidget({
    super.key,
    required this.character,
    this.fontSize = 200,
    this.onStrokesChanged,
  });

  @override
  State<TracingPracticeWidget> createState() => _TracingPracticeWidgetState();
}

class _TracingPracticeWidgetState extends State<TracingPracticeWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // 田字格背景
          CustomPaint(
            painter: _TianZiGePainter(),
            size: Size.infinite,
          ),
          // 汉字提示
          Center(
            child: Text(
              widget.character,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppTheme.primaryColor.withOpacity(0.15),
              ),
            ),
          ),
          // 手写绘制层
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentStroke = [details.localPosition];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _currentStroke.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                if (_currentStroke.isNotEmpty) {
                  _strokes.add(List.from(_currentStroke));
                  _currentStroke = [];
                  widget.onStrokesChanged?.call(_strokes);
                }
              });
            },
            child: CustomPaint(
              painter: _TracingPainter(
                strokes: _strokes,
                current: _currentStroke,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
      widget.onStrokesChanged?.call(_strokes);
    });
  }
}

/// 田字格绘制器
class _TianZiGePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = size.width < size.height ? size.width / 2 : size.height / 2;

    // 横线
    canvas.drawLine(
      Offset(cx - half, cy),
      Offset(cx + half, cy),
      paint,
    );

    // 竖线
    canvas.drawLine(
      Offset(cx, cy - half),
      Offset(cx, cy + half),
      paint,
    );

    // 斜线
    canvas.drawLine(
      Offset(cx - half, cy - half),
      Offset(cx + half, cy + half),
      paint,
    );
    canvas.drawLine(
      Offset(cx + half, cy - half),
      Offset(cx - half, cy + half),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 描红绘制器
class _TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;

  _TracingPainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 绘制已完成笔画
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // 绘制当前笔画
    if (current.isNotEmpty) {
      final currentPaint = Paint()
        ..color = AppTheme.accentColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(current.first.dx, current.first.dy);
      for (int i = 1; i < current.length; i++) {
        path.lineTo(current[i].dx, current[i].dy);
      }
      canvas.drawPath(path, currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter old) {
    return strokes.length != old.strokes.length ||
        current.length != old.current.length;
  }
}
