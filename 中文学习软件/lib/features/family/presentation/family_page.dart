import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/character_family.dart';
import '../../../data/models/character.dart';
import '../../../data/repositories/character_repository.dart';
import '../providers/family_provider.dart';
import '../../detail/presentation/character_detail_page.dart';

/// 字族图谱页面
class FamilyPage extends ConsumerStatefulWidget {
  const FamilyPage({super.key});

  @override
  ConsumerState<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends ConsumerState<FamilyPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('字族图谱'),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入声旁查找字族（如：青、工、包）',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(familyProvider.notifier).clearSelection();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref.read(familyProvider.notifier).searchByPhonetic(value);
                }
              },
            ),
          ),
          // 内容区
          Expanded(
            child: state.selectedFamily != null
                ? _buildFamilyDetail(context, state)
                : _buildFamilyList(context, state),
          ),
        ],
      ),
    );
  }

  /// 字族列表
  Widget _buildFamilyList(BuildContext context, FamilyState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.families.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无字族数据', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: state.families.length,
      itemBuilder: (context, index) {
        final family = state.families[index];
        return _FamilyCard(
          family: family,
          onTap: () {
            ref.read(familyProvider.notifier).selectFamily(family);
          },
        );
      },
    );
  }

  /// 字族详情
  Widget _buildFamilyDetail(BuildContext context, FamilyState state) {
    final family = state.selectedFamily!;

    return Column(
      children: [
        // 返回栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(familyProvider.notifier).clearSelection();
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${family.phoneticChar}" 字族',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              _ConsistencyBadge(consistency: family.phoneticConsistency),
            ],
          ),
        ),
        // 字族成员
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _FamilyMembersGrid(memberIds: state.memberIds),
        ),
      ],
    );
  }
}

/// 字族卡片
class _FamilyCard extends StatelessWidget {
  final CharacterFamily family;
  final VoidCallback onTap;

  const _FamilyCard({required this.family, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accent.withOpacity(0.1),
                AppTheme.accent.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                family.phoneticChar,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '声旁',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              _ConsistencyBadge(consistency: family.phoneticConsistency),
            ],
          ),
        ),
      ),
    );
  }
}

/// 读音一致性徽章
class _ConsistencyBadge extends StatelessWidget {
  final String consistency;

  const _ConsistencyBadge({required this.consistency});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (consistency) {
      case '高':
        color = Colors.green;
        label = '高一致性';
        icon = Icons.check_circle;
        break;
      case '中':
        color = Colors.orange;
        label = '中一致性';
        icon = Icons.info;
        break;
      default:
        color = Colors.red;
        label = '低一致性';
        icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

/// 字族成员网格
class _FamilyMembersGrid extends ConsumerWidget {
  final List<int> memberIds;

  const _FamilyMembersGrid({required this.memberIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (memberIds.isEmpty) {
      return const Center(
        child: Text('暂无成员数据', style: TextStyle(color: Colors.grey)),
      );
    }

    return FutureBuilder<List<Character>>(
      future: CharacterRepository().getByIds(memberIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final characters = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final char = characters[index];
            return _CharacterCard(
              character: char,
              onTap: () async {
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
        );
      },
    );
  }
}

/// 汉字卡片
class _CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const _CharacterCard({required this.character, required this.onTap});

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
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              character.pinyin,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            if (character.semantic != null) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  character.semantic!,
                  style: const TextStyle(fontSize: 9, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
