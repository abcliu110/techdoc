import 'package:flutter/material.dart';
import '../models/theme_word_model.dart';

/// 主题词卡片组件
class ThemeWordCard extends StatelessWidget {
  final ThemeWord word;
  final VoidCallback? onTap;
  final Color? accentColor;

  const ThemeWordCard({
    super.key,
    required this.word,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).primaryColor;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 词语
              Row(
                children: [
                  Text(
                    word.word,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (word.pinyin != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      word.pinyin!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // 释义
              if (word.meaning != null) ...[
                Text(
                  word.meaning!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // 例句
              if (word.exampleSentence != null && word.exampleSentence!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    word.exampleSentence!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
