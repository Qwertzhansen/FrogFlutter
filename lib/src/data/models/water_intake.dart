import 'package:equatable/equatable.dart';

class WaterIntake extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final double amount; // in ml
  final String container; // glass, bottle, cup
  final DateTime timestamp;
  final String? notes;

  const WaterIntake({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.container,
    required this.timestamp,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, date, amount, container, timestamp, notes];

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      container: map['container'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'amount': amount,
      'container': container,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}

class HydrationGoal extends Equatable {
  final String userId;
  final double dailyGoal; // in ml
  final List<String> reminderTimes; // HH:mm format
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HydrationGoal({
    required this.userId,
    required this.dailyGoal,
    required this.reminderTimes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [userId, dailyGoal, reminderTimes, isActive, createdAt, updatedAt];

  factory HydrationGoal.fromMap(Map<String, dynamic> map) {
    return HydrationGoal(
      userId: map['user_id'] as String,
      dailyGoal: (map['daily_goal'] as num).toDouble(),
      reminderTimes: List<String>.from(map['reminder_times']),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'daily_goal': dailyGoal,
      'reminder_times': reminderTimes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}