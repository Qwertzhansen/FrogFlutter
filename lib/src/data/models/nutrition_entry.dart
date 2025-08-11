
import 'package:equatable/equatable.dart';

class NutritionEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String foodItem;
  final String quantity;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imageUrl;
  final String? notes;
  final String inputMethod; // 'text', 'voice', 'image'
  final DateTime createdAt;

  const NutritionEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.foodItem,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
    this.notes,
    required this.inputMethod,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, userId, date, foodItem, quantity, calories, 
    protein, carbs, fat, imageUrl, notes, inputMethod, createdAt
  ];

  factory NutritionEntry.fromMap(Map<String, dynamic> map) {
    return NutritionEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      foodItem: map['food_item'] as String,
      quantity: map['quantity'] as String,
      calories: map['calories'] as int,
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
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
      'food_item': foodItem,
      'quantity': quantity,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'image_url': imageUrl,
      'notes': notes,
      'input_method': inputMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NutritionEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? foodItem,
    String? quantity,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? imageUrl,
    String? notes,
    String? inputMethod,
    DateTime? createdAt,
  }) {
    return NutritionEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      inputMethod: inputMethod ?? this.inputMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
