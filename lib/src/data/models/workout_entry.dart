
import 'package:equatable/equatable.dart';

class WorkoutEntry extends Equatable {
  final String id;
  final DateTime date;
  final String exercise;
  final int duration;

  const WorkoutEntry({
    required this.id,
    required this.date,
    required this.exercise,
    required this.duration,
  });

  @override
  List<Object> get props => [id, date, exercise, duration];

  factory WorkoutEntry.fromMap(Map<String, dynamic> map) {
    return WorkoutEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      exercise: map['exercise'] as String,
      duration: map['duration'] as int,
    );
  }
}
