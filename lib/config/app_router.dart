/// App Router Configuration using go_router
library;

import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/vocab/presentation/screens/vocab_home_screen.dart';
import '../features/vocab/presentation/screens/flashcard_screen.dart';
import '../features/grammar/presentation/screens/grammar_home_screen.dart';
import '../features/grammar/presentation/screens/grammar_detail_screen.dart';
import '../features/exam/presentation/screens/exam_home_screen.dart';
import '../features/exam/presentation/screens/exam_taking_screen.dart';
import '../features/progress/presentation/screens/progress_home_screen.dart';
import '../app/main_shell.dart';

class AppRouter {
  AppRouter._();
  
  // Route paths
  static const String home = '/';
  static const String vocab = '/vocab';
  static const String vocabFlashcard = '/vocab/flashcard';
  static const String grammar = '/grammar';
  static const String grammarDetail = '/grammar/:topicId';
  static const String exam = '/exam';
  static const String examTaking = '/exam/:packId';
  static const String progress = '/progress';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: vocab,
            name: 'vocab',
            builder: (context, state) => const VocabHomeScreen(),
            routes: [
              GoRoute(
                path: 'flashcard',
                name: 'flashcard',
                builder: (context, state) => const FlashcardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: grammar,
            name: 'grammar',
            builder: (context, state) => const GrammarHomeScreen(),
            routes: [
              GoRoute(
                path: ':topicId',
                name: 'grammar-detail',
                builder: (context, state) {
                  final topicId = state.pathParameters['topicId'] ?? '';
                  return GrammarDetailScreen(topicId: topicId);
                },
              ),
            ],
          ),
          GoRoute(
            path: exam,
            name: 'exam',
            builder: (context, state) => const ExamHomeScreen(),
            routes: [
              GoRoute(
                path: ':packId',
                name: 'exam-taking',
                builder: (context, state) {
                  final packId = state.pathParameters['packId'] ?? '';
                  return ExamTakingScreen(packId: packId);
                },
              ),
            ],
          ),
          GoRoute(
            path: progress,
            name: 'progress',
            builder: (context, state) => const ProgressHomeScreen(),
          ),
        ],
      ),
    ],
  );
}
