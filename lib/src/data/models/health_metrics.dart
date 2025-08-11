import 'package:equatable/equatable.dart';

class HealthMetrics extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final int? heartRate;
  final int? restingHeartRate;
  final int? steps;
  final double? distance; // in km
  final int? activeMinutes;
  final int? caloriesBurned;
  final double? vo2Max;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final double? bloodSugar; // mg/dL
  final double? bodyTemperature; // Celsius
  final int? respiratoryRate;
  final Map<String, dynamic>? additionalMetrics;
  final String dataSource; // manual, apple_health, google_fit, fitbit, etc.
  final DateTime createdAt;

  const HealthMetrics({
    required this.id,
    required this.userId,
    required this.date,
    this.heartRate,
    this.restingHeartRate,
    this.steps,
    this.distance,
    this.activeMinutes,
    this.caloriesBurned,
    this.vo2Max,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bloodSugar,
    this.bodyTemperature,
    this.respiratoryRate,
    this.additionalMetrics,
    required this.dataSource,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, heartRate, restingHeartRate, steps,
    distance, activeMinutes, caloriesBurned, vo2Max,
    bloodPressureSystolic, bloodPressureDiastolic, bloodSugar,
    bodyTemperature, respiratoryRate, additionalMetrics,
    dataSource, createdAt
  ];

  factory HealthMetrics.fromMap(Map<String, dynamic> map) {
    return HealthMetrics(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      heartRate: map['heart_rate'] as int?,
      restingHeartRate: map['resting_heart_rate'] as int?,
      steps: map['steps'] as int?,
      distance: (map['distance'] as num?)?.toDouble(),
      activeMinutes: map['active_minutes'] as int?,
      caloriesBurned: map['calories_burned'] as int?,
      vo2Max: (map['vo2_max'] as num?)?.toDouble(),
      bloodPressureSystolic: map['blood_pressure_systolic'] as int?,
      bloodPressureDiastolic: map['blood_pressure_diastolic'] as int?,
      bloodSugar: (map['blood_sugar'] as num?)?.toDouble(),
      bodyTemperature: (map['body_temperature'] as num?)?.toDouble(),
      respiratoryRate: map['respiratory_rate'] as int?,
      additionalMetrics: map['additional_metrics'] != null 
          ? Map<String, dynamic>.from(map['additional_metrics'])
          : null,
      dataSource: map['data_source'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'heart_rate': heartRate,
      'resting_heart_rate': restingHeartRate,
      'steps': steps,
      'distance': distance,
      'active_minutes': activeMinutes,
      'calories_burned': caloriesBurned,
      'vo2_max': vo2Max,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'blood_sugar': bloodSugar,
      'body_temperature': bodyTemperature,
      'respiratory_rate': respiratoryRate,
      'additional_metrics': additionalMetrics,
      'data_source': dataSource,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MedicationReminder extends Equatable {
  final String id;
  final String userId;
  final String medicationName;
  final String dosage;
  final String frequency; // daily, twice_daily, weekly, etc.
  final List<String> reminderTimes; // HH:mm format
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? notes;
  final String? prescribedBy;
  final DateTime createdAt;

  const MedicationReminder({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
    this.prescribedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, medicationName, dosage, frequency,
    reminderTimes, startDate, endDate, isActive,
    notes, prescribedBy, createdAt
  ];

  factory MedicationReminder.fromMap(Map<String, dynamic> map) {
    return MedicationReminder(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      medicationName: map['medication_name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      reminderTimes: List<String>.from(map['reminder_times']),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null 
          ? DateTime.parse(map['end_date'] as String)
          : null,
      isActive: map['is_active'] as bool? ?? true,
      notes: map['notes'] as String?,
      prescribedBy: map['prescribed_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'reminder_times': reminderTimes,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'notes': notes,
      'prescribed_by': prescribedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SymptomEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String symptom;
  final int severity; // 1-10 scale
  final String? trigger;
  final String? treatment;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;

  const SymptomEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.symptom,
    required this.severity,
    this.trigger,
    this.treatment,
    this.notes,
    this.tags = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, symptom, severity,
    trigger, treatment, notes, tags, createdAt
  ];

  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    return SymptomEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      symptom: map['symptom'] as String,
      severity: map['severity'] as int,
      trigger: map['trigger'] as String?,
      treatment: map['treatment'] as String?,
      notes: map['notes'] as String?,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'symptom': symptom,
      'severity': severity,
      'trigger': trigger,
      'treatment': treatment,
      'notes': notes,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FastingSession extends Equatable {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDuration; // in hours
  final int? actualDuration; // in hours
  final String fastingType; // intermittent, extended, etc.
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;

  const FastingSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration,
    required this.fastingType,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, startTime, endTime, plannedDuration,
    actualDuration, fastingType, notes, isCompleted, createdAt
  ];

  factory FastingSession.fromMap(Map<String, dynamic> map) {
    return FastingSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time'] as String)
          : null,
      plannedDuration: map['planned_duration'] as int,
      actualDuration: map['actual_duration'] as int?,
      fastingType: map['fasting_type'] as String,
      notes: map['notes'] as String?,
      isCompleted: map['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'planned_duration': plannedDuration,
      'actual_duration': actualDuration,
      'fasting_type': fastingType,
      'notes': notes,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}