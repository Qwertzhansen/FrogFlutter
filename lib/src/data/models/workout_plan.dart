import 'package:equatable/equatable.dart';

class WorkoutPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final String difficulty; // beginner, intermediate, advanced
  final int durationWeeks;
  final List<String> targetMuscleGroups;
  final List<WorkoutSession> sessions;
  final String imageUrl;
  final String category; // strength, cardio, flexibility, etc.
  final bool isPremium;
  final double rating;
  final int completedBy;
  final DateTime createdAt;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationWeeks,
    required this.targetMuscleGroups,
    required this.sessions,
    required this.imageUrl,
    required this.category,
    this.isPremium = false,
    this.rating = 0.0,
    this.completedBy = 0,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id, name, description, difficulty, durationWeeks,
    targetMuscleGroups, sessions, imageUrl, category,
    isPremium, rating, completedBy, createdAt
  ];

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as String,
      durationWeeks: map['duration_weeks'] as int,
      targetMuscleGroups: List<String>.from(map['target_muscle_groups']),
      sessions: (map['sessions'] as List)
          .map((session) => WorkoutSession.fromMap(session))
          .toList(),
      imageUrl: map['image_url'] as String,
      category: map['category'] as String,
      isPremium: map['is_premium'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      completedBy: map['completed_by'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'duration_weeks': durationWeeks,
      'target_muscle_groups': targetMuscleGroups,
      'sessions': sessions.map((session) => session.toMap()).toList(),
      'image_url': imageUrl,
      'category': category,
      'is_premium': isPremium,
      'rating': rating,
      'completed_by': completedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class WorkoutSession extends Equatable {
  final String id;
  final String name;
  final int dayNumber;
  final List<Exercise> exercises;
  final int estimatedDuration; // in minutes
  final String focusArea;

  const WorkoutSession({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.exercises,
    required this.estimatedDuration,
    required this.focusArea,
  });

  @override
  List<Object> get props => [id, name, dayNumber, exercises, estimatedDuration, focusArea];

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      name: map['name'] as String,
      dayNumber: map['day_number'] as int,
      exercises: (map['exercises'] as List)
          .map((exercise) => Exercise.fromMap(exercise))
          .toList(),
      estimatedDuration: map['estimated_duration'] as int,
      focusArea: map['focus_area'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'day_number': dayNumber,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'estimated_duration': estimatedDuration,
      'focus_area': focusArea,
    };
  }
}

class Exercise extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> muscleGroups;
  final String equipment;
  final String difficulty;
  final String instructions;
  final String videoUrl;
  final String imageUrl;
  final int sets;
  final int reps;
  final int restSeconds;
  final double weight;
  final String category;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.videoUrl,
    required this.imageUrl,
    this.sets = 1,
    this.reps = 1,
    this.restSeconds = 60,
    this.weight = 0.0,
    required this.category,
  });

  @override
  List<Object> get props => [
    id, name, description, muscleGroups, equipment,
    difficulty, instructions, videoUrl, imageUrl,
    sets, reps, restSeconds, weight, category
  ];

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      muscleGroups: List<String>.from(map['muscle_groups']),
      equipment: map['equipment'] as String,
      difficulty: map['difficulty'] as String,
      instructions: map['instructions'] as String,
      videoUrl: map['video_url'] as String,
      imageUrl: map['image_url'] as String,
      sets: map['sets'] as int? ?? 1,
      reps: map['reps'] as int? ?? 1,
      restSeconds: map['rest_seconds'] as int? ?? 60,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscle_groups': muscleGroups,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'video_url': videoUrl,
      'image_url': imageUrl,
      'sets': sets,
      'reps': reps,
      'rest_seconds': restSeconds,
      'weight': weight,
      'category': category,
    };
  }
}