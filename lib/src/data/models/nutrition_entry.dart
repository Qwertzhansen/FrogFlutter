
import 'package:equatable/equatable.dart';

class NutritionEntry extends Equatable {
  final String id;
  final DateTime date;
  final String foodItem;
  final int calories;

  const NutritionEntry({
    required this.id,
    required this.date,
    required this.foodItem,
    required this.calories,
  });

  @override
  List<Object> get props => [id, date, foodItem, calories];

  factory NutritionEntry.fromMap(Map<String, dynamic> map) {
    return NutritionEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      foodItem: map['food_item'] as String,
      calories: map['calories'] as int,
    );
  }
}
