import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();
  static const _pendingNutri = 'pending_nutrition';
  static const _pendingWorkout = 'pending_workout';

  Future<void> addPendingNutrition(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingNutri) ?? [];
    list.insert(0, jsonEncode(entry));
    await prefs.setStringList(_pendingNutri, list);
  }

  Future<void> addPendingWorkout(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingWorkout) ?? [];
    list.insert(0, jsonEncode(entry));
    await prefs.setStringList(_pendingWorkout, list);
  }

  Future<Map<String, int>> getPendingCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final n = (prefs.getStringList(_pendingNutri) ?? []).length;
    final w = (prefs.getStringList(_pendingWorkout) ?? []).length;
    return {'nutrition': n, 'workout': w};
  }

  Future<void> trySyncAll(String userId) async {
    final client = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();

    // Nutrition
    var nList = prefs.getStringList(_pendingNutri) ?? [];
    if (nList.isNotEmpty) {
      final keep = <String>[];
      for (final s in nList) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        try {
          await client.from('nutrition_entries').insert(m);
        } catch (_) {
          keep.add(s);
        }
      }
      await prefs.setStringList(_pendingNutri, keep);
    }

    // Workout
    var wList = prefs.getStringList(_pendingWorkout) ?? [];
    if (wList.isNotEmpty) {
      final keep = <String>[];
      for (final s in wList) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        try {
          await client.from('workout_entries').insert(m);
        } catch (_) {
          keep.add(s);
        }
      }
      await prefs.setStringList(_pendingWorkout, keep);
    }
  }
}