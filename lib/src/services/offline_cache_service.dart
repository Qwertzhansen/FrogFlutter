import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  OfflineCacheService._internal();
  static final OfflineCacheService instance = OfflineCacheService._internal();

  static const String _nutritionKey = 'cache_nutrition_entries';
  static const String _workoutKey = 'cache_workout_entries';

  Future<void> saveNutritionEntries(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nutritionKey, jsonEncode(list));
  }

  Future<void> saveWorkoutEntries(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getNutritionEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_nutritionKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<List<Map<String, dynamic>>> getWorkoutEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_workoutKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list;
  }
}