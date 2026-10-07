import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/database/data_init_service.dart';
import 'features/home/presentation/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据
  await DataInitService().initializeData();

  runApp(const ProviderScope(child: HanziLearnApp()));
}

class HanziLearnApp extends StatelessWidget {
  const HanziLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '汉字学习',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
