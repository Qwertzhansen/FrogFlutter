import 'package:equatable/equatable.dart';

class SleepEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int sleepDuration; // in minutes
  final int deepSleep; // in minutes
  final int lightSleep; // in minutes
  final int remSleep; // in minutes
  final int awakeTime; // in minutes
  final int sleepQuality; // 1-10 scale
  final String? notes;
  final Map<String, dynamic>? factors; // caffeine, stress, exercise, etc.
  final DateTime createdAt;

  const SleepEntry({
    required this.id,
    required this.userId,
    required this.bedtime,
    required this.wakeTime,
    required this.sleepDuration,
    this.deepSleep = 0,
    this.lightSleep = 0,
    this.remSleep = 0,
    this.awakeTime = 0,
    required this.sleepQuality,
    this.notes,
    this.factors,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, bedtime, wakeTime, sleepDuration,
    deepSleep, lightSleep, remSleep, awakeTime,
    sleepQuality, notes, factors, createdAt
  ];

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      bedtime: DateTime.parse(map['bedtime'] as String),
      wakeTime: DateTime.parse(map['wake_time'] as String),
      sleepDuration: map['sleep_duration'] as int,
      deepSleep: map['deep_sleep'] as int? ?? 0,
      lightSleep: map['light_sleep'] as int? ?? 0,
      remSleep: map['rem_sleep'] as int? ?? 0,
      awakeTime: map['awake_time'] as int? ?? 0,
      sleepQuality: map['sleep_quality'] as int,
      notes: map['notes'] as String?,
      factors: map['factors'] != null 
          ? Map<String, dynamic>.from(map['factors'])
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'bedtime': bedtime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'sleep_duration': sleepDuration,
      'deep_sleep': deepSleep,
      'light_sleep': lightSleep,
      'rem_sleep': remSleep,
      'awake_time': awakeTime,
      'sleep_quality': sleepQuality,
      'notes': notes,
      'factors': factors,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MoodEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final int mood; // 1-10 scale
  final int energy; // 1-10 scale
  final int stress; // 1-10 scale
  final int motivation; // 1-10 scale
  final List<String> emotions; // happy, sad, anxious, excited, etc.
  final String? notes;
  final Map<String, dynamic>? triggers; // work, relationships, health, etc.
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.energy,
    required this.stress,
    required this.motivation,
    required this.emotions,
    this.notes,
    this.triggers,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, mood, energy, stress,
    motivation, emotions, notes, triggers, createdAt
  ];

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      mood: map['mood'] as int,
      energy: map['energy'] as int,
      stress: map['stress'] as int,
      motivation: map['motivation'] as int,
      emotions: List<String>.from(map['emotions']),
      notes: map['notes'] as String?,
      triggers: map['triggers'] != null 
          ? Map<String, dynamic>.from(map['triggers'])
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'mood': mood,
      'energy': energy,
      'stress': stress,
      'motivation': motivation,
      'emotions': emotions,
      'notes': notes,
      'triggers': triggers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}