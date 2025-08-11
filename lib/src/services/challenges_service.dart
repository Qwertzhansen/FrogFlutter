import 'package:shared_preferences/shared_preferences.dart';

class ChallengesService {
  ChallengesService._internal();
  static final ChallengesService instance = ChallengesService._internal();
  static const _joinedKey = 'joined_challenges';
  static const _rewardedKey = 'rewarded_challenges';

  Future<Set<String>> getJoined() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_joinedKey) ?? [];
    return Set<String>.from(list);
  }

  Future<void> join(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getJoined();
    set.add(id);
    await prefs.setStringList(_joinedKey, set.toList());
  }

  Future<void> leave(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getJoined();
    set.remove(id);
    await prefs.setStringList(_joinedKey, set.toList());
  }

  Future<Set<String>> getRewarded() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_rewardedKey) ?? [];
    return Set<String>.from(list);
  }

  Future<void> markRewarded(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getRewarded();
    set.add(id);
    await prefs.setStringList(_rewardedKey, set.toList());
  }
}