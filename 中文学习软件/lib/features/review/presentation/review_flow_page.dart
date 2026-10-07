import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// 复习流程页面
class ReviewFlowPage extends ConsumerStatefulWidget {
  const ReviewFlowPage({super.key});

  @override
  ConsumerState<ReviewFlowPage> createState() => _ReviewFlowPageState();
}

class _ReviewFlowPageState extends ConsumerState<ReviewFlowPage> {
  List<int> _reviewCharIds = [];
  List<Character> _loadedChars = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showAnswer = false;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviewChars();
  }

  Future<void> _loadReviewChars() async {
    final reviewIds = await UserRepository().getReviewChars();
    final charRepo = CharacterRepository();

    final chars = <Character>[];
    for (final id in reviewIds) {
      final char = await charRepo.getById(id);
      if (char != null) chars.add(char);
    }

    setState(() {
      _reviewCharIds = reviewIds;
      _loadedChars = chars;
      _isLoading = false;
    });
  }

  Character? get _currentChar =>
      _currentIndex < _loadedChars.length ? _loadedChars[_currentIndex] : null;

  int get _remaining => _reviewCharIds.length - _currentIndex;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习巩固')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadedChars.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习巩固')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppTheme.successColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '太棒了！',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '所有汉字都已复习完成',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    final char = _currentChar!;

    return Scaffold(
      appBar: AppBar(
        title: Text('复习 ${_currentIndex + 1}/${_loadedChars.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '剩余 $_remaining 个',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _loadedChars.length,
          ),

          // 复习内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 汉字展示
                  GestureDetector(
                    onTap: () => setState(() => _showAnswer = !_showAnswer),
                    child: CharacterDisplay(
                      character: char,
                      fontSize: 100,
                      showPhonetic: _showAnswer,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 提示
                  Text(
                    _showAnswer ? '点击隐藏答案' : '点击显示答案',
                    style: const TextStyle(color: AppTheme.textHint),
                  ),

                  // 详细信息（展开时显示）
                  if (_showAnswer) ...[
                    const SizedBox(height: 24),
                    _buildDetailCard(char),
                  ],

                  const SizedBox(height: 32),

                  // 复习按钮
                  if (_showAnswer)
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnswerButton(
                            icon: Icons.close,
                            label: '不认识',
                            color: AppTheme.errorColor,
                            onPressed: () => _handleAnswer(false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnswerButton(
                            icon: Icons.check,
                            label: '认识',
                            color: AppTheme.successColor,
                            onPressed: () => _handleAnswer(true),
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showAnswer = true),
                      icon: const Icon(Icons.visibility),
                      label: const Text('显示答案'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 统计栏
          _buildStatsBar(),
        ],
      ),
    );
  }

  Widget _buildDetailCard(Character char) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (char.sixBook != null) ...[
              Text(
                '六书分类：${char.sixBook!.label}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            if (char.semantic != null && char.phonetic != null) ...[
              Row(
                children: [
                  Text(
                    '形旁: ${char.semantic}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.semanticCharColor),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '声旁: ${char.phonetic}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.phoneticCharColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (char.originalMeaning != null) ...[
              Text(
                '本义: ${char.originalMeaning}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
            if (char.extendedMeanings.isNotEmpty) ...[
              const Text(
                '引申义:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              ...char.extendedMeanings.take(3).map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('• $m', style: const TextStyle(fontSize: 14)),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildStatsBar() {
    final total = _correctCount + _wrongCount;
    final accuracy = total > 0 ? (_correctCount / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.check_circle,
              label: '认识',
              value: '$_correctCount',
              color: AppTheme.successColor,
            ),
            _buildStatItem(
              icon: Icons.cancel,
              label: '不认识',
              value: '$_wrongCount',
              color: AppTheme.errorColor,
            ),
            _buildStatItem(
              icon: Icons.percent,
              label: '正确率',
              value: '$accuracy%',
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

  Future<void> _handleAnswer(bool correct) async {
    final char = _currentChar;
    if (char == null) return;

    // 更新学习状态
    await UserRepository().markMastered(char.id, correct);

    setState(() {
      if (correct) {
        _correctCount++;
      } else {
        _wrongCount++;
      }

      if (_currentIndex < _loadedChars.length - 1) {
        _currentIndex++;
        _showAnswer = false;
      } else {
        // 复习完成
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final total = _correctCount + _wrongCount;
    final accuracy = total > 0 ? (_correctCount / total * 100).toInt() : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              accuracy >= 80 ? Icons.celebration : Icons.emoji_events,
              color: accuracy >= 80 ? AppTheme.successColor : AppTheme.warningColor,
            ),
            const SizedBox(width: 8),
            Text(accuracy >= 80 ? '太棒了！' : '做得不错！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本次复习完成！'),
            const SizedBox(height: 16),
            _buildStatRow('复习字数', '$total'),
            _buildStatRow('认识', '$_correctCount', color: AppTheme.successColor),
            _buildStatRow('不认识', '$_wrongCount', color: AppTheme.errorColor),
            _buildStatRow('正确率', '$accuracy%', color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              accuracy < 80
                  ? '不认识的字会安排在下次复习中，继续加油！'
                  : '继续保持，下次复习效果会更好！',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回复习列表
            },
            child: const Text('返回'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 重新开始复习
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _wrongCount = 0;
                _showAnswer = false;
              });
            },
            child: const Text('再复习一遍'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
