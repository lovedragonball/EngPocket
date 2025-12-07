/// App Router Configuration using go_router
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/vocab/presentation/screens/vocab_home_screen.dart';
import '../features/vocab/presentation/screens/flashcard_screen.dart';
import '../features/vocab/presentation/screens/daily_vocab_screen.dart';
import '../features/vocab/presentation/screens/vocab_quiz_screen.dart';
import '../features/vocab/presentation/screens/vocab_list_screen.dart';
import '../features/grammar/presentation/screens/grammar_home_screen.dart';
import '../features/grammar/presentation/screens/grammar_detail_screen.dart';
import '../features/exam/presentation/screens/exam_home_screen.dart';
import '../features/exam/presentation/screens/exam_taking_screen.dart';
import '../features/progress/presentation/screens/progress_home_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/reading/presentation/screens/reading_home_screen.dart';
import '../features/reading/presentation/screens/reading_detail_screen.dart';
import '../features/statistics/presentation/screens/statistics_home_screen.dart';
import '../features/gamification/presentation/screens/achievements_screen.dart';
import '../features/gamification/presentation/screens/quests_screen.dart';
import '../features/gamification/presentation/screens/profile_screen.dart';
import '../app/main_shell.dart';

class AppRouter {
  AppRouter._();

  // Route paths
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String vocab = '/vocab';
  static const String vocabFlashcard = '/vocab/flashcard';
  static const String vocabDaily = '/vocab/daily';
  static const String vocabQuiz = '/vocab/quiz';
  static const String vocabList = '/vocab/list';
  static const String grammar = '/grammar';
  static const String grammarDetail = '/grammar/:topicId';
  static const String exam = '/exam';
  static const String examTaking = '/exam/:packId';
  static const String reading = '/reading';
  static const String readingDetail = '/reading/:passageId';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String statistics = '/statistics';
  static const String achievements = '/achievements';
  static const String quests = '/quests';
  static const String profile = '/profile';

  // Track if we've checked onboarding
  static bool _hasCheckedOnboarding = false;
  static bool _hasSeenOnboarding = false;

  static Future<void> _checkOnboardingStatus() async {
    if (_hasCheckedOnboarding) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    } catch (e) {
      _hasSeenOnboarding = false;
    }
    _hasCheckedOnboarding = true;
  }

  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: (BuildContext context, GoRouterState state) async {
      await _checkOnboardingStatus();

      // If user hasn't seen onboarding and not already on onboarding page
      if (!_hasSeenOnboarding && state.matchedLocation != onboarding) {
        return onboarding;
      }

      // If user has seen onboarding and is on onboarding page, redirect to home
      if (_hasSeenOnboarding && state.matchedLocation == onboarding) {
        return home;
      }

      return null;
    },
    routes: [
      // Onboarding (outside shell)
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => OnboardingScreen(
          onComplete: () {
            _hasSeenOnboarding = true;
          },
        ),
      ),

      // Settings (outside shell for full screen)
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Reading routes (outside shell for immersive experience)
      GoRoute(
        path: reading,
        name: 'reading',
        builder: (context, state) => const ReadingHomeScreen(),
        routes: [
          GoRoute(
            path: ':passageId',
            name: 'reading-detail',
            builder: (context, state) {
              final passageId = state.pathParameters['passageId'] ?? '';
              return ReadingDetailScreen(passageId: passageId);
            },
          ),
        ],
      ),

      // Statistics (outside shell for full screen charts)
      GoRoute(
        path: statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsHomeScreen(),
      ),

      // Achievements
      GoRoute(
        path: achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),

      // Quests
      GoRoute(
        path: quests,
        name: 'quests',
        builder: (context, state) => const QuestsScreen(),
      ),

      // Profile
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Main app with bottom navigation
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
              GoRoute(
                path: 'daily',
                name: 'daily-vocab',
                builder: (context, state) => const DailyVocabScreen(),
              ),
              GoRoute(
                path: 'quiz',
                name: 'vocab-quiz',
                builder: (context, state) => const VocabQuizScreen(),
              ),
              GoRoute(
                path: 'list',
                name: 'vocab-list',
                builder: (context, state) => const VocabListScreen(),
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

  /// Reset onboarding check (useful for testing or settings reset)
  static void resetOnboardingCheck() {
    _hasCheckedOnboarding = false;
    _hasSeenOnboarding = false;
  }
}
