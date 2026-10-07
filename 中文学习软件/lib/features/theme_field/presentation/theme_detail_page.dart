import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_field_provider.dart';
import '../models/theme_model.dart';
import '../models/theme_word_model.dart';
import '../widgets/theme_char_grid.dart';
import '../widgets/theme_word_card.dart';
import '../../../data/repositories/character_repository.dart';
import '../../../data/models/models.dart';

/// 主题详情页
class ThemeDetailPage extends ConsumerStatefulWidget {
  final int themeId;
  final Theme? theme;

  const ThemeDetailPage({
    super.key,
    required this.themeId,
    this.theme,
  });

  @override
  ConsumerState<ThemeDetailPage> createState() => _ThemeDetailPageState();
}

class _ThemeDetailPageState extends ConsumerState<ThemeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CharacterRepository _characterRepo = CharacterRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeDetailAsync = ref.watch(themeDetailProvider(widget.themeId));
    final themeWordsAsync = ref.watch(themeWordsProvider(widget.themeId));
    final themeCharIdsAsync = ref.watch(themeCharacterIdsProvider(widget.themeId));
    final currentTheme = widget.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTheme?.name ?? '主题详情'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '汉字', icon: Icon(Icons.text_fields)),
            Tab(text: '词语', icon: Icon(Icons.library_books)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 主题信息头部
          if (currentTheme != null) _buildThemeHeader(currentTheme),

          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 汉字 Tab
                _buildCharTab(themeCharIdsAsync),
                // 词语 Tab
                _buildWordTab(themeWordsAsync, currentTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeHeader(Theme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(theme.color).withOpacity(0.15),
            Color(theme.color).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(theme.color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(theme.category),
                  color: Color(theme.color),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.category.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            theme.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.text_fields,
                label: '${theme.charCount} 个汉字',
                color: Color(theme.color),
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.library_books,
                label: '${theme.wordCount} 个词语',
                color: Color(theme.color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharTab(AsyncValue<List<int>> charIdsAsync) {
    return charIdsAsync.when(
      data: (charIds) {
        if (charIds.isEmpty) {
          return const Center(
            child: Text('暂无汉字数据'),
          );
        }

        return FutureBuilder<List<Character>>(
          future: _characterRepo.getByIds(charIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('加载失败: ${snapshot.error}'));
            }

            final characters = snapshot.data ?? [];
            final currentTheme = widget.theme;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ThemeCharGrid(
                characters: characters,
                accentColor: currentTheme != null
                    ? Color(currentTheme.color)
                    : null,
                onCharTap: (char) => _showCharDetail(char),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildWordTab(
      AsyncValue<List<ThemeWord>> wordsAsync, Theme? theme) {
    return wordsAsync.when(
      data: (words) {
        if (words.isEmpty) {
          return const Center(
            child: Text('暂无词语数据'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: words.length,
          itemBuilder: (context, index) {
            final word = words[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ThemeWordCard(
                word: word,
                accentColor: theme != null ? Color(theme.color) : null,
                onTap: () => _showWordDetail(word),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
    );
  }

  void _showCharDetail(Character char) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      char.character,
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      char.pinyin,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DetailRow(label: '部首', value: char.radical),
                  _DetailRow(label: '笔画', value: '${char.strokes} 画'),
                  _DetailRow(label: '字频', value: '${char.frequency}'),
                  if (char.originalMeaning != null)
                    _DetailRow(label: '本义', value: char.originalMeaning!),
                  if (char.sixBook != null)
                    _DetailRow(label: '六书', value: char.sixBook!.label),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showWordDetail(ThemeWord word) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (word.pinyin != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      word.pinyin!,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (word.meaning != null) ...[
                const Text(
                  '释义',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.meaning!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (word.exampleSentence != null) ...[
                const SizedBox(height: 16),
                const Text(
                  '例句',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    word.exampleSentence!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(ThemeCategory category) {
    switch (category) {
      case ThemeCategory.person:
        return Icons.person;
      case ThemeCategory.nature:
        return Icons.landscape;
      case ThemeCategory.animal:
        return Icons.pets;
      case ThemeCategory.plant:
        return Icons.grass;
      case ThemeCategory.food:
        return Icons.restaurant;
      case ThemeCategory.color:
        return Icons.palette;
      case ThemeCategory.action:
        return Icons.directions_run;
      case ThemeCategory.emotion:
        return Icons.mood;
      case ThemeCategory.time:
        return Icons.access_time;
      case ThemeCategory.direction:
        return Icons.explore;
      case ThemeCategory.number:
        return Icons.looks_one;
      case ThemeCategory.other:
        return Icons.category;
    }
  }
}

/// 详情行
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// 信息标签
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
