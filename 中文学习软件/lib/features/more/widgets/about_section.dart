import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 关于与帮助区域
class AboutSection extends StatelessWidget {
  final VoidCallback onHelpTap;
  final VoidCallback onAboutTap;

  const AboutSection({
    super.key,
    required this.onHelpTap,
    required this.onAboutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '关于与帮助',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.green,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    '使用帮助',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '学习方法和功能介绍',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: onHelpTap,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    '关于应用',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '版本 v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: onAboutTap,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
