import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/nutrition_entry.dart';
import '../../services/ai_service.dart';
import '../../services/offline_cache_service.dart';
import '../../services/sync_service.dart';

class NutritionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AIService _aiService = AIService();

  Future<List<NutritionEntry>> getNutritionEntries(String userId, {DateTime? date}) async {
    try {
      var query = _supabase
          .from('nutrition_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Date filtering is handled in the application layer below
      // due to Supabase API compatibility issues

      final response = await query;
      var entries = (response as List)
          .map((entry) => NutritionEntry.fromMap(entry))
          .toList();
      // cache on success
      await OfflineCacheService.instance.saveNutritionEntries(
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
      final cached = await OfflineCacheService.instance.getNutritionEntries();
      if (cached.isNotEmpty) {
        var entries = cached.map((m) => NutritionEntry.fromMap(m)).toList();
        // Filter by date if provided
        if (date != null) {
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));
          entries = entries.where((entry) =>
              entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              entry.date.isBefore(endOfDay)).toList();
        }
        return entries;
      }
      throw Exception('Failed to fetch nutrition entries: $e');
    }
  }

  Future<NutritionEntry> addNutritionEntryFromText(
    String userId,
    String description,
  ) async {
    try {
      // Use AI to parse the description
      final aiAnalysis = await _aiService.analyzeNutritionDescription(description);
      
      final entry = NutritionEntry(
        id: '', // Will be set by Supabase
        userId: userId,
        date: DateTime.now(),
        foodItem: aiAnalysis['food_item'] ?? 'Unknown Food',
        quantity: aiAnalysis['quantity'] ?? '1 serving',
        calories: aiAnalysis['calories'] ?? 0,
        protein: (aiAnalysis['protein'] ?? 0).toDouble(),
        carbs: (aiAnalysis['carbs'] ?? 0).toDouble(),
        fat: (aiAnalysis['fat'] ?? 0).toDouble(),
        notes: aiAnalysis['notes'] ?? description,
        inputMethod: 'text',
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('nutrition_entries')
          .insert(entry.toMap())
          .select()
          .single();

      return NutritionEntry.fromMap(response);
    } catch (e) {
      // offline fallback: create local entry and enqueue for sync
      final fallback = NutritionEntry(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        date: DateTime.now(),
        foodItem: 'Logged (offline)',
        quantity: '1 serving',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        notes: description,
        inputMethod: 'text',
        createdAt: DateTime.now(),
      );
      final cached = await OfflineCacheService.instance.getNutritionEntries();
      final updated = [fallback.toMap(), ...cached];
      await OfflineCacheService.instance.saveNutritionEntries(updated);
      // enqueue for sync
      await SyncService.instance.addPendingNutrition(fallback.toMap());
      return fallback;
    }
  }

  Future<NutritionEntry> addNutritionEntryFromVoice(
    String userId,
    String voiceDescription,
  ) async {
    try {
      final aiAnalysis = await _aiService.analyzeNutritionDescription(voiceDescription);
      
      final entry = NutritionEntry(
        id: '',
        userId: userId,
        date: DateTime.now(),
        foodItem: aiAnalysis['food_item'] ?? 'Unknown Food',
        quantity: aiAnalysis['quantity'] ?? '1 serving',
        calories: aiAnalysis['calories'] ?? 0,
        protein: (aiAnalysis['protein'] ?? 0).toDouble(),
        carbs: (aiAnalysis['carbs'] ?? 0).toDouble(),
        fat: (aiAnalysis['fat'] ?? 0).toDouble(),
        notes: aiAnalysis['notes'] ?? voiceDescription,
        inputMethod: 'voice',
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('nutrition_entries')
          .insert(entry.toMap())
          .select()
          .single();

      return NutritionEntry.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add nutrition entry from voice: $e');
    }
  }

  Future<NutritionEntry> addNutritionEntryFromImage(
    String userId,
    File imageFile,
  ) async {
    try {
      // Upload image to Supabase Storage
      final fileName = 'nutrition_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await _uploadImage(imageFile, fileName);
      
      // Analyze image with AI
      final aiAnalysis = await _aiService.analyzeFoodImage(imageFile);
      
      final entry = NutritionEntry(
        id: '',
        userId: userId,
        date: DateTime.now(),
        foodItem: aiAnalysis['food_item'] ?? 'Unknown Food',
        quantity: aiAnalysis['quantity'] ?? '1 serving',
        calories: aiAnalysis['calories'] ?? 0,
        protein: (aiAnalysis['protein'] ?? 0).toDouble(),
        carbs: (aiAnalysis['carbs'] ?? 0).toDouble(),
        fat: (aiAnalysis['fat'] ?? 0).toDouble(),
        imageUrl: imageUrl,
        notes: aiAnalysis['notes'] ?? 'Added from image',
        inputMethod: 'image',
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('nutrition_entries')
          .insert(entry.toMap())
          .select()
          .single();

      return NutritionEntry.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add nutrition entry from image: $e');
    }
  }

  Future<String> _uploadImage(File imageFile, String fileName) async {
    try {
      await _supabase.storage
          .from('nutrition-images')
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from('nutrition-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteNutritionEntry(String entryId) async {
    try {
      await _supabase
          .from('nutrition_entries')
          .delete()
          .eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to delete nutrition entry: $e');
    }
  }

  Future<NutritionEntry> updateNutritionEntry(NutritionEntry entry) async {
    try {
      final response = await _supabase
          .from('nutrition_entries')
          .update(entry.toMap())
          .eq('id', entry.id)
          .select()
          .single();

      return NutritionEntry.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update nutrition entry: $e');
    }
  }

  Future<Map<String, dynamic>> getDailyNutritionSummary(String userId, DateTime date) async {
    try {
      final entries = await getNutritionEntries(userId, date: date);
      
      int totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final entry in entries) {
        totalCalories += entry.calories;
        totalProtein += entry.protein;
        totalCarbs += entry.carbs;
        totalFat += entry.fat;
      }

      return {
        'date': date.toIso8601String(),
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'entry_count': entries.length,
      };
    } catch (e) {
      throw Exception('Failed to get daily nutrition summary: $e');
    }
  }
}