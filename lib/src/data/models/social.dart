import 'package:equatable/equatable.dart';

class UserConnection extends Equatable {
  final String id;
  final String userId;
  final String connectedUserId;
  final String connectionType; // friend, following, blocked
  final DateTime createdAt;
  final bool isAccepted;

  const UserConnection({
    required this.id,
    required this.userId,
    required this.connectedUserId,
    required this.connectionType,
    required this.createdAt,
    this.isAccepted = false,
  });

  @override
  List<Object> get props => [id, userId, connectedUserId, connectionType, createdAt, isAccepted];

  factory UserConnection.fromMap(Map<String, dynamic> map) {
    return UserConnection(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      connectedUserId: map['connected_user_id'] as String,
      connectionType: map['connection_type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isAccepted: map['is_accepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'connected_user_id': connectedUserId,
      'connection_type': connectionType,
      'created_at': createdAt.toIso8601String(),
      'is_accepted': isAccepted,
    };
  }
}

class SocialPost extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String postType; // workout, nutrition, progress, achievement, general
  final List<String> imageUrls;
  final String? videoUrl;
  final Map<String, dynamic>? metadata; // workout data, nutrition data, etc.
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isPublic;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.postType,
    this.imageUrls = const [],
    this.videoUrl,
    this.metadata,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isPublic = true,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, userId, content, postType, imageUrls, videoUrl,
    metadata, likesCount, commentsCount, sharesCount,
    isPublic, tags, createdAt, updatedAt
  ];

  factory SocialPost.fromMap(Map<String, dynamic> map) {
    return SocialPost(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      postType: map['post_type'] as String,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      videoUrl: map['video_url'] as String?,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      likesCount: map['likes_count'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      sharesCount: map['shares_count'] as int? ?? 0,
      isPublic: map['is_public'] as bool? ?? true,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'post_type': postType,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'metadata': metadata,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_public': isPublic,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PostComment extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentCommentId;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, postId, userId, content, parentCommentId,
    likesCount, createdAt, updatedAt
  ];

  factory PostComment.fromMap(Map<String, dynamic> map) {
    return PostComment(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      parentCommentId: map['parent_comment_id'] as String?,
      likesCount: map['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_comment_id': parentCommentId,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WorkoutBuddy extends Equatable {
  final String id;
  final String userId;
  final String buddyUserId;
  final String status; // pending, active, paused
  final List<String> sharedGoals;
  final Map<String, dynamic> preferences; // workout times, types, etc.
  final DateTime createdAt;
  final DateTime? lastWorkoutTogether;

  const WorkoutBuddy({
    required this.id,
    required this.userId,
    required this.buddyUserId,
    required this.status,
    required this.sharedGoals,
    required this.preferences,
    required this.createdAt,
    this.lastWorkoutTogether,
  });

  @override
  List<Object?> get props => [
    id, userId, buddyUserId, status, sharedGoals,
    preferences, createdAt, lastWorkoutTogether
  ];

  factory WorkoutBuddy.fromMap(Map<String, dynamic> map) {
    return WorkoutBuddy(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      buddyUserId: map['buddy_user_id'] as String,
      status: map['status'] as String,
      sharedGoals: List<String>.from(map['shared_goals']),
      preferences: Map<String, dynamic>.from(map['preferences']),
      createdAt: DateTime.parse(map['created_at'] as String),
      lastWorkoutTogether: map['last_workout_together'] != null 
          ? DateTime.parse(map['last_workout_together'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'buddy_user_id': buddyUserId,
      'status': status,
      'shared_goals': sharedGoals,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'last_workout_together': lastWorkoutTogether?.toIso8601String(),
    };
  }
}

class Leaderboard extends Equatable {
  final String id;
  final String name;
  final String type; // weekly_steps, monthly_workouts, yearly_calories, etc.
  final String period; // daily, weekly, monthly, yearly
  final List<LeaderboardEntry> entries;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const Leaderboard({
    required this.id,
    required this.name,
    required this.type,
    required this.period,
    required this.entries,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  @override
  List<Object> get props => [id, name, type, period, entries, startDate, endDate, isActive];

  factory Leaderboard.fromMap(Map<String, dynamic> map) {
    return Leaderboard(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      period: map['period'] as String,
      entries: (map['entries'] as List)
          .map((entry) => LeaderboardEntry.fromMap(entry))
          .toList(),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'period': period,
      'entries': entries.map((entry) => entry.toMap()).toList(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class LeaderboardEntry extends Equatable {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int rank;
  final double score;
  final Map<String, dynamic> details;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.rank,
    required this.score,
    required this.details,
  });

  @override
  List<Object?> get props => [userId, username, avatarUrl, rank, score, details];

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['user_id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      rank: map['rank'] as int,
      score: (map['score'] as num).toDouble(),
      details: Map<String, dynamic>.from(map['details']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'rank': rank,
      'score': score,
      'details': details,
    };
  }
}