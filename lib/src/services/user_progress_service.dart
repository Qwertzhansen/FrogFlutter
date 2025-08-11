import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService {
  UserProgressService._internal();
  static final UserProgressService instance = UserProgressService._internal();
  static const _extraXpKey = 'extra_xp_total';

  Future<int> getExtraXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_extraXpKey) ?? 0;
  }

  Future<void> addXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getExtraXp();
    await prefs.setInt(_extraXpKey, current + amount);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_extraXpKey, 0);
  }
}