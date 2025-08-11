import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category; // fitness, nutrition, consistency, social
  final int points;
  final String rarity; // common, rare, epic, legendary
  final Map<String, dynamic> criteria;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime createdAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.points,
    required this.rarity,
    required this.criteria,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, name, description, iconUrl, category,
    points, rarity, criteria, isUnlocked, unlockedAt, createdAt
  ];

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      iconUrl: map['icon_url'] as String,
      category: map['category'] as String,
      points: map['points'] as int,
      rarity: map['rarity'] as String,
      criteria: Map<String, dynamic>.from(map['criteria']),
      isUnlocked: map['is_unlocked'] as bool? ?? false,
      unlockedAt: map['unlocked_at'] != null 
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category,
      'points': points,
      'rarity': rarity,
      'criteria': criteria,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserLevel extends Equatable {
  final String userId;
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final int totalXP;
  final String title;
  final List<String> unlockedFeatures;
  final DateTime lastUpdated;

  const UserLevel({
    required this.userId,
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.totalXP,
    required this.title,
    required this.unlockedFeatures,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [
    userId, level, currentXP, xpToNextLevel,
    totalXP, title, unlockedFeatures, lastUpdated
  ];

  factory UserLevel.fromMap(Map<String, dynamic> map) {
    return UserLevel(
      userId: map['user_id'] as String,
      level: map['level'] as int,
      currentXP: map['current_xp'] as int,
      xpToNextLevel: map['xp_to_next_level'] as int,
      totalXP: map['total_xp'] as int,
      title: map['title'] as String,
      unlockedFeatures: List<String>.from(map['unlocked_features']),
      lastUpdated: DateTime.parse(map['last_updated'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'level': level,
      'current_xp': currentXP,
      'xp_to_next_level': xpToNextLevel,
      'total_xp': totalXP,
      'title': title,
      'unlocked_features': unlockedFeatures,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class Challenge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // daily, weekly, monthly, custom
  final Map<String, dynamic> goal;
  final int rewardPoints;
  final String? rewardBadge;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int participantCount;
  final String difficulty;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.goal,
    required this.rewardPoints,
    this.rewardBadge,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.participantCount = 0,
    required this.difficulty,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, name, description, type, goal, rewardPoints,
    rewardBadge, startDate, endDate, isActive,
    participantCount, difficulty, createdAt
  ];

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      goal: Map<String, dynamic>.from(map['goal']),
      rewardPoints: map['reward_points'] as int,
      rewardBadge: map['reward_badge'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isActive: map['is_active'] as bool? ?? true,
      participantCount: map['participant_count'] as int? ?? 0,
      difficulty: map['difficulty'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'goal': goal,
      'reward_points': rewardPoints,
      'reward_badge': rewardBadge,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'participant_count': participantCount,
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
    };
  }
}