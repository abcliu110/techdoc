import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/character.dart';
import '../models/origin_models.dart';
import '../providers/evolution_provider.dart';
import '../providers/origin_explore_provider.dart';

/// 演变河流页面 - 横向展示汉字从古至今的演变历程
class EvolutionRiverPage extends ConsumerStatefulWidget {
  const EvolutionRiverPage({super.key});

  @override
  ConsumerState<EvolutionRiverPage> createState() => _EvolutionRiverPageState();
}

class _EvolutionRiverPageState extends ConsumerState<EvolutionRiverPage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riverState = ref.watch(evolutionRiverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('演变河流'),
      ),
      body: Column(
        children: [
          // 时代时间线
          _buildTimeline(),

          // 汉字演变卡片
          Expanded(
            child: riverState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : riverState.selectedCharacter == null
                    ? _buildCharacterCarousel(
                        ref.watch(evolutionPathListProvider).value ?? const [],
                      )
                    : _buildCharacterCarousel([riverState.selectedCharacter!]),
          ),
        ],
      ),
    );
  }

  /// 时代时间线
  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEraItem(EvolutionEra.jiaguwen, '甲骨文', '商'),
          _buildArrow(),
          _buildEraItem(EvolutionEra.jinwen, '金文', '周'),
          _buildArrow(),
          _buildEraItem(EvolutionEra.xiaozhuan, '小篆', '秦'),
          _buildArrow(),
          _buildEraItem(EvolutionEra.modern, '楷书', '今'),
        ],
      ),
    );
  }

  /// 时代节点
  Widget _buildEraItem(EvolutionEra era, String name, String dynasty) {
    final color = _getEraColor(era);
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              _getEraInitial(era),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(fontSize: 11, color: color),
        ),
        Text(
          dynasty,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  /// 箭头
  Widget _buildArrow() {
    return Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400);
  }

  /// 汉字轮播
  Widget _buildCharacterCarousel(List<Character> chars) {
    if (chars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '暂无演变数据',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: chars.length,
      itemBuilder: (context, index) {
        final char = chars[index];
        return _EvolutionCharacterCard(
          character: char,
          onLoadEvolution: () {
            ref.read(evolutionRiverProvider.notifier).loadEvolutionPath(char);
          },
        );
      },
    );
  }

  /// 获取时代颜色
  Color _getEraColor(EvolutionEra era) {
    switch (era) {
      case EvolutionEra.jiaguwen:
        return const Color(0xFF8B4513);
      case EvolutionEra.jinwen:
        return const Color(0xFFB8860B);
      case EvolutionEra.xiaozhuan:
        return const Color(0xFF2F4F4F);
      case EvolutionEra.lishu:
        return const Color(0xFF556B2F);
      case EvolutionEra.kaishu:
        return const Color(0xFF483D8B);
      case EvolutionEra.modern:
        return const Color(0xFF4A90D9);
    }
  }

  /// 获取时代首字母
  String _getEraInitial(EvolutionEra era) {
    switch (era) {
      case EvolutionEra.jiaguwen:
        return '甲';
      case EvolutionEra.jinwen:
        return '金';
      case EvolutionEra.xiaozhuan:
        return '篆';
      case EvolutionEra.lishu:
        return '隶';
      case EvolutionEra.kaishu:
        return '楷';
      case EvolutionEra.modern:
        return '今';
    }
  }
}

/// 演变汉字卡片
class _EvolutionCharacterCard extends ConsumerStatefulWidget {
  final Character character;
  final VoidCallback onLoadEvolution;

  const _EvolutionCharacterCard({
    required this.character,
    required this.onLoadEvolution,
  });

  @override
  ConsumerState<_EvolutionCharacterCard> createState() =>
      _EvolutionCharacterCardState();
}

class _EvolutionCharacterCardState
    extends ConsumerState<_EvolutionCharacterCard> {
  @override
  void initState() {
    super.initState();
    // 加载演变数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoadEvolution();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(evolutionRiverProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 汉字头部
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.character.character,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.character.pinyin,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.character.sixBook != null)
                          Text(
                            '六书：${widget.character.sixBook!.label}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (widget.character.originalMeaning != null)
                          Text(
                            '本义：${widget.character.originalMeaning}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 演变路径
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.nodes.isEmpty
                        ? _buildSimpleEvolution()
                        : _buildEvolutionRiver(state.nodes),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 简化演变展示（当没有详细演变数据时）
  Widget _buildSimpleEvolution() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '字形演变',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.character.originJiaguwen != null)
              _buildEraGlyph(
                widget.character.originJiaguwen!,
                '甲骨',
                const Color(0xFF8B4513),
              ),
            if (widget.character.originJinwen != null) ...[
              _buildArrow(),
              _buildEraGlyph(
                widget.character.originJinwen!,
                '金文',
                const Color(0xFFB8860B),
              ),
            ],
            if (widget.character.originXiaozhuan != null) ...[
              _buildArrow(),
              _buildEraGlyph(
                widget.character.originXiaozhuan!,
                '小篆',
                const Color(0xFF2F4F4F),
              ),
            ],
            _buildArrow(),
            _buildEraGlyph(
              widget.character.character,
              '楷书',
              const Color(0xFF4A90D9),
            ),
          ],
        ),
      ],
    );
  }

  /// 演变河流展示
  Widget _buildEvolutionRiver(List<EvolutionNode> nodes) {
    return Column(
      children: [
        const Text(
          '字形演变',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 演变河流 - 垂直布局
        Expanded(
          child: Row(
            children: _buildEvolutionNodes(nodes),
          ),
        ),
      ],
    );
  }

  /// 构建演变节点列表（带箭头）
  List<Widget> _buildEvolutionNodes(List<EvolutionNode> nodes) {
    final List<Widget> widgets = [];
    for (int i = 0; i < nodes.length; i++) {
      widgets.add(_buildEvolutionNode(nodes[i]));
      if (i < nodes.length - 1) {
        widgets.add(_buildVerticalArrow());
      }
    }
    return widgets;
  }

  /// 构建单个演变节点
  Widget _buildEvolutionNode(EvolutionNode node) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getEraColor(node.era).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getEraColor(node.era),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                node.glyph ?? '?',
                style: TextStyle(
                  fontSize: node.glyph != null && node.glyph!.length > 1
                      ? 20
                      : 32,
                  fontWeight: FontWeight.bold,
                  color: _getEraColor(node.era),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            node.era.label,
            style: TextStyle(
              fontSize: 12,
              color: _getEraColor(node.era),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            node.era.dynasty,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 时代字形展示
  Widget _buildEraGlyph(String glyph, String era, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              glyph,
              style: TextStyle(
                fontSize: glyph.length > 1 ? 20 : 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          era,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// 箭头
  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 20),
    );
  }

  /// 垂直箭头
  Widget _buildVerticalArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 16),
    );
  }

  /// 获取时代颜色
  Color _getEraColor(EvolutionEra era) {
    switch (era) {
      case EvolutionEra.jiaguwen:
        return const Color(0xFF8B4513);
      case EvolutionEra.jinwen:
        return const Color(0xFFB8860B);
      case EvolutionEra.xiaozhuan:
        return const Color(0xFF2F4F4F);
      case EvolutionEra.lishu:
        return const Color(0xFF556B2F);
      case EvolutionEra.kaishu:
        return const Color(0xFF483D8B);
      case EvolutionEra.modern:
        return const Color(0xFF4A90D9);
    }
  }
}
