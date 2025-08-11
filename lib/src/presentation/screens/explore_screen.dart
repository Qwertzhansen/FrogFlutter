import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/blocs/workout/workout_bloc.dart';
import '../../data/blocs/nutrition/nutrition_bloc.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure we have some recent data for streaks and insights
    context.read<NutritionBloc>().add(const NutritionEntriesLoaded());
    context.read<WorkoutBloc>().add(const WorkoutEntriesLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Quick Start Workouts', Icons.fitness_center),
            const SizedBox(height: 8),
            _buildWorkoutTemplates(),
            const SizedBox(height: 24),

            _buildSectionTitle('Meal Ideas', Icons.restaurant),
            const SizedBox(height: 8),
            _buildMealIdeas(),
            const SizedBox(height: 24),

            _buildSectionTitle('Your Achievements', Icons.emoji_events),
            const SizedBox(height: 8),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWorkoutTemplates() {
    final templates = [
      {
        'name': 'Full Body Blast',
        'duration': 30,
        'intensity': 'medium',
        'desc': 'Squats, Push-ups, Rows, Plank — 3 rounds',
        'aiText': 'Full Body Blast 30 min: 3 rounds of squats, push-ups, rows, plank. Medium intensity.'
      },
      {
        'name': 'Cardio Burner',
        'duration': 25,
        'intensity': 'high',
        'desc': 'Intervals: 1 min run / 1 min walk x 12',
        'aiText': '25 min cardio intervals: alternate 1 min run and 1 min walk for 12 rounds. High intensity.'
      },
      {
        'name': 'Upper Body Strength',
        'duration': 40,
        'intensity': 'medium',
        'desc': 'DB Press, Rows, Shoulder Press, Curls',
        'aiText': 'Upper body strength 40 min: dumbbell press, rows, shoulder press, curls. Medium intensity.'
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final t = templates[index];
          return Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['name'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(t['desc'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(
                  children: [
                    _chip('${t['duration']} min'),
                    const SizedBox(width: 8),
                    _chip('${t['intensity']}'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WorkoutBloc>().add(
                          WorkoutEntryAddedFromText(t['aiText'] as String),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Workout template logged!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Use'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealIdeas() {
    final meals = [
      {
        'name': 'Protein Oats',
        'kcal': 420,
        'desc': 'Oats with whey, banana, peanut butter',
        'aiText': 'Meal: protein oats with banana and peanut butter, ~420 kcal, protein 30g, carbs 50g, fat 12g'
      },
      {
        'name': 'Chicken Bowl',
        'kcal': 560,
        'desc': 'Chicken, rice, broccoli, olive oil',
        'aiText': 'Meal: chicken rice bowl with broccoli and olive oil, ~560 kcal, protein 45g, carbs 60g, fat 18g'
      },
      {
        'name': 'Greek Salad',
        'kcal': 380,
        'desc': 'Feta, cucumbers, tomato, olive oil',
        'aiText': 'Meal: greek salad with feta, cucumber, tomato, olive oil, ~380 kcal, protein 15g, carbs 20g, fat 24g'
      },
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final m = meals[index];
          return Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m['name'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(m['desc'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(
                  children: [
                    _chip('${m['kcal']} kcal', color: Colors.green.shade600),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NutritionBloc>().add(
                          NutritionEntryAddedFromText(m['aiText'] as String),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Meal idea logged!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievements() {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, nState) {
        return BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, wState) {
            // Compute a simple streak: consecutive days with any entry in last 14 days
            final now = DateTime.now();
            final days = List.generate(14, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: i)));

            bool hasEntriesOn(DateTime day) {
              bool has = false;
              if (nState is NutritionLoadSuccess) {
                has |= nState.entries.any((e) => _isSameDay(e.date, day));
              }
              if (wState is WorkoutLoadSuccess) {
                has |= wState.entries.any((e) => _isSameDay(e.date, day));
              }
              return has;
            }

            int streak = 0;
            for (final day in days) {
              if (hasEntriesOn(day)) streak++; else break;
            }

            final badges = <Map<String, dynamic>>[
              {'name': 'First Log', 'earned': streak >= 1, 'icon': Icons.check_circle, 'color': Colors.blue},
              {'name': '3-Day Streak', 'earned': streak >= 3, 'icon': Icons.local_fire_department, 'color': Colors.orange},
              {'name': '7-Day Streak', 'earned': streak >= 7, 'icon': Icons.emoji_events, 'color': Colors.purple},
            ];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Current Streak: $streak day${streak == 1 ? '' : 's'}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: badges.map((b) {
                      final earned = b['earned'] as bool;
                      final color = (b['color'] as Color).withValues(alpha: earned ? 1 : 0.3);
                      return Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color),
                        ),
                        child: Row(
                          children: [
                            Icon(b['icon'] as IconData, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b['name'] as String,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              earned ? Icons.verified : Icons.lock_outline,
                              size: 16,
                              color: earned ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _chip(String text, {Color? color}) {
    final base = color ?? Colors.indigo.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: base.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: base, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
