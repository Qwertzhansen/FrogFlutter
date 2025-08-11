
import 'package:equatable/equatable.dart';

class WorkoutEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String exercise;
  final int duration; // in minutes
  final String intensity; // low, medium, high
  final int caloriesBurned;
  final String? notes;
  final String inputMethod; // 'text', 'voice'
  final DateTime createdAt;

  const WorkoutEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.exercise,
    required this.duration,
    required this.intensity,
    required this.caloriesBurned,
    this.notes,
    required this.inputMethod,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, exercise, duration, intensity, 
    caloriesBurned, notes, inputMethod, createdAt
  ];

  factory WorkoutEntry.fromMap(Map<String, dynamic> map) {
    return WorkoutEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      exercise: map['exercise'] as String,
      duration: map['duration'] as int,
      intensity: map['intensity'] as String,
      caloriesBurned: map['calories_burned'] as int,
      notes: map['notes'] as String?,
      inputMethod: map['input_method'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'exercise': exercise,
      'duration': duration,
      'intensity': intensity,
      'calories_burned': caloriesBurned,
      'notes': notes,
      'input_method': inputMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WorkoutEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? exercise,
    int? duration,
    String? intensity,
    int? caloriesBurned,
    String? notes,
    String? inputMethod,
    DateTime? createdAt,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      exercise: exercise ?? this.exercise,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      inputMethod: inputMethod ?? this.inputMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
