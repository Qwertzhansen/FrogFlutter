import 'package:equatable/equatable.dart';

class ProgressPhoto extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String imageUrl;
  final String photoType; // front, side, back
  final double? weight;
  final Map<String, double>? measurements; // chest, waist, arms, etc.
  final String? notes;
  final DateTime createdAt;

  const ProgressPhoto({
    required this.id,
    required this.userId,
    required this.date,
    required this.imageUrl,
    required this.photoType,
    this.weight,
    this.measurements,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, imageUrl, photoType,
    weight, measurements, notes, createdAt
  ];

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) {
    return ProgressPhoto(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      imageUrl: map['image_url'] as String,
      photoType: map['photo_type'] as String,
      weight: (map['weight'] as num?)?.toDouble(),
      measurements: map['measurements'] != null 
          ? Map<String, double>.from(map['measurements'])
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'image_url': imageUrl,
      'photo_type': photoType,
      'weight': weight,
      'measurements': measurements,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class BodyMeasurement extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final double? weight;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftArm;
  final double? rightArm;
  final double? leftThigh;
  final double? rightThigh;
  final String? notes;
  final DateTime createdAt;

  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, weight, bodyFatPercentage, muscleMass,
    chest, waist, hips, leftArm, rightArm, leftThigh, rightThigh,
    notes, createdAt
  ];

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num?)?.toDouble(),
      bodyFatPercentage: (map['body_fat_percentage'] as num?)?.toDouble(),
      muscleMass: (map['muscle_mass'] as num?)?.toDouble(),
      chest: (map['chest'] as num?)?.toDouble(),
      waist: (map['waist'] as num?)?.toDouble(),
      hips: (map['hips'] as num?)?.toDouble(),
      leftArm: (map['left_arm'] as num?)?.toDouble(),
      rightArm: (map['right_arm'] as num?)?.toDouble(),
      leftThigh: (map['left_thigh'] as num?)?.toDouble(),
      rightThigh: (map['right_thigh'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'body_fat_percentage': bodyFatPercentage,
      'muscle_mass': muscleMass,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'left_arm': leftArm,
      'right_arm': rightArm,
      'left_thigh': leftThigh,
      'right_thigh': rightThigh,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}