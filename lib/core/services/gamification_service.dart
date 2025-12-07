/// Gamification Service - รวมบริการ Gamification ทั้งหมด
// ignore_for_file: use_build_context_synchronously
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/quest.dart';
import '../models/user_gamification.dart';
import 'xp_service.dart';
import 'streak_service.dart';
import 'quest_service.dart';
import 'achievement_service.dart';
import '../../features/gamification/presentation/widgets/xp_gain_popup.dart';
import '../../features/gamification/presentation/widgets/level_up_dialog.dart';
import '../../features/gamification/presentation/widgets/achievement_unlocked_dialog.dart';

/// Service หลักสำหรับจัดการระบบ Gamification
class GamificationService {
  static GamificationService? _instance;

  GamificationService._();

  static GamificationService get instance {
    _instance ??= GamificationService._();
    return _instance!;
  }

  bool _isInitialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Stream subscriptions
  StreamSubscription? _xpGainSubscription;
  StreamSubscription? _levelUpSubscription;
  StreamSubscription? _achievementSubscription;
  StreamSubscription? _streakSubscription;
  StreamSubscription? _milestoneSubscription;

  /// ตรวจสอบว่า initialized หรือยัง
  bool get isInitialized => _isInitialized;

  /// Initialize gamification system with navigator key
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) return;

    _navigatorKey = navigatorKey;

    // Setup listeners
    _setupListeners();

    // Check streak on app start
    await StreakService.instance.checkAndUpdateStreak();

    // Check quests reset
    await QuestService.instance.checkAndResetQuests();

    // Check achievements
    await AchievementService.instance.checkAchievements();

    _isInitialized = true;
  }

  /// Get current context from navigator key
  BuildContext? get _context => _navigatorKey?.currentContext;

  /// Setup event listeners
  void _setupListeners() {
    // Listen for XP gains
    _xpGainSubscription = XpService.instance.onXpGain.listen((result) {
      final context = _context;
      if (context != null && result.xpGained > 0) {
        try {
          XpGainPopup.show(
            context,
            xpGained: result.xpGained,
            source: result.source.description,
          );
        } catch (e) {
          // Context may be invalid, ignore
        }
      }
    });

    // Listen for level ups
    _levelUpSubscription = XpService.instance.onLevelUp.listen((newLevel) {
      final context = _context;
      if (context != null) {
        try {
          LevelUpDialog.show(context, newLevel: newLevel);
        } catch (e) {
          // Context may be invalid, ignore
        }
      }
    });

    // Listen for achievement unlocks
    _achievementSubscription =
        AchievementService.instance.onAchievementUnlocked.listen((achievement) {
      final context = _context;
      if (context != null) {
        try {
          AchievementUnlockedDialog.show(context, achievement: achievement);
        } catch (e) {
          // Context may be invalid, ignore
        }
      }
    });

    // Listen for streak changes
    _streakSubscription =
        StreakService.instance.onStreakChange.listen((result) {
      if (result.streakReset && result.previousStreak >= 3) {
        final context = _context;
        if (context != null) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.heart_broken_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('เสียใจด้วย! Streak ของคุณขาดหายไป'),
                    ),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'กู้คืน',
                  textColor: Colors.white,
                  onPressed: () {
                    // [Future] Streak freeze/repair feature
                  },
                ),
              ),
            );
          } catch (e) {
            // Context may be invalid
          }
        }
      }
    });

    // Listen for milestone reached
    _milestoneSubscription =
        StreakService.instance.onMilestoneReached.listen((milestone) {
      final context = _context;
      if (context != null) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(milestone.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streak Milestone: ${milestone.title}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('+${milestone.xpReward} XP'),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        } catch (e) {
          // Context may be invalid, ignore
        }
      }
    });
  }

  /// Record vocabulary learned
  Future<void> recordVocabLearned({int count = 1}) async {
    try {
      final data = await XpService.instance.loadData();

      // Update stats
      await XpService.instance.saveData(
        data.copyWith(
          totalVocabLearned: data.totalVocabLearned + count,
        ),
      );

      // Give XP
      await XpService.instance
          .addXp(XpSource.vocabLearned, customAmount: count * 10);

      // Update quests
      await QuestService.instance
          .updateQuestProgress(QuestAction.learnVocab, amount: count);

      // Check achievements
      await AchievementService.instance.checkAchievements();
    } catch (e) {
      debugPrint('Error recording vocab learned: $e');
    }
  }

  /// Record vocab session completed
  Future<void> recordVocabSessionCompleted() async {
    try {
      await XpService.instance.addXp(XpSource.vocabSession);
      await AchievementService.instance.checkAchievements();
    } catch (e) {
      debugPrint('Error recording vocab session: $e');
    }
  }

  /// Record quiz completed
  Future<void> recordQuizCompleted({required double percentage}) async {
    try {
      await XpService.instance.addQuizXp(percentage);
      await QuestService.instance.updateQuestProgress(QuestAction.completeQuiz);
      await AchievementService.instance.checkAchievements();
    } catch (e) {
      debugPrint('Error recording quiz: $e');
    }
  }

  /// Record exam completed
  Future<void> recordExamCompleted({required double percentage}) async {
    try {
      final data = await XpService.instance.loadData();

      // Update stats
      final isPerfect = percentage >= 100;
      final isHighScore = percentage >= 90;

      await XpService.instance.saveData(
        data.copyWith(
          totalExamsTaken: data.totalExamsTaken + 1,
          perfectExams: isPerfect ? data.perfectExams + 1 : data.perfectExams,
          consecutiveHighScoreExams:
              isHighScore ? data.consecutiveHighScoreExams + 1 : 0,
        ),
      );

      // Give XP
      await XpService.instance.addExamXp(percentage);

      // Update quests
      await QuestService.instance.updateQuestProgress(QuestAction.completeExam);

      // Check achievements
      await AchievementService.instance.checkAchievements();
    } catch (e) {
      debugPrint('Error recording exam: $e');
    }
  }

  /// Record reading completed
  Future<void> recordReadingCompleted() async {
    try {
      final data = await XpService.instance.loadData();

      // Update stats
      await XpService.instance.saveData(
        data.copyWith(
          totalReadingCompleted: data.totalReadingCompleted + 1,
        ),
      );

      // Give XP
      await XpService.instance.addXp(XpSource.readingComplete);

      // Update quests
      await QuestService.instance.updateQuestProgress(QuestAction.readPassage);

      // Check achievements
      await AchievementService.instance.checkAchievements();
    } catch (e) {
      debugPrint('Error recording reading: $e');
    }
  }

  /// Record grammar lesson completed
  Future<void> recordGrammarCompleted() async {
    try {
      final data = await XpService.instance.loadData();

      // Update stats
      await XpService.instance.saveData(
        data.copyWith(
          totalGrammarCompleted: data.totalGrammarCompleted + 1,
        ),
      );

      // Give XP
      await XpService.instance.addXp(XpSource.grammarComplete);

      // Update quests
      await QuestService.instance.updateQuestProgress(QuestAction.learnGrammar);

      // Check achievements
      await AchievementService.instance.checkAchievements();
    } catch (e) {
      debugPrint('Error recording grammar: $e');
    }
  }

  /// Record daily login
  Future<void> recordDailyLogin() async {
    try {
      await XpService.instance.addXp(XpSource.dailyLogin);
      await QuestService.instance
          .updateQuestProgress(QuestAction.maintainStreak);
    } catch (e) {
      debugPrint('Error recording daily login: $e');
    }
  }

  /// Get current gamification stats
  Future<UserGamification> getStats() async {
    return XpService.instance.loadData();
  }

  /// Get all achievements with status
  Future<List<({Achievement achievement, bool isUnlocked, double progress})>>
      getAllAchievements() async {
    return AchievementService.instance.getAllAchievementsWithStatus();
  }

  /// Get all quests with progress
  Future<List<({Quest quest, int current, bool completed, bool claimed})>>
      getAllQuests() async {
    return QuestService.instance.getAllQuestProgress();
  }

  /// Dispose service
  void dispose() {
    _xpGainSubscription?.cancel();
    _levelUpSubscription?.cancel();
    _achievementSubscription?.cancel();
    _streakSubscription?.cancel();
    _milestoneSubscription?.cancel();

    XpService.instance.dispose();
    StreakService.instance.dispose();
    QuestService.instance.dispose();
    AchievementService.instance.dispose();

    _isInitialized = false;
    _navigatorKey = null;
  }
}
