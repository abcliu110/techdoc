import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/character.dart';
import '../../../data/repositories/character_repository.dart';
import '../providers/six_book_provider.dart';
import '../../detail/presentation/character_detail_page.dart';

/// 六书字典页面
class SixBookPage extends ConsumerWidget {
  const SixBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sixBookProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('六书字典'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(sixBookProvider.notifier).refreshCounts();
            },
          ),
        ],
      ),
      body: state.selectedCategory == null
          ? _buildCategoryList(context, ref, state)
          : _buildCharacterList(context, ref, state),
    );
  }

  /// 六书分类列表
  Widget _buildCategoryList(BuildContext context, WidgetRef ref, SixBookState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        return _SixBookCard(
          category: category,
          onTap: () {
            ref.read(sixBookProvider.notifier).loadCharacters(category.type);
          },
        );
      },
    );
  }

  /// 汉字列表
  Widget _buildCharacterList(BuildContext context, WidgetRef ref, SixBookState state) {
    return Column(
      children: [
        // 返回按钮和标题
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(sixBookProvider.notifier).loadCharacters(state.selectedCategory!);
                  // 返回分类列表
                  ref.invalidate(sixBookProvider);
                },
              ),
              const SizedBox(width: 8),
              _SixBookBadge(type: state.selectedCategory!),
              const SizedBox(width: 8),
              Text(
                '${state.selectedCategory!.label} (${state.characters.length}字)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // 汉字网格
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: state.characters.length,
                  itemBuilder: (context, index) {
                    final char = state.characters[index];
                    return _CharacterChip(
                      character: char,
                      onTap: () async {
                        // 加载完整汉字数据
                        final charRepo = CharacterRepository();
                        final fullChar = await charRepo.getById(char.id);
                        if (fullChar != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CharacterDetailPage(character: fullChar),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// 六书分类卡片
class _SixBookCard extends StatelessWidget {
  final SixBookCategory category;
  final VoidCallback onTap;

  const _SixBookCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getColor(category.type).withOpacity(0.1),
                _getColor(category.type).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SixBookBadge(type: category.type, large: true),
              const SizedBox(height: 8),
              Text(
                category.type.label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                category.description,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                category.example,
                style: TextStyle(fontSize: 10, color: AppTheme.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(SixBook type) {
    switch (type) {
      case SixBook.pictogram:
        return const Color(0xFFE74C3C);
      case SixBook.indicative:
        return const Color(0xFFE67E22);
      case SixBook.associative:
        return const Color(0xFF9B59B6);
      case SixBook.phonetic:
        return const Color(0xFF3498DB);
      case SixBook.mutual:
        return const Color(0xFF27AE60);
      case SixBook.phoneticLoan:
        return const Color(0xFF1ABC9C);
    }
  }
}

/// 六书图标徽章
class _SixBookBadge extends StatelessWidget {
  final SixBook type;
  final bool large;

  const _SixBookBadge({required this.type, this.large = false});

  @override
  Widget build(BuildContext context) {
    final size = large ? 48.0 : 32.0;
    final fontSize = large ? 24.0 : 16.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(type),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _getIcon(type),
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }

  Color _getColor(SixBook type) {
    switch (type) {
      case SixBook.pictogram:
        return const Color(0xFFE74C3C);
      case SixBook.indicative:
        return const Color(0xFFE67E22);
      case SixBook.associative:
        return const Color(0xFF9B59B6);
      case SixBook.phonetic:
        return const Color(0xFF3498DB);
      case SixBook.mutual:
        return const Color(0xFF27AE60);
      case SixBook.phoneticLoan:
        return const Color(0xFF1ABC9C);
    }
  }

  String _getIcon(SixBook type) {
    switch (type) {
      case SixBook.pictogram:
        return '🔶';
      case SixBook.indicative:
        return '🔷';
      case SixBook.associative:
        return '🟣';
      case SixBook.phonetic:
        return '🔵';
      case SixBook.mutual:
        return '🟢';
      case SixBook.phoneticLoan:
        return '⬜';
    }
  }
}

/// 汉字芯片
class _CharacterChip extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const _CharacterChip({required this.character, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              character.character,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              character.pinyin,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
