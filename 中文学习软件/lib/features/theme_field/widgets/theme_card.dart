import 'package:flutter/material.dart' hide Theme;
import '../models/theme_model.dart';

/// 主题卡片组件
class ThemeCard extends StatelessWidget {
  final Theme theme;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Color(theme.color).withOpacity(0.15),
                Color(theme.color).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标和标题行
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(theme.color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(theme.category),
                      color: Color(theme.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          theme.category.label,
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
              const SizedBox(height: 12),
              // 描述
              Text(
                theme.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // 统计信息
              Row(
                children: [
                  _StatChip(
                    icon: Icons.text_fields,
                    label: '${theme.charCount} 字',
                    color: Color(theme.color),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.library_books,
                    label: '${theme.wordCount} 词',
                    color: Color(theme.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

/// 统计标签
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
