import 'package:flutter/material.dart';
import '../models/origin_models.dart';

/// 演变卡片 - 展示汉字的演变路径
class EvolutionCard extends StatelessWidget {
  /// 演变路径
  final EvolutionPath evolutionPath;
  /// 点击回调
  final VoidCallback? onTap;
  /// 是否高亮
  final bool highlight;

  const EvolutionCard({
    super.key,
    required this.evolutionPath,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: highlight ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: highlight
            ? const BorderSide(color: Color(0xFFFF6B6B), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  const Icon(Icons.timeline, size: 20, color: Color(0xFFFF6B6B)),
                  const SizedBox(width: 8),
                  Text(
                    '字源演变',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '从古至今',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 演变路径 - 横向展示
              SizedBox(
                height: 80,
                child: Row(
                  children: _buildEvolutionPath(),
                ),
              ),

              // 本义说明
              if (evolutionPath.originalMeaning != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '本义：${evolutionPath.originalMeaning}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建演变路径
  List<Widget> _buildEvolutionPath() {
    final nodes = evolutionPath.nodes;
    if (nodes.isEmpty) {
      return [
        Center(
          child: Text(
            evolutionPath.modernChar,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
      ];
    }

    final List<Widget> widgets = [];

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      // 添加节点
      widgets.add(_buildNode(node));

      // 添加连接线和箭头（除了最后一个）
      if (i < nodes.length - 1) {
        widgets.add(_buildConnector());
      }
    }

    return widgets;
  }

  /// 构建单个演变节点
  Widget _buildNode(EvolutionNode node) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getEraColor(node.era).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getEraColor(node.era),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              node.glyph ?? '?',
              style: TextStyle(
                fontSize: node.glyph != null && node.glyph!.length > 1 ? 18 : 28,
                fontWeight: FontWeight.bold,
                color: _getEraColor(node.era),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          node.era.label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 构建连接线
  Widget _buildConnector() {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomPaint(
        painter: _ArrowPainter(),
      ),
    );
  }

  /// 获取时代对应的颜色
  Color _getEraColor(EvolutionEra era) {
    switch (era) {
      case EvolutionEra.jiaguwen:
        return const Color(0xFF8B4513); // 棕色
      case EvolutionEra.jinwen:
        return const Color(0xFFB8860B); // 暗金色
      case EvolutionEra.xiaozhuan:
        return const Color(0xFF2F4F4F); // 深青色
      case EvolutionEra.lishu:
        return const Color(0xFF556B2F); // 橄榄绿
      case EvolutionEra.kaishu:
        return const Color(0xFF483D8B); // 深紫蓝
      case EvolutionEra.modern:
        return const Color(0xFF4A90D9); // 蓝色
    }
  }
}

/// 箭头绘制器
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 画直线
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width - 6, size.height / 2),
      paint,
    );

    // 画箭头
    final path = Path()
      ..moveTo(size.width - 6, size.height / 2 - 4)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 6, size.height / 2 + 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
