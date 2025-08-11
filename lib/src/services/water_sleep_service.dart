import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WaterSleepService {
  WaterSleepService._internal();
  static final WaterSleepService instance = WaterSleepService._internal();

  String _keyForDate(DateTime d) => 'water_sleep_' + DateFormat('yyyyMMdd').format(d);
  String get _todayKey => _keyForDate(DateTime.now());

  Future<Map<String, dynamic>> getToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todayKey);
    if (raw == null) return {'water': 0, 'sleep': 0};
    try {
      final parts = raw.split(',');
      return {'water': int.parse(parts[0]), 'sleep': double.parse(parts[1])};
    } catch (_) {
      return {'water': 0, 'sleep': 0};
    }
  }

  Future<void> setWater(int glasses) async {
    final prefs = await SharedPreferences.getInstance();
    final today = await getToday();
    final val = '${glasses.clamp(0, 30)},${today['sleep'] ?? 0}';
    await prefs.setString(_todayKey, val);
  }

  Future<void> setSleep(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    final today = await getToday();
    final val = '${today['water'] ?? 0},${hours.clamp(0, 24)}';
    await prefs.setString(_todayKey, val);
  }

  Future<Map<String, dynamic>> getForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(date));
    if (raw == null) return {'water': 0, 'sleep': 0};
    try {
      final parts = raw.split(',');
      return {'water': int.parse(parts[0]), 'sleep': double.parse(parts[1])};
    } catch (_) {
      return {'water': 0, 'sleep': 0};
    }
  }

  Future<int> countWaterDays(int days) async {
    int count = 0;
    for (int i = 0; i < days; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final data = await getForDate(d);
      if ((data['water'] as int? ?? 0) > 0) count++;
    }
    return count;
  }
}