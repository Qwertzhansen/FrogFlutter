
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frogg_flutter/src/data/models/profile.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<Profile?> fetchProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    if (response != null) {
      return Profile.fromMap(response);
    }
    return null;
  }

  Future<void> updateProfile({
    required String userId,
    required String username,
    required String avatarUrl,
  }) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
    });
  }
}
