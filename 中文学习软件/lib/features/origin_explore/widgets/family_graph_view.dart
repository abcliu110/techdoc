import 'package:flutter/material.dart';
import '../../../data/models/character.dart';

/// 字族图谱视图 - 展示形声字的声旁和形旁结构
class FamilyGraphView extends StatelessWidget {
  /// 现代汉字
  final String character;
  /// 声旁
  final String? phoneticChar;
  /// 形旁
  final String? semanticChar;
  /// 相关汉字列表
  final List<Character> relatedCharacters;
  /// 点击汉字回调
  final Function(Character)? onCharacterTap;

  const FamilyGraphView({
    super.key,
    required this.character,
    this.phoneticChar,
    this.semanticChar,
    this.relatedCharacters = const [],
    this.onCharacterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.account_tree, size: 20, color: Color(0xFF4A90D9)),
                const SizedBox(width: 8),
                const Text(
                  '字族图谱',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (phoneticChar != null || semanticChar != null)
                  _buildStructureBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // 字族结构图
            _buildStructureGraph(),
            const SizedBox(height: 16),

            // 相关字列表
            if (relatedCharacters.isNotEmpty) ...[
              const Text(
                '同族字',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildRelatedChars(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建结构徽章
  Widget _buildStructureBadge() {
    final parts = <String>[];
    if (semanticChar != null) parts.add('形旁');
    if (phoneticChar != null) parts.add('声旁');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90D9).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        parts.join(' + '),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4A90D9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建字族结构图
  Widget _buildStructureGraph() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // 现代字
            Text(
              character,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '现代字形',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            if (semanticChar != null || phoneticChar != null) ...[
              const SizedBox(height: 12),
              const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
              const SizedBox(height: 12),

              // 形声结构
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (semanticChar != null) ...[
                    _buildComponentCard(
                      char: semanticChar!,
                      type: '形旁',
                      color: const Color(0xFF52C41A),
                      meaning: _getSemanticMeaning(semanticChar!),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (phoneticChar != null)
                    _buildComponentCard(
                      char: phoneticChar!,
                      type: '声旁',
                      color: const Color(0xFF4A90D9),
                      meaning: '提供读音',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建组件卡片
  Widget _buildComponentCard({
    required String char,
    required String type,
    required Color color,
    String? meaning,
  }) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            char,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ),
          if (meaning != null) ...[
            const SizedBox(height: 4),
            Text(
              meaning,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 获取形旁含义
  String _getSemanticMeaning(String semanticChar) {
    final meanings = {
      '氵': '水',
      '扌': '手',
      '木': '树',
      '火': '火',
      '土': '土',
      '金': '金',
      '口': '口',
      '心': '心',
      '女': '女',
      '子': '子',
      '宀': '屋',
      '艹': '草',
      '月': '肉/月',
      '目': '眼',
      '足': '足',
      '言': '言',
      '走': '走',
      '车': '车',
      '忄': '心',
      '礻': '神',
      '衤': '衣',
      '饣': '食',
      '马': '马',
      '鱼': '鱼',
      '鸟': '鸟',
      '虫': '虫',
      '贝': '贝',
      '刂': '刀',
      '刀': '刀',
      '冫': '冰',
      '疒': '病',
    };
    return meanings[semanticChar] ?? '';
  }

  /// 构建相关字列表
  Widget _buildRelatedChars() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: relatedCharacters.take(12).map((char) {
        return InkWell(
          onTap: () => onCharacterTap?.call(char),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  char.character,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  char.pinyin,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
