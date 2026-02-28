import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/phrase_list_screen.dart';
import '../screens/phrase_detail_screen.dart';
import '../screens/practice_screen.dart';
// [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
// import '../screens/ai_chat_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/main_shell.dart';
import '../screens/roadmap_screen.dart';
import '../screens/scenario_list_screen.dart';
import '../screens/scenario_play_screen.dart';
import '../screens/scenario_result_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (_, __) => const CategoryScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (_, __) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/phrase-list/:categoryId',
      builder: (_, state) => PhraseListScreen(
        categoryId: state.pathParameters['categoryId']!,
      ),
    ),
    GoRoute(
      path: '/phrase/:id',
      builder: (_, state) => PhraseDetailScreen(
        phraseId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/practice/:categoryId',
      builder: (_, state) => PracticeScreen(
        categoryId: state.pathParameters['categoryId']!,
      ),
    ),
    // [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
    // GoRoute(
    //   path: '/chat',
    //   builder: (_, __) => const AiChatScreen(),
    // ),
    GoRoute(
      path: '/quiz',
      builder: (_, __) => const QuizScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (_, __) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/roadmap',
      builder: (_, __) => const RoadmapScreen(),
    ),
    GoRoute(
      path: '/scenario-list',
      builder: (_, __) => const ScenarioListScreen(),
    ),
    GoRoute(
      path: '/scenario-play/:scenarioId',
      builder: (_, state) => ScenarioPlayScreen(
        scenarioId: state.pathParameters['scenarioId']!,
      ),
    ),
    GoRoute(
      path: '/scenario-result/:scenarioId',
      builder: (_, state) => ScenarioResultScreen(
        scenarioId: state.pathParameters['scenarioId']!,
      ),
    ),
  ],
);
