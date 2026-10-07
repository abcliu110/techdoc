import 'package:flutter/material.dart';

/// App 主题配置
class AppTheme {
  // 品牌色
  static const Color primaryColor = Color(0xFF4A90D9);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFC9A962); // 古铜金，文化气息
  static const Color successColor = Color(0xFF52C41A);
  static const Color warningColor = Color(0xFFFAAD14);
  static const Color errorColor = Color(0xFFFF4D4F);

  // 汉字学习相关颜色
  static const Color characterCardBg = Color(0xFFF7F8FC);
  static const Color phoneticCharColor = Color(0xFF4A90D9); // 声旁颜色
  static const Color semanticCharColor = Color(0xFF52C41A); // 形旁颜色
  static const Color radicalColor = Color(0xFFFF6B6B); // 部首颜色

  // 文字颜色
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // 背景色
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  /// 主题数据
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFE8E8E8),
      ),
    );
  }
}
