import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/character.dart';
import '../../detail/presentation/character_detail_page.dart';
import '../providers/origin_explore_provider.dart';
import '../models/origin_models.dart';
import '../widgets/evolution_card.dart';
import '../widgets/family_graph_view.dart';
import '../widgets/phonetic_semantic_card.dart';
import 'evolution_river_page.dart';

/// 字源探索页面 - 探索汉字的演变历史和形声结构
class OriginExplorePage extends ConsumerStatefulWidget {
  const OriginExplorePage({super.key});

  @override
  ConsumerState<OriginExplorePage> createState() => _OriginExplorePageState();
}

class _OriginExplorePageState extends ConsumerState<OriginExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(originExploreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('字源探索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: '演变河流',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EvolutionRiverPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(originExploreProvider.notifier).clear();
              _searchController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索区域
          _buildSearchSection(),

          // 主内容区
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildErrorView(state.error!)
                    : state.result != null
                        ? _buildResultView(state.result!)
                        : _buildEmptyView(),
          ),
        ],
      ),
    );
  }

  /// 搜索区域
  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: '输入汉字或拼音探索字源...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(originExploreProvider.notifier).clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                ref.read(originExploreProvider.notifier).exploreByCharacter(value);
              }
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // 快捷入口
          Row(
            children: [
              const Text(
                '快速探索：',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['日', '月', '水', '火', '木', '金', '土', '人', '口', '心']
                        .map((char) => _buildQuickCharChip(char))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 快速汉字芯片
  Widget _buildQuickCharChip(String char) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          _searchController.text = char;
          ref.read(originExploreProvider.notifier).exploreByCharacter(char);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: Text(
            char,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.accent,
            ),
          ),
        ),
      ),
    );
  }

  /// 空状态视图
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '字源探索',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '输入汉字，探索汉字的演变历史\n了解形声字的声旁和形旁结构',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 功能说明卡片
            _buildFeatureCard(
              icon: Icons.timeline,
              title: '字形演变',
              description: '从甲骨文到现代楷书，了解汉字的演变历程',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.psychology,
              title: '形声分析',
              description: '分解形声字的结构，理解声旁和形旁的作用',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.account_tree,
              title: '字族图谱',
              description: '查看同声旁的字族，批量学习相关汉字',
            ),
          ],
        ),
      ),
    );
  }

  /// 功能说明卡片
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 错误视图
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(originExploreProvider.notifier).clear();
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新搜索'),
            ),
          ],
        ),
      ),
    );
  }

  /// 结果视图
  Widget _buildResultView(OriginExploreResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 汉字基本信息
          _buildCharacterHeader(result.character),
          const SizedBox(height: 16),

          // 演变路径卡片
          if (result.evolutionPath != null &&
              result.evolutionPath!.nodes.isNotEmpty) ...[
            EvolutionCard(evolutionPath: result.evolutionPath!),
            const SizedBox(height: 8),
          ],

          // 形声分析卡片
          if (result.phoneticAnalysis != null) ...[
            PhoneticSemanticCard(
              analysis: result.phoneticAnalysis!,
              onPhoneticTap: result.phoneticAnalysis!.phoneticChar != null
                  ? () => _navigateToCharacter(result.phoneticAnalysis!.phoneticChar!)
                  : null,
              onSemanticTap: result.phoneticAnalysis!.semanticChar != null
                  ? () => _navigateToCharacter(result.phoneticAnalysis!.semanticChar!)
                  : null,
            ),
            const SizedBox(height: 8),
          ],

          // 字族图谱卡片
          if (result.phoneticAnalysis?.phoneticChar != null ||
              result.phoneticAnalysis?.semanticChar != null) ...[
            FamilyGraphView(
              character: result.character.character,
              phoneticChar: result.phoneticAnalysis?.phoneticChar,
              semanticChar: result.phoneticAnalysis?.semanticChar,
              relatedCharacters: result.relatedCharacters,
              onCharacterTap: (char) => _navigateToCharacter(char.character),
            ),
            const SizedBox(height: 8),
          ],

          // 相关汉字列表
          if (result.relatedCharacters.isNotEmpty) ...[
            _buildRelatedSection(result.relatedCharacters),
          ],

          // 底部留白
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 汉字头部信息
  Widget _buildCharacterHeader(Character char) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 汉字展示
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  char.character,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // 信息区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拼音
                  Row(
                    children: [
                      const Icon(Icons.volume_up, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        char.pinyin,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 基本信息
                  _buildInfoChip(Icons.category, '部首 ${char.radical}'),
                  const SizedBox(height: 4),
                  _buildInfoChip(Icons.gradient, '${char.strokes} 画'),
                  const SizedBox(height: 4),
                  _buildInfoChip(Icons.trending_up, '频率第 ${char.frequency} 位'),

                  // 六书分类
                  if (char.sixBook != null) ...[
                    const SizedBox(height: 8),
                    _buildSixBookBadge(char.sixBook!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 信息芯片
  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  /// 六书徽章
  Widget _buildSixBookBadge(SixBook sixBook) {
    final color = _getSixBookColor(sixBook);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '六书：${sixBook.label}',
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 六书颜色
  Color _getSixBookColor(SixBook sixBook) {
    switch (sixBook) {
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

  /// 相关汉字区域
  Widget _buildRelatedSection(List<Character> characters) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  '相关汉字',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${characters.length} 个',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: characters.map((char) {
                return InkWell(
                  onTap: () => _navigateToCharacter(char.character),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          char.character,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          char.pinyin,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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

  /// 导航到汉字详情页
  void _navigateToCharacter(String char) {
    ref.read(originExploreProvider.notifier).exploreByCharacter(char);
  }
}
