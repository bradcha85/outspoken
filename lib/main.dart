import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/phrase_provider.dart';
import 'providers/progress_provider.dart';
// [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
// import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OutSpokenApp());
}

class OutSpokenApp extends StatelessWidget {
  const OutSpokenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Phrase: 표현/카테고리 목록, 검색/필터 상태
        ChangeNotifierProvider(create: (_) => PhraseProvider()),
        // Progress: 학습 진도, 즐겨찾기, 스트릭 (SharedPreferences 로드)
        ChangeNotifierProvider(create: (_) => ProgressProvider()..load()),
        // [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
        // ChangeNotifierProvider(create: (_) => ChatProvider()),
        // Settings: 레벨, 목표, TTS 속도, 알림 설정, 테마 (SharedPreferences 로드)
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp.router(
          title: 'OutSpoken',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
