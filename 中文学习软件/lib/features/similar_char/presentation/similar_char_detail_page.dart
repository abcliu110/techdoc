import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/similar_char_model.dart';
import '../providers/similar_char_provider.dart';

/// 形近字对比详情页
class SimilarCharDetailPage extends ConsumerStatefulWidget {
  final SimilarCharGroup group;

  const SimilarCharDetailPage({super.key, required this.group});

  @override
  ConsumerState<SimilarCharDetailPage> createState() => _SimilarCharDetailPageState();
}

class _SimilarCharDetailPageState extends ConsumerState<SimilarCharDetailPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showExamples = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName),
        actions: [
          IconButton(
            icon: Icon(
              widget.group.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.group.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            tooltip: '开始练习',
            onPressed: () => _startPractice(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 难度标签
          _buildDifficultyTag(),
          // 汉字大字展示区
          Expanded(
            flex: 3,
            child: _buildCharDisplayArea(),
          ),
          // 差异说明区
          _buildDifferenceSection(),
          // 组词对比区
          if (_showExamples) Expanded(flex: 2, child: _buildWordsComparison()),
          // 底部操作区
          _buildBottomActions(),
        ],
      ),
    );
  }

  /// 构建难度标签
  Widget _buildDifficultyTag() {
    final difficulty = DifficultyLevel.fromCode(widget.group.difficultyLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getDifficultyColor(difficulty).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${difficulty.emoji} ${difficulty.label}',
              style: TextStyle(
                color: _getDifficultyColor(difficulty),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.group.category,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取难度对应的颜色
  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  /// 构建汉字大字展示区
  Widget _buildCharDisplayArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 滑动切换汉字
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.group.chars.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final char = widget.group.chars[index];
                return _buildCharCard(char, index);
              },
            ),
          ),
          // 页面指示器
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.group.chars.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个汉字卡片
  Widget _buildCharCard(SimilarChar char, int index) {
    return GestureDetector(
      onTap: () => _showCharDetailDialog(char),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.characterCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 汉字大字
            Text(
              char.character,
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // 拼音
            Text(
              char.pinyin,
              style: const TextStyle(
                fontSize: 24,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            // 解释
            Text(
              char.explanation,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建差异说明区
  Widget _buildDifferenceSection() {
    final currentChar = widget.group.chars[_currentIndex];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.highlight, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              const Text(
                '差异特征',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentChar.highlightInfo,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建组词对比区
  Widget _buildWordsComparison() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '组词对比',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(_showExamples ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _showExamples = !_showExamples),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.group.chars.length,
              itemBuilder: (context, index) {
                return _buildWordCard(widget.group.chars[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个组词卡片
  Widget _buildWordCard(SimilarChar char) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Text(
                char.character,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                char.pinyin,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          // 例词列表
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: char.exampleWords.take(4).map((word) {
                return GestureDetector(
                  onTap: () => _copyWord(word),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      word,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 记忆口诀
          if (widget.group.memoryTip.isNotEmpty) ...[
            const Divider(height: 16),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.group.memoryTip,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.amber,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 构建底部操作区
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => _startPractice(context),
          icon: const Icon(Icons.quiz),
          label: const Text('开始区分练习'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.accent,
          ),
        ),
      ),
    );
  }

  /// 显示汉字详情弹窗
  void _showCharDetailDialog(SimilarChar char) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              char.character,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  char.pinyin,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  char.differenceType,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              char.explanation,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              '差异: ${char.highlightInfo}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 切换收藏状态
  void _toggleFavorite() {
    ref.read(similarCharListProvider.notifier).toggleFavorite(widget.group.id);
  }

  /// 复制词语
  void _copyWord(String word) {
    // 实际应用中可以使用 Clipboard 或其他方式复制
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制: $word'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 开始练习
  void _startPractice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimilarCharPracticePage(group: widget.group),
      ),
    );
  }
}

/// 形近字练习页面
class SimilarCharPracticePage extends ConsumerStatefulWidget {
  final SimilarCharGroup? group;

  const SimilarCharPracticePage({super.key, this.group});

  @override
  ConsumerState<SimilarCharPracticePage> createState() => _SimilarCharPracticePageState();
}

class _SimilarCharPracticePageState extends ConsumerState<SimilarCharPracticePage> {
  String? _selectedAnswer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    // 如果没有传入 group，使用第一组数据
    if (widget.group != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(practiceProvider.notifier).generateQuestions(
          groups: [widget.group!],
          mode: PracticeMode.identify,
          count: 5,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider);

    if (state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('形近字练习')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.isFinished) {
      return _buildResultPage(state);
    }

    return _buildQuestionPage(state);
  }

  /// 构建题目页面
  Widget _buildQuestionPage(PracticeState state) {
    final question = state.currentQuestion!;
    return Scaffold(
      appBar: AppBar(
        title: Text('练习 ${state.currentIndex + 1}/${state.totalQuestions}'),
      ),
      body: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.totalQuestions,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 题目
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.characterCardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.quiz, size: 48, color: AppTheme.primaryColor),
                        const SizedBox(height: 16),
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 选项
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: question.options.map((option) {
                        return _buildOptionButton(option, question.correctAnswer);
                      }).toList(),
                    ),
                  ),
                  // 解析
                  if (_showResult) _buildExplanation(question),
                  // 操作按钮
                  _buildActionButtons(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选项按钮
  Widget _buildOptionButton(String option, String correctAnswer) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = AppTheme.textPrimary;

    if (_showResult) {
      if (option == correctAnswer) {
        bgColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (option == _selectedAnswer) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red;
      }
    } else if (_selectedAnswer == option) {
      borderColor = AppTheme.primaryColor;
      bgColor = AppTheme.primaryColor.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: _showResult ? null : () => setState(() => _selectedAnswer = option),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            option,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建解析区
  Widget _buildExplanation(PracticeQuestion question) {
    final isCorrect = _selectedAnswer == question.correctAnswer;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '回答正确！' : '回答错误',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation ?? '请注意区分差异特征',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(PracticeState state) {
    return Row(
      children: [
        if (!_showResult)
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedAnswer == null
                  ? null
                  : () {
                      ref.read(practiceProvider.notifier).answer(_selectedAnswer!);
                      setState(() => _showResult = true);
                    },
              child: const Text('确认答案'),
            ),
          )
        else
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ref.read(practiceProvider.notifier).nextQuestion();
                setState(() {
                  _selectedAnswer = null;
                  _showResult = false;
                });
              },
              child: Text(
                state.currentIndex < state.totalQuestions - 1 ? '下一题' : '查看结果',
              ),
            ),
          ),
      ],
    );
  }

  /// 构建结果页面
  Widget _buildResultPage(PracticeState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('练习结果')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.accuracy >= 0.8 ? Icons.celebration : Icons.emoji_events,
                size: 100,
                color: state.accuracy >= 0.8 ? Colors.amber : AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                state.accuracy >= 0.8 ? '太棒了！' : '继续加油！',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '正确率: ${(state.accuracy * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '答对: ${state.correctCount} 题 | 答错: ${state.wrongCount} 题',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  ref.read(practiceProvider.notifier).reset();
                  Navigator.pop(context);
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
