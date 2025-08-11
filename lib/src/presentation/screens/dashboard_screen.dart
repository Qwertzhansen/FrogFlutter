import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'explore_screen.dart';
import '../../services/water_sleep_service.dart';
import '../../data/blocs/profile/profile_bloc.dart';
import '../../data/blocs/ai_trainer/ai_trainer_bloc.dart';
import '../../data/blocs/nutrition/nutrition_bloc.dart';
import '../../data/blocs/workout/workout_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's data
    final today = DateTime.now();
    context.read<NutritionBloc>().add(NutritionEntriesLoaded(date: today));
    context.read<WorkoutBloc>().add(WorkoutEntriesLoaded(date: today));
    context.read<AITrainerBloc>().add(AIMotivationRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Personal Trainer'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildMotivationSection(),
            const SizedBox(height: 20),
            _buildTodaysSummary(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildDiscoverCard(),
            const SizedBox(height: 20),
            _buildWaterSleep(),
            const SizedBox(height: 20),
            _buildWeeklyProgress(),
            const SizedBox(height: 20),
            _buildRecentActivity(),
            const SizedBox(height: 20),
            _buildAIInsights(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String username = 'Fitness Enthusiast';
        if (state is ProfileLoadSuccess) {
          username = state.profile.username;
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $username! 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready for another great day of fitness?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMotivationSection() {
    return BlocBuilder<AITrainerBloc, AITrainerState>(
      builder: (context, state) {
        if (state is AIMotivationSuccess) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'AI Motivation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.messages.map((message) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                    ),
                  ),
                )),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTodaysSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildNutritionSummaryCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildWorkoutSummaryCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionSummaryCard() {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        int calories = 0;
        int entries = 0;
        
        if (state is NutritionLoadSuccess) {
          entries = state.entries.length;
          if (state.dailySummary != null) {
            calories = state.dailySummary!['total_calories'] ?? 0;
          }
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.restaurant, color: Colors.green.shade700),
              const SizedBox(height: 8),
              Text(
                'Nutrition',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$calories cal',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$entries entries',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutSummaryCard() {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        int duration = 0;
        int workouts = 0;
        
        if (state is WorkoutLoadSuccess) {
          workouts = state.entries.length;
          if (state.dailySummary != null) {
            duration = state.dailySummary!['total_duration'] ?? 0;
          }
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.fitness_center, color: Colors.purple.shade700),
              const SizedBox(height: 8),
              Text(
                'Workouts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${duration}min',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$workouts sessions',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 Widget _buildDiscoverCard() {
   return Container(
     padding: const EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Colors.indigo.shade50,
       borderRadius: BorderRadius.circular(12),
       border: Border.all(color: Colors.indigo.shade200),
     ),
     child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Icon(Icons.explore, color: Colors.indigo.shade700),
         const SizedBox(width: 12),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 'Explore templates and meal ideas',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                   color: Colors.indigo.shade800,
                 ),
               ),
               const SizedBox(height: 6),
               Text(
                 'Jump into a prebuilt workout or add a healthy meal with one tap in the new Explore tab.',
                 style: TextStyle(color: Colors.indigo.shade700),
               ),
               const SizedBox(height: 8),
               Align(
                 alignment: Alignment.centerLeft,
                 child: FilledButton.icon(
                   onPressed: () {
                     // Switch to Explore tab
                     Navigator.of(context).push(
                       MaterialPageRoute(builder: (_) => const ExploreScreen()),
                     );
                   },
                   icon: const Icon(Icons.explore),
                   label: const Text('Open Explore'),
                 ),
               )
             ],
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildWeeklyProgress() {
   final now = DateTime.now();
   final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));

   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       const Text('Weekly Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
       const SizedBox(height: 12),
       Row(
         children: [
           Expanded(
             child: _buildWeeklyBarChart(
               days: days,
               title: 'Calories (kcal)',
               color: Colors.green.shade600,
               valueForDayBuilder: (day, nutritionState, workoutState) {
                 if (nutritionState is NutritionLoadSuccess) {
                   final entries = nutritionState.entries.where((e) => DateTime(e.date.year, e.date.month, e.date.day) == day);
                   return entries.fold<int>(0, (sum, e) => sum + e.calories);
                 }
                 return 0;
               },
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: _buildWeeklyBarChart(
               days: days,
               title: 'Workout (min)',
               color: Colors.purple.shade600,
               valueForDayBuilder: (day, nutritionState, workoutState) {
                 if (workoutState is WorkoutLoadSuccess) {
                   final entries = workoutState.entries.where((e) => DateTime(e.date.year, e.date.month, e.date.day) == day);
                   return entries.fold<int>(0, (sum, e) => sum + e.duration);
                 }
                 return 0;
               },
             ),
           ),
         ],
       ),
     ],
   );
 }

 Widget _buildWeeklyBarChart({
   required List<DateTime> days,
   required String title,
   required Color color,
   required int Function(DateTime day, NutritionState nState, WorkoutState wState) valueForDayBuilder,
 }) {
   return Container(
     padding: const EdgeInsets.all(12),
     decoration: BoxDecoration(
       color: color.withValues(alpha: 0.06),
       borderRadius: BorderRadius.circular(12),
       border: Border.all(color: color.withValues(alpha: 0.2)),
     ),
     child: BlocBuilder<NutritionBloc, NutritionState>(
       builder: (context, nState) {
         return BlocBuilder<WorkoutBloc, WorkoutState>(
           builder: (context, wState) {
             final values = days.map((d) => valueForDayBuilder(d, nState, wState)).toList();
             final maxVal = (values.reduce((a, b) => a > b ? a : b)).clamp(1, 999999);
             return Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                 const SizedBox(height: 8),
                 SizedBox(
                   height: 100,
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       for (int i = 0; i < days.length; i++) ...[
                         Expanded(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               Container(
                                 height: 4 + 96 * (values[i] / maxVal),
                                 decoration: BoxDecoration(
                                   color: color,
                                   borderRadius: BorderRadius.circular(6),
                                 ),
                               ),
                               const SizedBox(height: 6),
                               Text(DateFormat('E').format(days[i]).substring(0,1), style: TextStyle(fontSize: 10, color: color)),
                             ],
                           ),
                         ),
                         if (i < days.length - 1) const SizedBox(width: 4),
                       ]
                     ],
                   ),
                 )
               ],
             );
           },
         );
       },
     ),
   );
 }

 Widget _buildWaterSleep() {
   return FutureBuilder<Map<String, dynamic>>(
     future: WaterSleepService.instance.getToday(),
     builder: (context, snap) {
       final data = snap.data ?? {'water': 0, 'sleep': 0.0};
       final water = data['water'] as int? ?? 0;
       final sleep = (data['sleep'] as num?)?.toDouble() ?? 0.0;
       return Row(
         children: [
           Expanded(
             child: Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.cyan.shade50,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.cyan.shade200),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text('Water', style: TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('$water glasses'),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                       IconButton(
                         icon: const Icon(Icons.remove),
                         onPressed: () async {
                           await WaterSleepService.instance.setWater((water - 1).clamp(0, 30));
                           if (!mounted) return; setState(() {});
                         },
                       ),
                       IconButton(
                         icon: const Icon(Icons.add),
                         onPressed: () async {
                           await WaterSleepService.instance.setWater((water + 1).clamp(0, 30));
                           if (!mounted) return; setState(() {});
                         },
                       ),
                     ],
                   ),
                 ],
               ),
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.indigo.shade50,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.indigo.shade200),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text('Sleep', style: TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('${sleep.toStringAsFixed(1)} h'),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                       IconButton(
                         icon: const Icon(Icons.remove),
                         onPressed: () async {
                           await WaterSleepService.instance.setSleep((sleep - 0.5).clamp(0, 24));
                           if (!mounted) return; setState(() {});
                         },
                       ),
                       IconButton(
                         icon: const Icon(Icons.add),
                         onPressed: () async {
                           await WaterSleepService.instance.setSleep((sleep + 0.5).clamp(0, 24));
                           if (!mounted) return; setState(() {});
                         },
                       ),
                     ],
                   ),
                 ],
               ),
             ),
           ),
         ],
       );
     },
   );
 }

 Widget _buildRecentActivity() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
       const SizedBox(height: 12),
       BlocBuilder<NutritionBloc, NutritionState>(
         builder: (context, nState) {
           return BlocBuilder<WorkoutBloc, WorkoutState>(
             builder: (context, wState) {
               final items = <_ActivityItem>[];
               if (nState is NutritionLoadSuccess) {
                 for (final e in nState.entries.take(5)) {
                   items.add(_ActivityItem(
                     icon: Icons.restaurant,
                     color: Colors.green,
                     title: e.foodItem,
                     subtitle: '${e.calories} kcal • ${e.quantity}',
                     timestamp: e.createdAt,
                   ));
                 }
               }
               if (wState is WorkoutLoadSuccess) {
                 for (final e in wState.entries.take(5)) {
                   items.add(_ActivityItem(
                     icon: Icons.fitness_center,
                     color: Colors.purple,
                     title: e.exercise,
                     subtitle: '${e.duration} min • ${e.intensity}',
                     timestamp: e.createdAt,
                   ));
                 }
               }
               items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
               final visible = items.take(6).toList();
               if (visible.isEmpty) return const Text('No recent activity yet. Start logging!');
               return Column(
                 children: visible.map((it) => ListTile(
                   contentPadding: EdgeInsets.zero,
                   leading: CircleAvatar(backgroundColor: it.color.withValues(alpha: 0.15), child: Icon(it.icon, color: it.color)),
                   title: Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                   subtitle: Text(it.subtitle),
                   trailing: Text(DateFormat('EEE').format(it.timestamp)),
                 )).toList(),
               );
             },
           );
         },
       ),
     ],
   );
 }

 class _ActivityItem {
   final IconData icon;
   final Color color;
   final String title;
   final String subtitle;
   final DateTime timestamp;
   _ActivityItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.timestamp});
 }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Log Food',
                Icons.camera_alt,
                Colors.green,
                () => Navigator.pushNamed(context, '/log'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Log Workout',
                Icons.fitness_center,
                Colors.purple,
                () => Navigator.pushNamed(context, '/log'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AITrainerBloc>().add(AIAdviceRequested());
              },
              child: const Text('Get Advice'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<AITrainerBloc, AITrainerState>(
          builder: (context, state) {
            if (state is AITrainerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AIAdviceSuccess) {
              return Container(
                width: double.infinity,
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
                        Icon(Icons.lightbulb, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Personalized Advice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.advice,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tap "Get Advice" to receive personalized AI recommendations!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}