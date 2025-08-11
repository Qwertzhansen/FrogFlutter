import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/blocs/nutrition/nutrition_bloc.dart';
import '../../data/blocs/workout/workout_bloc.dart';
import '../../services/user_progress_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Levels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<NutritionBloc, NutritionState>(
          builder: (context, nState) {
            return BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, wState) {
                final entriesN = (nState is NutritionLoadSuccess) ? nState.entries : <dynamic>[];
                final entriesW = (wState is WorkoutLoadSuccess) ? wState.entries : <dynamic>[];

                final xpFromNutrition = entriesN.fold<int>(0, (sum, e) => sum + 20 + (e.calories / 100).floor());
                final xpFromWorkouts = entriesW.fold<int>(0, (sum, e) => sum + 50 + (e.duration / 5).floor());
                final baseXP = xpFromNutrition + xpFromWorkouts;

                // Include extra awarded XP from challenges
                // Note: This is async; for simplicity we use a FutureBuilder wrapper below
                return FutureBuilder<int>(
                  future: UserProgressService.instance.getExtraXp(),
                  builder: (context, snap) {
                    final extraXP = snap.data ?? 0;
                    final totalXP = baseXP + extraXP;
                    final levelInfo = _computeLevel(totalXP);

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLevelCard(levelInfo, totalXP),
                          const SizedBox(height: 20),
                          _buildStreakCard(streak),
                          const SizedBox(height: 20),
                          const Text('Badges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: badges.map((b) => _badgeTile(b['name'], b['earned'], b['icon'], b['color'])).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                );
                final streak = _computeStreak(entriesN, entriesW);
                final badges = _computeBadges(streak, entriesN.length, entriesW.length, totalXP);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLevelCard(levelInfo, totalXP),
                      const SizedBox(height: 20),
                      _buildStreakCard(streak),
                      const SizedBox(height: 20),
                      const Text('Badges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: badges.map((b) => _badgeTile(b['name'], b['earned'], b['icon'], b['color'])).toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(_LevelInfo info, int xp) {
    final progress = info.progressToNext;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Level ${info.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${xp} XP', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.blue.shade100,
            color: Colors.blue.shade600,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text('Next level: ${info.currentXP}/${info.nextLevelXP} XP'),
          const SizedBox(height: 4),
          Text('Title: ${info.title}', style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text('Current streak: $streak day${streak == 1 ? '' : 's'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
        ],
      ),
    );
  }

  Widget _badgeTile(String name, bool earned, IconData icon, Color color) {
    final c = earned ? color : color.withValues(alpha: 0.3);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c),
      ),
      child: Row(
        children: [
          Icon(icon, color: c),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: TextStyle(color: c, fontWeight: FontWeight.w600))),
          Icon(earned ? Icons.verified : Icons.lock_outline, color: earned ? Colors.green : Colors.grey, size: 18),
        ],
      ),
    );
  }

  int _computeStreak(List nutrition, List workouts) {
    int streak = 0;
    final now = DateTime.now();
    final days = List.generate(30, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: i)));
    bool hasForDay(DateTime d) {
      final n = nutrition.any((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day);
      final w = workouts.any((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day);
      return n || w;
    }
    for (final d in days) {
      if (hasForDay(d)) streak++; else break;
    }
    return streak;
  }

  List<Map<String, dynamic>> _computeBadges(int streak, int meals, int workouts, int xp) {
    return [
      {'name': 'First Log', 'earned': (meals + workouts) >= 1, 'icon': Icons.check_circle, 'color': Colors.blue},
      {'name': '3-Day Streak', 'earned': streak >= 3, 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'name': '7-Day Streak', 'earned': streak >= 7, 'icon': Icons.emoji_events, 'color': Colors.purple},
      {'name': 'Gym Rat', 'earned': workouts >= 10, 'icon': Icons.fitness_center, 'color': Colors.red},
      {'name': 'Food Logger', 'earned': meals >= 20, 'icon': Icons.restaurant, 'color': Colors.green},
      {'name': '1000 XP', 'earned': xp >= 1000, 'icon': Icons.stars, 'color': Colors.indigo},
    ];
  }

  _LevelInfo _computeLevel(int xp) {
    // Level formula: next level at 100, 300, 600, 1000, 1500, ...
    int level = 1;
    int nextThreshold = 100;
    int prevThreshold = 0;
    while (xp >= nextThreshold) {
      level++;
      prevThreshold = nextThreshold;
      nextThreshold += 100 * level; // grows gradually
    }
    final currentXP = xp - prevThreshold;
    final nextLevelXP = nextThreshold - prevThreshold;
    final progressToNext = nextLevelXP == 0 ? 0.0 : currentXP / nextLevelXP;
    final title = _levelTitle(level);
    return _LevelInfo(level, currentXP, nextLevelXP, progressToNext, title);
  }

  String _levelTitle(int level) {
    if (level >= 10) return 'Beast Mode';
    if (level >= 7) return 'Athlete';
    if (level >= 5) return 'Challenger';
    if (level >= 3) return 'Riser';
    return 'Rookie';
  }
}

class _LevelInfo {
  final int level;
  final int currentXP;
  final int nextLevelXP;
  final double progressToNext;
  final String title;
  _LevelInfo(this.level, this.currentXP, this.nextLevelXP, this.progressToNext, this.title);
}