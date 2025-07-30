
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String username;
  final String avatarUrl;

  const Profile({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  @override
  List<Object> get props => [id, username, avatarUrl];

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String,
    );
  }
}
