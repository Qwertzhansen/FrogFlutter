import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_entry.dart';
import '../../services/ai_service.dart';
import '../../services/offline_cache_service.dart';
import '../../services/sync_service.dart';

class WorkoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AIService _aiService = AIService();

  Future<List<WorkoutEntry>> getWorkoutEntries(String userId, {DateTime? date}) async {
    try {
      var query = _supabase
          .from('workout_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Date filtering is handled in the application layer below
      // due to Supabase API compatibility issues

      final response = await query;
      var entries = (response as List)
          .map((entry) => WorkoutEntry.fromMap(entry))
          .toList();
      // cache on success
      await OfflineCacheService.instance.saveWorkoutEntries(
        entries.map((e) => e.toMap()).toList(),
      );
      
      // Filter by date in application layer if date is specified
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        entries = entries.where((entry) {
          return entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                 entry.date.isBefore(endOfDay);
        }).toList();
      }
      
      return entries;
    } catch (e) {
      // fallback to cache
      final cached = await OfflineCacheService.instance.getWorkoutEntries();
      if (cached.isNotEmpty) {
        var entries = cached.map((m) => WorkoutEntry.fromMap(m)).toList();
        if (date != null) {
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));
          entries = entries.where((entry) =>
              entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              entry.date.isBefore(endOfDay)).toList();
        }
        return entries;
      }
      throw Exception('Failed to fetch workout entries: $e');
    }
  }

  Future<WorkoutEntry> addWorkoutEntryFromText(
    String userId,
    String description,
  ) async {
    try {
      // Use AI to parse the description
      final aiAnalysis = await _aiService.analyzeWorkoutDescription(description);
      
      final entry = WorkoutEntry(
        id: '', // Will be set by Supabase
        userId: userId,
        date: DateTime.now(),
        exercise: aiAnalysis['exercise'] ?? 'General Exercise',
        duration: aiAnalysis['duration'] ?? 30,
        intensity: aiAnalysis['intensity'] ?? 'medium',
        caloriesBurned: aiAnalysis['calories_burned'] ?? 200,
        notes: aiAnalysis['notes'] ?? description,
        inputMethod: 'text',
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('workout_entries')
          .insert(entry.toMap())
          .select()
          .single();

      return WorkoutEntry.fromMap(response);
    } catch (e) {
      final fallback = WorkoutEntry(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        date: DateTime.now(),
        exercise: 'Logged (offline)',
        duration: 30,
        intensity: 'medium',
        caloriesBurned: 0,
        notes: description,
        inputMethod: 'text',
        createdAt: DateTime.now(),
      );
      final cached = await OfflineCacheService.instance.getWorkoutEntries();
      final updated = [fallback.toMap(), ...cached];
      await OfflineCacheService.instance.saveWorkoutEntries(updated);
      // enqueue for sync
      await SyncService.instance.addPendingWorkout(fallback.toMap());
      return fallback;
    }
  }

  Future<WorkoutEntry> addWorkoutEntryFromVoice(
    String userId,
    String voiceDescription,
  ) async {
    try {
      final aiAnalysis = await _aiService.analyzeWorkoutDescription(voiceDescription);
      
      final entry = WorkoutEntry(
        id: '',
        userId: userId,
        date: DateTime.now(),
        exercise: aiAnalysis['exercise'] ?? 'General Exercise',
        duration: aiAnalysis['duration'] ?? 30,
        intensity: aiAnalysis['intensity'] ?? 'medium',
        caloriesBurned: aiAnalysis['calories_burned'] ?? 200,
        notes: aiAnalysis['notes'] ?? voiceDescription,
        inputMethod: 'voice',
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('workout_entries')
          .insert(entry.toMap())
          .select()
          .single();

      return WorkoutEntry.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add workout entry from voice: $e');
    }
  }

  Future<void> deleteWorkoutEntry(String entryId) async {
    try {
      await _supabase
          .from('workout_entries')
          .delete()
          .eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to delete workout entry: $e');
    }
  }

  Future<WorkoutEntry> updateWorkoutEntry(WorkoutEntry entry) async {
    try {
      final response = await _supabase
          .from('workout_entries')
          .update(entry.toMap())
          .eq('id', entry.id)
          .select()
          .single();

      return WorkoutEntry.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update workout entry: $e');
    }
  }

  Future<Map<String, dynamic>> getDailyWorkoutSummary(String userId, DateTime date) async {
    try {
      final entries = await getWorkoutEntries(userId, date: date);
      
      int totalDuration = 0;
      int totalCaloriesBurned = 0;
      Map<String, int> exerciseCount = {};

      for (final entry in entries) {
        totalDuration += entry.duration;
        totalCaloriesBurned += entry.caloriesBurned;
        exerciseCount[entry.exercise] = (exerciseCount[entry.exercise] ?? 0) + 1;
      }

      return {
        'date': date.toIso8601String(),
        'total_duration': totalDuration,
        'total_calories_burned': totalCaloriesBurned,
        'exercise_count': exerciseCount,
        'workout_count': entries.length,
      };
    } catch (e) {
      throw Exception('Failed to get daily workout summary: $e');
    }
  }

  Future<Map<String, dynamic>> getWeeklyWorkoutSummary(String userId, DateTime startDate) async {
    try {
      final endDate = startDate.add(const Duration(days: 7));
      
      final response = await _supabase
          .from('workout_entries')
          .select()
          .eq('user_id', userId);
          // Note: Date filtering moved to application layer due to API compatibility

      var entries = (response as List)
          .map((entry) => WorkoutEntry.fromMap(entry))
          .toList();
      
      // Filter by date range in application layer
      entries = entries.where((entry) {
        return entry.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               entry.date.isBefore(endDate);
      }).toList();

      int totalDuration = 0;
      int totalCaloriesBurned = 0;
      int workoutDays = 0;
      Set<String> uniqueDays = {};

      for (final entry in entries) {
        totalDuration += entry.duration;
        totalCaloriesBurned += entry.caloriesBurned;
        
        final dayKey = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
        uniqueDays.add(dayKey);
      }

      workoutDays = uniqueDays.length;

      return {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'total_duration': totalDuration,
        'total_calories_burned': totalCaloriesBurned,
        'workout_days': workoutDays,
        'total_workouts': entries.length,
        'average_duration': entries.isNotEmpty ? totalDuration / entries.length : 0,
      };
    } catch (e) {
      throw Exception('Failed to get weekly workout summary: $e');
    }
  }
}