import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../shared/widgets/character_card.dart';
import '../providers/learning_provider.dart';

class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});
  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  int _currentIndex = 0;
  bool _showDetails = false;
  List<WordExample> _wordExamples = [];
  List<Character> _familyChars = [];
  bool _loadingExamples = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('字卡学习')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.noTask || state.characters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('字卡学习')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              const Text('太棒了！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                state.noTask ? '当前没有需要学习的汉字' : '今日学习任务已完成！',
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      );
    }

    final currentChar = state.characters[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('字卡学习 ${_currentIndex + 1}/${state.characters.length}'),
        actions: [
          IconButton(
            icon: Icon(_showDetails ? Icons.info : Icons.info_outline),
            onPressed: () => setState(() => _showDetails = !_showDetails),
          ),
        ],
      ),
      body: Column(children: [
        LinearProgressIndicator(value: (_currentIndex + 1) / state.characters.length),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
          // 汉字大字展示
          GestureDetector(
            onTap: () => _toggleDetails(currentChar),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.characterCardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CharacterDisplay(character: currentChar, fontSize: 100, showPhonetic: _showDetails),
                  const SizedBox(height: 8),
                  Text(
                    currentChar.pinyin,
                    style: const TextStyle(fontSize: 20, color: AppTheme.textSecondary),
                  ),
                  Text(
                    '${currentChar.strokes}画 · ${currentChar.radical}部',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textHint),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 六书分类标签
          if (currentChar.sixBook != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentChar.sixBook!.label,
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),

          const SizedBox(height: 16),

          // 形声规律展示（核心功能）
          if (currentChar.semantic != null && currentChar.phonetic != null)
            _buildPhoneticSemanticCard(currentChar),

          // 字族展示
          if (_familyChars.isNotEmpty) _buildFamilyCard(currentChar),

          const SizedBox(height: 16),

          // 本义与引申义
          if (_showDetails) ...[
            if (currentChar.originalMeaning != null)
              _buildMeaningCard('本义', currentChar.originalMeaning!, Icons.star_outline),
            if (currentChar.extendedMeanings.isNotEmpty)
              _buildExtendedMeaningsCard(currentChar.extendedMeanings),
          ],

          // 例词
          if (_wordExamples.isNotEmpty) _buildWordExamplesCard(),

          // 例句
          if (_showDetails && _wordExamples.isNotEmpty)
            _buildExampleSentenceCard(),

          const SizedBox(height: 24),

          // 学习按钮
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleAnswer(false),
                icon: const Icon(Icons.refresh),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: const Text('没记住'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleAnswer(true),
                icon: const Icon(Icons.check),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: const Text('记住了'),
              ),
            ),
          ]),
        ]))),
      ]),
    );
  }

  Widget _buildPhoneticSemanticCard(Character char) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '形声规律',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildComponentBox(char.semantic!, '形旁', Colors.green),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.add, size: 24, color: Colors.grey),
                ),
                _buildComponentBox(char.phonetic!, '声旁', Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '形旁"${char.semantic}"表示义类，声旁"${char.phonetic}"提示读音',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentBox(String text, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(text, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildFamilyCard(Character char) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.family_restroom, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${char.phonetic}字族',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _familyChars.map((c) {
                final isCurrent = c.id == char.id;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppTheme.primaryColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    c.character,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningCard(String title, String meaning, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(meaning, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildExtendedMeaningsCard(List<String> meanings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_flat, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text('引申义', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            ...meanings.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.key + 1}. ', style: const TextStyle(color: AppTheme.textHint)),
                  Expanded(child: Text(e.value, style: const TextStyle(fontSize: 16))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWordExamplesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.book, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Text('例词', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _wordExamples.take(6).map((ex) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ex.word,
                    style: const TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSentenceCard() {
    final exampleWithSentence = _wordExamples.firstWhere(
      (ex) => ex.exampleSentence != null && ex.exampleSentence!.isNotEmpty,
      orElse: () => _wordExamples.first,
    );
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.format_quote, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('例句', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              exampleWithSentence.exampleSentence ?? '例句示例',
              style: const TextStyle(fontSize: 18, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleDetails(Character char) async {
    setState(() => _showDetails = !_showDetails);
    if (_showDetails) {
      await _loadExamplesAndFamily(char);
    }
  }

  Future<void> _loadExamplesAndFamily(Character char) async {
    setState(() => _loadingExamples = true);
    try {
      final charRepo = CharacterRepository();
      final examples = await charRepo.getWordExamples(char.id);
      setState(() => _wordExamples = examples);

      // 加载字族
      if (char.phonetic != null && char.phonetic!.isNotEmpty) {
        final family = await charRepo.getByPhonetic(char.phonetic!);
        setState(() => _familyChars = family);
      }
    } catch (e) {
      debugPrint('加载例词失败: $e');
    }
    setState(() => _loadingExamples = false);
  }

  Future<void> _handleAnswer(bool correct) async {
    final state = ref.read(learningProvider);
    if (state.characters.isEmpty) return;
    final char = state.characters[_currentIndex];
    await UserRepository().markLearned(char.id);
    await UserRepository().markMastered(char.id, correct);

    if (_currentIndex < state.characters.length - 1) {
      setState(() {
        _currentIndex++;
        _showDetails = false;
        _wordExamples = [];
        _familyChars = [];
      });
    } else {
      if (mounted) {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('太棒了！🎉'),
          content: const Text('今日学习任务已完成！\n\n继续保持，每天进步一点点！'),
          actions: [TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('确定'),
          )],
        ));
      }
    }
  }
}
