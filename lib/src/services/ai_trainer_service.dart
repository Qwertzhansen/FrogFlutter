import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_service.dart';

class AITrainerService {
  final AIService _aiService = AIService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> getPersonalizedAdvice(String userId) async {
    try {
      // Get user's recent activities
      final recentActivities = await _getRecentActivities(userId);
      
      // Get user profile for goals
      final profile = await _getUserProfile(userId);
      
      // Generate personalized advice
      final advice = await _aiService.getPersonalizedAdvice(
        profile['fitness_goal'] ?? 'general fitness',
        recentActivities,
      );

      return advice;
    } catch (e) {
      return 'Keep up the great work! Remember to stay consistent with your fitness journey.';
    }
  }

  Future<String> generateWorkoutPlan(String userId, String preferences) async {
    try {
      final profile = await _getUserProfile(userId);
      final recentWorkouts = await _getRecentWorkouts(userId);
      
      final prompt = '''
Based on the user's profile: ${profile.toString()}
Recent workouts: ${recentWorkouts.toString()}
User preferences: $preferences

Generate a personalized workout plan for the next week. Include:
- Exercise types and duration
- Rest days
- Progressive difficulty
- Specific recommendations based on their history
''';

      return await _aiService.processNaturalLanguageInput(prompt, 'workout_planning');
    } catch (e) {
      return 'Here\'s a basic workout plan: Mix cardio and strength training, aim for 3-4 sessions per week with rest days in between.';
    }
  }

  Future<String> generateNutritionAdvice(String userId, String dietaryPreferences) async {
    try {
      final profile = await _getUserProfile(userId);
      final recentNutrition = await _getRecentNutrition(userId);
      
      final prompt = '''
Based on the user's profile: ${profile.toString()}
Recent nutrition: ${recentNutrition.toString()}
Dietary preferences: $dietaryPreferences

Provide personalized nutrition advice including:
- Calorie recommendations
- Macro balance suggestions
- Meal timing
- Specific food recommendations
''';

      return await _aiService.processNaturalLanguageInput(prompt, 'nutrition_advice');
    } catch (e) {
      return 'Focus on a balanced diet with adequate protein, complex carbs, and healthy fats. Stay hydrated and eat regular meals.';
    }
  }

  Future<Map<String, dynamic>> analyzeProgress(String userId) async {
    try {
      final workoutSummary = await _getWorkoutProgress(userId);
      final nutritionSummary = await _getNutritionProgress(userId);
      
      final prompt = '''
Analyze this user's fitness progress:
Workout data: ${workoutSummary.toString()}
Nutrition data: ${nutritionSummary.toString()}

Provide insights on:
- Progress trends
- Areas for improvement
- Achievements to celebrate
- Specific recommendations

Return as a structured analysis.
''';

      final analysis = await _aiService.processNaturalLanguageInput(prompt, 'progress_analysis');
      
      return {
        'analysis': analysis,
        'workout_summary': workoutSummary,
        'nutrition_summary': nutritionSummary,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'analysis': 'Keep tracking your activities to see detailed progress analysis.',
        'workout_summary': {},
        'nutrition_summary': {},
        'generated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<String> answerFitnessQuestion(String question, String userId) async {
    try {
      final userContext = await _getUserContext(userId);
      
      final prompt = '''
User context: ${userContext.toString()}
Question: $question

Provide a helpful, personalized answer to this fitness-related question.
Consider the user's current fitness level, goals, and history.
''';

      return await _aiService.processNaturalLanguageInput(prompt, 'fitness_qa');
    } catch (e) {
      return 'I\'m here to help with your fitness journey! Could you please rephrase your question?';
    }
  }

  Future<List<String>> generateMotivationalMessages(String userId) async {
    try {
      final profile = await _getUserProfile(userId);
      final recentActivities = await _getRecentActivities(userId);
      
      final prompt = '''
Based on user profile: ${profile.toString()}
Recent activities: ${recentActivities.toString()}

Generate 3 personalized motivational messages that are:
- Encouraging and positive
- Specific to their progress
- Actionable
- Brief (1-2 sentences each)

Return as a JSON array of strings.
''';

      final response = await _aiService.processNaturalLanguageInput(prompt, 'motivation');
      
      // Try to parse JSON response
      try {
        final messages = response.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(3)
            .toList();
        return messages.isNotEmpty ? messages : _getDefaultMotivationalMessages();
      } catch (e) {
        return _getDefaultMotivationalMessages();
      }
    } catch (e) {
      return _getDefaultMotivationalMessages();
    }
  }

  // Helper methods
  Future<List<Map<String, dynamic>>> _getRecentActivities(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final workouts = await _supabase
        .from('workout_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', weekAgo.toIso8601String())
        .order('date', ascending: false)
        .limit(10);

    final nutrition = await _supabase
        .from('nutrition_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', weekAgo.toIso8601String())
        .order('date', ascending: false)
        .limit(10);

    return [
      ...workouts.map((w) => {'type': 'workout', 'data': w}),
      ...nutrition.map((n) => {'type': 'nutrition', 'data': n}),
    ];
  }

  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return {'fitness_goal': 'general fitness'};
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentWorkouts(String userId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final response = await _supabase
        .from('workout_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', weekAgo.toIso8601String())
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> _getRecentNutrition(String userId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final response = await _supabase
        .from('nutrition_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', weekAgo.toIso8601String())
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> _getWorkoutProgress(String userId) async {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final response = await _supabase
        .from('workout_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', monthAgo.toIso8601String());

    final workouts = List<Map<String, dynamic>>.from(response);
    
    int totalWorkouts = workouts.length;
    int totalDuration = workouts.fold(0, (sum, w) => sum + (w['duration'] as int));
    int totalCalories = workouts.fold(0, (sum, w) => sum + (w['calories_burned'] as int));

    return {
      'total_workouts': totalWorkouts,
      'total_duration': totalDuration,
      'total_calories': totalCalories,
      'average_duration': totalWorkouts > 0 ? totalDuration / totalWorkouts : 0,
    };
  }

  Future<Map<String, dynamic>> _getNutritionProgress(String userId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final response = await _supabase
        .from('nutrition_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', weekAgo.toIso8601String());

    final entries = List<Map<String, dynamic>>.from(response);
    
    int totalCalories = entries.fold(0, (sum, e) => sum + (e['calories'] as int));
    double totalProtein = entries.fold(0.0, (sum, e) => sum + (e['protein'] as num).toDouble());

    return {
      'total_entries': entries.length,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'average_calories': entries.isNotEmpty ? totalCalories / entries.length : 0,
    };
  }

  Future<Map<String, dynamic>> _getUserContext(String userId) async {
    final profile = await _getUserProfile(userId);
    final recentActivities = await _getRecentActivities(userId);
    
    return {
      'profile': profile,
      'recent_activities': recentActivities,
    };
  }

  List<String> _getDefaultMotivationalMessages() {
    return [
      'Every workout brings you closer to your goals! 💪',
      'Consistency is key - you\'re building healthy habits!',
      'Your future self will thank you for the effort you\'re putting in today!',
    ];
  }
}