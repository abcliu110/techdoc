import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/practice_provider.dart';

/// 书写练习首页
class PracticeHomePage extends ConsumerWidget {
  const PracticeHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('书写练习')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_note, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const Text('书写练习', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('练习汉字书写，掌握正确笔顺', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticePage()));
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始练习'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 书写练习页面
class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key});

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  bool _showHint = true;
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final char = state.character;

    return Scaffold(
      appBar: AppBar(
        title: Text(char?.character ?? '书写练习'),
        actions: [
          IconButton(
            icon: Icon(_showHint ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showHint = !_showHint),
            tooltip: _showHint ? '隐藏提示' : '显示提示',
          ),
        ],
      ),
      body: char == null ? _buildEmptyState() : Column(
        children: [
          LinearProgressIndicator(value: (state.currentIndex + 1) / state.practiceChars.length),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('${char.pinyin} · ${char.strokes}画', style: const TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          if (_showHint) Center(child: Text(char.character, style: TextStyle(fontSize: 280, color: AppTheme.primaryColor.withOpacity(0.15)))),
                          CustomPaint(painter: _GridPainter(), size: Size.infinite),
                          GestureDetector(
                            onPanStart: (d) => setState(() => _currentStroke = [d.localPosition]),
                            onPanUpdate: (d) => setState(() => _currentStroke.add(d.localPosition)),
                            onPanEnd: (_) => setState(() {
                              if (_currentStroke.isNotEmpty) {
                                _strokes.add(List.from(_currentStroke));
                                _currentStroke = [];
                              }
                            }),
                            child: CustomPaint(painter: _StrokePainter(strokes: _strokes, current: _currentStroke), size: Size.infinite),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBtn(Icons.refresh, '重写', state.currentIndex >= 0 ? () => setState(() { _strokes.clear(); _currentStroke = []; }) : null),
                      _buildBtn(Icons.skip_previous, '上一个', state.currentIndex > 0 ? () { ref.read(practiceProvider.notifier).previousCharacter(); setState(() { _strokes.clear(); _currentStroke = []; }); } : null),
                      _buildBtn(Icons.skip_next, '下一个', () { ref.read(practiceProvider.notifier).nextCharacter(); setState(() { _strokes.clear(); _currentStroke = []; }); }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_note, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text('正在加载...', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => ref.read(practiceProvider.notifier).loadPracticeChars(count: 20), child: const Text('加载练习')),
        ],
      ),
    );
  }

  Widget _buildBtn(IconData icon, String label, VoidCallback? onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(backgroundColor: onPressed != null ? AppTheme.primaryColor : Colors.grey.shade300),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: onPressed != null ? AppTheme.textPrimary : Colors.grey)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 1..style = PaintingStyle.stroke;
    final cx = size.width / 2, cy = size.height / 2, half = size.width < size.height ? size.width / 2 : size.height / 2;
    canvas.drawLine(Offset(cx - half, cy), Offset(cx + half, cy), paint);
    canvas.drawLine(Offset(cx, cy - half), Offset(cx, cy + half), paint);
    canvas.drawLine(Offset(cx - half, cy - half), Offset(cx + half, cy + half), paint);
    canvas.drawLine(Offset(cx + half, cy - half), Offset(cx - half, cy + half), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;
  _StrokePainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primaryColor..strokeWidth = 4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.isEmpty) continue;
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (int i = 1; i < s.length; i++) path.lineTo(s[i].dx, s[i].dy);
      canvas.drawPath(path, paint);
    }
    if (current.isNotEmpty) {
      final path = Path()..moveTo(current.first.dx, current.first.dy);
      for (int i = 1; i < current.length; i++) path.lineTo(current[i].dx, current[i].dy);
      canvas.drawPath(path, paint..color = AppTheme.accentColor);
    }
  }
  @override
  bool shouldRepaint(covariant _StrokePainter old) => strokes.length != old.strokes.length || current.length != old.current.length;
}
