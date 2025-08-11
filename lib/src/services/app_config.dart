import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static final AppConfig instance = AppConfig._internal();
  AppConfig._internal();

  static const _mockAIKey = 'mock_ai_enabled';
  static const _notifEnabledKey = 'notif_enabled';
  static const _lunchTimeKey = 'notif_lunch_time';
  static const _eveningTimeKey = 'notif_evening_time';

  bool _mockAI = true; // default true when no API configured
  bool _notificationsEnabled = true;
  String _lunchTime = '13:00';
  String _eveningTime = '20:00';

  bool get mockAI => _mockAI;
  bool get notificationsEnabled => _notificationsEnabled;
  String get lunchTime => _lunchTime;
  String get eveningTime => _eveningTime;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mockAI = prefs.getBool(_mockAIKey) ?? true;
    _notificationsEnabled = prefs.getBool(_notifEnabledKey) ?? true;
    _lunchTime = prefs.getString(_lunchTimeKey) ?? '13:00';
    _eveningTime = prefs.getString(_eveningTimeKey) ?? '20:00';
  }

  Future<void> setMockAI(bool value) async {
    _mockAI = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mockAIKey, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, value);
  }

  Future<void> setLunchTime(String hhmm) async {
    _lunchTime = hhmm;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lunchTimeKey, hhmm);
  }

  Future<void> setEveningTime(String hhmm) async {
    _eveningTime = hhmm;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eveningTimeKey, hhmm);
  }
}