import 'package:flutter/material.dart';
import '../../../data/models/character.dart';
import '../models/origin_models.dart';

/// 形声分析卡片 - 展示形声字的声旁和形旁分析
class PhoneticSemanticCard extends StatelessWidget {
  /// 形声分析数据
  final PhoneticAnalysis analysis;
  /// 点击声旁回调
  final VoidCallback? onPhoneticTap;
  /// 点击形旁回调
  final VoidCallback? onSemanticTap;

  const PhoneticSemanticCard({
    super.key,
    required this.analysis,
    this.onPhoneticTap,
    this.onSemanticTap,
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
                const Icon(Icons.psychology, size: 20, color: Color(0xFF9B59B6)),
                const SizedBox(width: 8),
                const Text(
                  '形声分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (analysis.sixBook != null)
                  _buildSixBookBadge(analysis.sixBook!),
              ],
            ),
            const SizedBox(height: 16),

            // 形声结构说明
            if (analysis.structureNote != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF9B59B6).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Color(0xFF9B59B6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        analysis.structureNote!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 声旁和形旁
            Row(
              children: [
                if (analysis.phoneticChar != null)
                  Expanded(
                    child: _buildComponentPanel(
                      icon: Icons.volume_up,
                      title: '声旁',
                      char: analysis.phoneticChar!,
                      subtitle: analysis.phoneticReading ?? '提供读音',
                      color: const Color(0xFF4A90D9),
                      onTap: onPhoneticTap,
                    ),
                  ),
                if (analysis.phoneticChar != null && analysis.semanticChar != null)
                  const SizedBox(width: 12),
                if (analysis.semanticChar != null)
                  Expanded(
                    child: _buildComponentPanel(
                      icon: Icons.image,
                      title: '形旁',
                      char: analysis.semanticChar!,
                      subtitle: analysis.semanticMeaning ?? '提供语义',
                      color: const Color(0xFF52C41A),
                      onTap: onSemanticTap,
                    ),
                  ),
              ],
            ),

            // 形声字学习提示
            if (analysis.sixBook == SixBook.phonetic) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, size: 18, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '形声字约占现代汉字的90%，记忆声旁可批量掌握同音字族',
                        style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建六书徽章
  Widget _buildSixBookBadge(SixBook sixBook) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSixBookColor(sixBook).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        sixBook.label,
        style: TextStyle(
          fontSize: 11,
          color: _getSixBookColor(sixBook),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 获取六书颜色
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

  /// 构建组件面板
  Widget _buildComponentPanel({
    required IconData icon,
    required String title,
    required String char,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              char,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
