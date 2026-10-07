import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/radical_provider.dart';
import '../models/radical_model.dart';
import '../../../data/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/character_card.dart';
import '../../detail/presentation/character_detail_page.dart';

/// 部首详情页面
class RadicalDetailPage extends ConsumerStatefulWidget {
  final Radical radical;

  const RadicalDetailPage({
    super.key,
    required this.radical,
  });

  @override
  ConsumerState<RadicalDetailPage> createState() => _RadicalDetailPageState();
}

class _RadicalDetailPageState extends ConsumerState<RadicalDetailPage> {
  List<Character> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final charsAsync = await ref.read(radicalCharactersProvider(widget.radical.character).future);
    if (mounted) {
      setState(() {
        _characters = charsAsync;
        _isLoading = false;
      });
    }
  }

  void _navigateToCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterDetailPage(character: character),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('部首 "${widget.radical.character}"'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 部首信息卡片
          _buildRadicalInfoCard(),

          // 汉字列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCharacterGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadicalInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // 部首字符
          Text(
            widget.radical.character,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 8),

          // 部首名称
          Text(
            widget.radical.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 详细信息行
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip('笔画', '${widget.radical.strokes}'),
              const SizedBox(width: 12),
              _buildInfoChip('位置', _getPositionLabel(widget.radical.position)),
              const SizedBox(width: 12),
              _buildInfoChip('字数', '${_characters.length}'),
            ],
          ),

          // 说明文字
          if (widget.radical.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.radical.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getPositionLabel(String position) {
    switch (position) {
      case 'left':
        return '左侧';
      case 'right':
        return '右侧';
      case 'top':
        return '顶部';
      case 'bottom':
        return '底部';
      case 'surround':
        return '包围';
      case 'any':
        return '任意';
      default:
        return position;
    }
  }

  Widget _buildCharacterGrid() {
    if (_characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_fields, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '暂无包含此部首的汉字',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '含此部首的汉字（${_characters.length}个）',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _characters.length,
            itemBuilder: (context, index) {
              final character = _characters[index];
              return CharacterCard(
                character: character,
                onTap: () => _navigateToCharacter(character),
              );
            },
          ),
        ),
      ],
    );
  }
}
