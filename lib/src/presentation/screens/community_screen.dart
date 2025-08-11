
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/blocs/ai_trainer/ai_trainer_bloc.dart';
import '../../services/notifications_service.dart';
import '../../services/challenges_service.dart';
import '../../services/water_sleep_service.dart';
import '../../services/user_progress_service.dart';
import '../../data/blocs/nutrition/nutrition_bloc.dart';
import '../../data/blocs/workout/workout_bloc.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "Hi! I'm your AI Personal Trainer! 🏋️‍♂️\n\nI can help you with:\n• Workout advice and planning\n• Nutrition guidance\n• Progress analysis\n• Motivation and tips\n\nWhat would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
              Tab(icon: Icon(Icons.leaderboard_outlined), text: 'Leaderboard'),
              Tab(icon: Icon(Icons.flag_outlined), text: 'Challenges'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatTab(),
            _buildLeaderboardTab(),
            _buildChallengesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(child: _buildChatArea()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildChatArea() {
    return BlocListener<AITrainerBloc, AITrainerState>(
      listener: (context, state) {
        if (state is AIQuestionAnswered) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: state.answer,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        } else if (state is AIWorkoutPlanSuccess) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: "Here's your personalized workout plan:\n\n${state.workoutPlan}",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        } else if (state is AINutritionAdviceSuccess) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: "Here's your nutrition advice:\n\n${state.nutritionAdvice}",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        } else if (state is AIProgressAnalysisSuccess) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: "Here's your progress analysis:\n\n${state.analysis['analysis']}",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        } else if (state is AITrainerFailure) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: "Sorry, I encountered an error: ${state.error}\n\nPlease try again!",
                isUser: false,
                timestamp: DateTime.now(),
                isError: true,
              ),
            );
          });
          _scrollToBottom();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(_messages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? Colors.blue.shade600
              : message.isError 
                  ? Colors.red.shade100
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.purple.shade100,
                    child: Icon(
                      Icons.psychology,
                      size: 16,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Trainer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser 
                    ? Colors.white 
                    : message.isError 
                        ? Colors.red.shade800
                        : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser 
                    ? Colors.white70 
                    : Colors.grey.shade600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildQuickActions(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'Ask your AI trainer anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<AITrainerBloc, AITrainerState>(
                builder: (context, state) {
                  final isLoading = state is AITrainerLoading;
                  return CircleAvatar(
                    backgroundColor: Colors.purple.shade700,
                    child: IconButton(
                      onPressed: isLoading ? null : _sendMessage,
                      icon: isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickActionChip(
            'Workout Plan',
            Icons.fitness_center,
            () => _sendQuickAction('Generate a workout plan for me'),
          ),
          _buildQuickActionChip(
            'Nutrition Advice',
            Icons.restaurant,
            () => _sendQuickAction('Give me nutrition advice'),
          ),
          _buildQuickActionChip(
            'Progress Analysis',
            Icons.analytics,
            () => _requestProgressAnalysis(),
          ),
          _buildQuickActionChip(
            'Motivation',
            Icons.psychology,
            () => _sendQuickAction('Give me some motivation'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        avatar: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.purple.shade50,
        side: BorderSide(color: Colors.purple.shade200),
      ),
    );
  }

  void _sendMessage() {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: question,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _questionController.clear();
    _scrollToBottom();

    context.read<AITrainerBloc>().add(AIQuestionAsked(question));
  }

  void _sendQuickAction(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    if (message.contains('workout plan')) {
      context.read<AITrainerBloc>().add(const AIWorkoutPlanRequested('general fitness'));
    } else if (message.contains('nutrition')) {
      context.read<AITrainerBloc>().add(const AINutritionAdviceRequested('balanced diet'));
    } else {
      context.read<AITrainerBloc>().add(AIQuestionAsked(message));
    }
  }

  void _requestProgressAnalysis() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: 'Analyze my progress',
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();
    context.read<AITrainerBloc>().add(AIProgressAnalysisRequested());
  }

 Widget _buildLeaderboardTab() {
   final data = [
     {'name': 'Alex', 'emoji': '🏃‍♂️', 'score': 1450},
     {'name': 'Jess', 'emoji': '🚴‍♀️', 'score': 1320},
     {'name': 'Marcus', 'emoji': '🏋️‍♂️', 'score': 1280},
     {'name': 'You', 'emoji': '🔥', 'score': 1190},
     {'name': 'Maria', 'emoji': '🧘‍♀️', 'score': 980},
   ];
   return ListView.separated(
     padding: const EdgeInsets.all(16),
     itemCount: data.length,
     separatorBuilder: (_, __) => const SizedBox(height: 8),
     itemBuilder: (context, index) {
       final item = data[index];
       return Container(
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.purple.shade100),
         ),
         child: Row(
           children: [
             SizedBox(width: 28, child: Text(index == 0 ? '🏆' : '${index + 1}', textAlign: TextAlign.center)),
             const SizedBox(width: 8),
             Text(item['emoji'] as String, style: const TextStyle(fontSize: 20)),
             const SizedBox(width: 12),
             Expanded(child: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
             Text('${item['score']}', style: const TextStyle(fontWeight: FontWeight.bold)),
           ],
         ),
       );
     },
   );
 }

 Widget _buildChallengesTab() {
   return FutureBuilder<Set<String>>(
     future: ChallengesService.instance.getJoined(),
     builder: (context, snapshot) {
       final initialJoined = snapshot.data ?? <String>{};
       return _challengesList(initialJoined);
     },
   );
 }

 Widget _challengesList(Set<String> initialJoined) {
   return BlocBuilder<NutritionBloc, NutritionState>(
     builder: (context, nState) {
       return BlocBuilder<WorkoutBloc, WorkoutState>(
         builder: (context, wState) {
           return _buildChallengeListContent(initialJoined, nState, wState);
         },
       );
     },
   );
 }

 Widget _buildChallengeListContent(Set<String> initialJoined, NutritionState nState, WorkoutState wState) {
  return FutureBuilder<Set<String>>(
    future: ChallengesService.instance.getRewarded(),
    builder: (context, snap) {
      final rewarded = snap.data ?? <String>{};

      final challenges = [
        {
          'id': 'c1',
          'name': '7-Day Workout Streak',
          'desc': 'Log a workout every day for 7 days',
          'rewardXp': 300,
          'goal': 7,
          'type': 'workout_streak',
        },
        {
          'id': 'c2',
          'name': 'Hydration Hero',
          'desc': 'Log water on 5 days',
          'rewardXp': 150,
          'goal': 5,
          'type': 'hydration_days',
        },
        {
          'id': 'c3',
          'name': 'Balanced Meals',
          'desc': 'Log 10 meals',
          'rewardXp': 250,
          'goal': 10,
          'type': 'meals_count',
        },
      ];

      var joined = Set<String>.from(initialJoined);

      int computeWorkoutStreak() {
        int streak = 0;
        if (wState is! WorkoutLoadSuccess) return 0;
        final entries = wState.entries;
        bool hasWorkoutOn(DateTime d) =>
          entries.any((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day);

        var day = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        while (streak < 30 && hasWorkoutOn(day)) {
          streak++;
          day = day.subtract(const Duration(days: 1));
        }
        return streak;
      }

      int computeMealsCount() {
        if (nState is! NutritionLoadSuccess) return 0;
        return nState.entries.length;
      }

      final workoutStreak = computeWorkoutStreak();
      final mealsCount = computeMealsCount();
      final waterDays = 0; // see note: can be upgraded to 7-day async calc

      int progressFor(Map<String, dynamic> ch) {
        switch (ch['type']) {
          case 'workout_streak':
            return workoutStreak.clamp(0, ch['goal'] as int);
          case 'hydration_days':
            return waterDays.clamp(0, ch['goal'] as int);
          case 'meals_count':
            return mealsCount.clamp(0, ch['goal'] as int);
        }
        return 0;
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ch = challenges[index];
              final id = ch['id'] as String;
              final isJoined = joined.contains(id);
              final goal = ch['goal'] as int;
              final progress = progressFor(ch);
              final isComplete = progress >= goal;
              final isRewarded = rewarded.contains(id);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag_outlined, color: Colors.purple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ch['name'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (!isJoined)
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                joined.add(id);
                                ChallengesService.instance.join(id);
                              });
                            },
                            child: const Text('Join'),
                          )
                        else if (isJoined && isComplete && !isRewarded)
                          FilledButton(
                            onPressed: () async {
                              final xp = ch['rewardXp'] as int;
                              await UserProgressService.instance.addXp(xp);
                              await ChallengesService.instance.markRewarded(id);
                              await NotificationsService.instance.showCelebration(
                                'Challenge Completed',
                                ch['name'] as String,
                              );
                              final newRewarded = await ChallengesService.instance.getRewarded();
                              setState(() {});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Awarded +$xp XP!')),
                                );
                              }
                            },
                            child: const Text('Claim'),
                          )
                        else
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                joined.remove(id);
                                ChallengesService.instance.leave(id);
                              });
                            },
                            child: const Text('Leave'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(ch['desc'] as String),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: (progress / goal).clamp(0.0, 1.0),
                              backgroundColor: Colors.purple.shade50,
                              color: Colors.purple.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$progress/$goal'),
                      ],
                    ),
                    if (isJoined && isComplete && isRewarded)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: const [
                            Icon(Icons.verified, color: Colors.green, size: 18),
                            SizedBox(width: 6),
                            Text('Completed'),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
   // Persist joined challenges across restarts
   // and display joined state accordingly
   final challenges = [
     {'id': 'c1', 'name': '7-Day Workout Streak', 'desc': 'Log a workout every day for 7 days', 'reward': '+300 XP'},
     {'id': 'c2', 'name': 'Hydration Hero', 'desc': 'Log water intake for 5 days', 'reward': '+150 XP'},
     {'id': 'c3', 'name': 'Balanced Meals', 'desc': 'Log 10 healthy meals', 'reward': '+250 XP'},
   ];
   var joined = Set<String>.from(initialJoined);
   return StatefulBuilder(builder: (context, setState) {
     return ListView.separated(
       padding: const EdgeInsets.all(16),
       itemCount: challenges.length,
       separatorBuilder: (_, __) => const SizedBox(height: 8),
       itemBuilder: (context, index) {
         final ch = challenges[index];
         final isJoined = joined.contains(ch['id']);
         return Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.purple.shade100),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   const Icon(Icons.flag_outlined, color: Colors.purple),
                   const SizedBox(width: 8),
                   Expanded(child: Text(ch['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                   FilledButton(
                     onPressed: () async {
                       setState(() {
                         if (isJoined) {
                           joined.remove(ch['id']);
                           ChallengesService.instance.leave(ch['id'] as String);
                         } else {
                           joined.add(ch['id'] as String);
                           ChallengesService.instance.join(ch['id'] as String);
                         }
                       });
                       await NotificationsService.instance.showCelebration(
                         isJoined ? 'Left Challenge' : 'Joined Challenge',
                         ch['name'] as String,
                       );
                     },
                     child: Text(isJoined ? 'Leave' : 'Join'),
                   ),
                 ],
               ),
               const SizedBox(height: 6),
               Text(ch['desc'] as String),
               const SizedBox(height: 6),
               Text('Reward: ${ch['reward']}', style: const TextStyle(fontWeight: FontWeight.w600)),
             ],
           ),
         );
       },
     );
   });
 }

 void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
