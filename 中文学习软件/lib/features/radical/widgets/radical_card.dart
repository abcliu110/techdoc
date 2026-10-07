import 'package:flutter/material.dart';
import '../models/radical_model.dart';
import '../../../core/theme/app_theme.dart';

/// 部首卡片组件
class RadicalCard extends StatelessWidget {
  final Radical radical;
  final int? characterCount;
  final VoidCallback? onTap;

  const RadicalCard({
    super.key,
    required this.radical,
    this.characterCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 部首字符
            Text(
              radical.character,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // 部首名称
            Text(
              radical.name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            // 笔画数
            Text(
              '${radical.strokes}画',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            if (characterCount != null) ...[
              const SizedBox(height: 4),
              // 汉字数量
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$characterCount 字',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 部首网格卡片
class RadicalGridCard extends StatelessWidget {
  final Radical radical;
  final int? characterCount;
  final VoidCallback? onTap;

  const RadicalGridCard({
    super.key,
    required this.radical,
    this.characterCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              radical.character,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              radical.name,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            if (characterCount != null && characterCount! > 0) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$characterCount',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 简化版部首卡片（用于列表）
class RadicalListTile extends StatelessWidget {
  final Radical radical;
  final int? characterCount;
  final VoidCallback? onTap;

  const RadicalListTile({
    super.key,
    required this.radical,
    this.characterCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          radical.character,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
      ),
      title: Text(radical.name),
      subtitle: Text(
        '${radical.strokes}画 | ${radical.position}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: characterCount != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$characterCount',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right),
    );
  }
}
