import 'package:equatable/equatable.dart';
import 'nutrition_entry.dart';

class MealPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final String dietType; // keto, vegan, paleo, mediterranean, etc.
  final Map<String, double> dailyTargets; // calories, protein, carbs, fat
  final List<MealPlanDay> days;
  final String difficulty;
  final double rating;
  final int followersCount;
  final String createdBy;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.dietType,
    required this.dailyTargets,
    required this.days,
    required this.difficulty,
    this.rating = 0.0,
    this.followersCount = 0,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id, name, description, durationDays, dietType,
    dailyTargets, days, difficulty, rating,
    followersCount, createdBy, createdAt
  ];

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      durationDays: map['duration_days'] as int,
      dietType: map['diet_type'] as String,
      dailyTargets: Map<String, double>.from(map['daily_targets']),
      days: (map['days'] as List)
          .map((day) => MealPlanDay.fromMap(day))
          .toList(),
      difficulty: map['difficulty'] as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      followersCount: map['followers_count'] as int? ?? 0,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration_days': durationDays,
      'diet_type': dietType,
      'daily_targets': dailyTargets,
      'days': days.map((day) => day.toMap()).toList(),
      'difficulty': difficulty,
      'rating': rating,
      'followers_count': followersCount,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MealPlanDay extends Equatable {
  final int dayNumber;
  final List<PlannedMeal> meals;
  final String? notes;

  const MealPlanDay({
    required this.dayNumber,
    required this.meals,
    this.notes,
  });

  @override
  List<Object?> get props => [dayNumber, meals, notes];

  factory MealPlanDay.fromMap(Map<String, dynamic> map) {
    return MealPlanDay(
      dayNumber: map['day_number'] as int,
      meals: (map['meals'] as List)
          .map((meal) => PlannedMeal.fromMap(meal))
          .toList(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_number': dayNumber,
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'notes': notes,
    };
  }
}

class PlannedMeal extends Equatable {
  final String id;
  final String mealType; // breakfast, lunch, dinner, snack
  final String name;
  final List<RecipeIngredient> ingredients;
  final String? recipeId;
  final String? instructions;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final Map<String, double> nutrition; // calories, protein, carbs, fat
  final String? imageUrl;

  const PlannedMeal({
    required this.id,
    required this.mealType,
    required this.name,
    required this.ingredients,
    this.recipeId,
    this.instructions,
    this.prepTime = 0,
    this.cookTime = 0,
    required this.nutrition,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id, mealType, name, ingredients, recipeId,
    instructions, prepTime, cookTime, nutrition, imageUrl
  ];

  factory PlannedMeal.fromMap(Map<String, dynamic> map) {
    return PlannedMeal(
      id: map['id'] as String,
      mealType: map['meal_type'] as String,
      name: map['name'] as String,
      ingredients: (map['ingredients'] as List)
          .map((ingredient) => RecipeIngredient.fromMap(ingredient))
          .toList(),
      recipeId: map['recipe_id'] as String?,
      instructions: map['instructions'] as String?,
      prepTime: map['prep_time'] as int? ?? 0,
      cookTime: map['cook_time'] as int? ?? 0,
      nutrition: Map<String, double>.from(map['nutrition']),
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal_type': mealType,
      'name': name,
      'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'recipe_id': recipeId,
      'instructions': instructions,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'nutrition': nutrition,
      'image_url': imageUrl,
    };
  }
}

class Recipe extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final List<String> tags;
  final Map<String, double> nutritionPerServing;
  final String? imageUrl;
  final String? videoUrl;
  final double rating;
  final int reviewCount;
  final String createdBy;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.tags,
    required this.nutritionPerServing,
    this.imageUrl,
    this.videoUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, name, description, ingredients, instructions,
    prepTime, cookTime, servings, difficulty, tags,
    nutritionPerServing, imageUrl, videoUrl, rating,
    reviewCount, createdBy, createdAt
  ];

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      ingredients: (map['ingredients'] as List)
          .map((ingredient) => RecipeIngredient.fromMap(ingredient))
          .toList(),
      instructions: List<String>.from(map['instructions']),
      prepTime: map['prep_time'] as int,
      cookTime: map['cook_time'] as int,
      servings: map['servings'] as int,
      difficulty: map['difficulty'] as String,
      tags: List<String>.from(map['tags']),
      nutritionPerServing: Map<String, double>.from(map['nutrition_per_serving']),
      imageUrl: map['image_url'] as String?,
      videoUrl: map['video_url'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] as int? ?? 0,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'instructions': instructions,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'tags': tags,
      'nutrition_per_serving': nutritionPerServing,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'rating': rating,
      'review_count': reviewCount,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class RecipeIngredient extends Equatable {
  final String name;
  final double amount;
  final String unit;
  final String? notes;

  const RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.notes,
  });

  @override
  List<Object?> get props => [name, amount, unit, notes];

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'notes': notes,
    };
  }
}

class ShoppingList extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<ShoppingItem> items;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, userId, name, items, isCompleted, createdAt, completedAt];

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      items: (map['items'] as List)
          .map((item) => ShoppingItem.fromMap(item))
          .toList(),
      isCompleted: map['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class ShoppingItem extends Equatable {
  final String name;
  final double amount;
  final String unit;
  final bool isChecked;
  final String? category;
  final String? notes;

  const ShoppingItem({
    required this.name,
    required this.amount,
    required this.unit,
    this.isChecked = false,
    this.category,
    this.notes,
  });

  @override
  List<Object?> get props => [name, amount, unit, isChecked, category, notes];

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
      isChecked: map['is_checked'] as bool? ?? false,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'is_checked': isChecked,
      'category': category,
      'notes': notes,
    };
  }
}