import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_config.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? ''; // may be empty in mock mode
  
  // Alternative: Use local LLM or other AI services
  // static const String _baseUrl = 'http://localhost:11434/api'; // For Ollama
  
  Future<String> processNaturalLanguageInput(String input, String context) async {
    // If no API key is configured, return deterministic mock responses
    if (_apiKey.isEmpty) {
      return _mockResponse(input, context);
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an AI Personal Trainer assistant. Your job is to:
1. Parse natural language input about workouts and nutrition
2. Extract structured data from user descriptions
3. Provide fitness advice and motivation
4. Return responses in JSON format when extracting data

Context: $context

For workout entries, extract: exercise name, duration (minutes), intensity, calories burned (estimate)
For nutrition entries, extract: food item, quantity, calories (estimate), macros if possible
For general questions, provide helpful fitness advice.'''
            },
            {
              'role': 'user',
              'content': input,
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to process AI request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  String _mockResponse(String input, String context) {
    switch (context) {
      case 'personalized_advice':
        return 'Stay consistent this week: aim for 3 workouts and prioritize protein with each meal. Hydrate well and get 7-8 hours of sleep.';
      case 'workout_planning':
        return 'Weekly plan: Mon (Full Body 40m), Wed (HIIT 25m), Fri (Upper Body 35m), Sat (Light Cardio 20m). Rest Tue/Thu.';
      case 'nutrition_advice':
        return 'Target balanced meals: ~30g protein, complex carbs, veggies, and healthy fats. Keep snacks high-protein.';
      case 'progress_analysis':
        return 'Calories are trending steady; workouts increasing in duration. Great momentum—consider adding progressive overload.';
      case 'fitness_qa':
        return 'A mix of strength (3x/week) and cardio (2x/week) supports fat loss while maintaining muscle. Keep protein adequate.';
      case 'motivation':
        return 'You\'re building a great habit. Small consistent steps beat big inconsistent efforts. You\'ve got this!';
      default:
        return 'AI mock response: keep going!';
    }
  }

  Future<Map<String, dynamic>> analyzeWorkoutDescription(String description) async {
    final prompt = '''
Parse this workout description and return a JSON object with the following structure:
{
  "exercise": "exercise name",
  "duration": duration_in_minutes,
  "intensity": "low/medium/high",
  "calories_burned": estimated_calories,
  "notes": "additional notes"
}

Description: "$description"
''';

    try {
      final response = await processNaturalLanguageInput(prompt, 'workout_parsing');
      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
      
      // Fallback parsing if JSON extraction fails
      return _fallbackWorkoutParsing(description);
    } catch (e) {
      return _fallbackWorkoutParsing(description);
    }
  }

  Future<Map<String, dynamic>> analyzeNutritionDescription(String description) async {
    final prompt = '''
Parse this nutrition description and return a JSON object with the following structure:
{
  "food_item": "food name",
  "quantity": "amount with unit",
  "calories": estimated_calories,
  "protein": protein_grams,
  "carbs": carbs_grams,
  "fat": fat_grams,
  "notes": "additional notes"
}

Description: "$description"
''';

    try {
      final response = await processNaturalLanguageInput(prompt, 'nutrition_parsing');
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
      
      return _fallbackNutritionParsing(description);
    } catch (e) {
      return _fallbackNutritionParsing(description);
    }
  }

  Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    // In mock mode, return a fixed recognized meal
    if (_apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'food_item': 'Chicken Salad',
        'quantity': '1 bowl',
        'calories': 420,
        'protein': 35,
        'carbs': 18,
        'fat': 20,
        'confidence': 0.9,
        'notes': 'Mocked image analysis',
      };
    }
    // This would typically use a vision API like OpenAI's GPT-4 Vision or Google Vision API
    // For now, we'll simulate the response
    
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      // Process image for nutrition analysis
      base64Encode(bytes);
      
      // TODO: Implement actual image analysis
      // For now, return a mock response
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      return {
        'food_item': 'Detected food item',
        'quantity': '1 serving',
        'calories': 250,
        'protein': 15,
        'carbs': 30,
        'fat': 8,
        'confidence': 0.85,
        'notes': 'Image analysis result'
      };
    } catch (e) {
      throw Exception('Image analysis failed: $e');
    }
  }

  Future<String> getPersonalizedAdvice(String userGoal, List<Map<String, dynamic>> recentActivities) async {
    final prompt = '''
Based on the user's goal: "$userGoal"
And their recent activities: ${jsonEncode(recentActivities)}

Provide personalized fitness and nutrition advice. Be motivational and specific.
''';

    try {
      return await processNaturalLanguageInput(prompt, 'personalized_advice');
    } catch (e) {
      return 'Keep up the great work! Stay consistent with your fitness journey.';
    }
  }

  Map<String, dynamic> _fallbackWorkoutParsing(String description) {
    // If no API key, this doubles as the primary parsing

    // Simple keyword-based parsing as fallback
    final lowerDesc = description.toLowerCase();
    
    String exercise = 'General Exercise';
    int duration = 30;
    String intensity = 'medium';
    int calories = 200;
    
    // Extract exercise type
    if (lowerDesc.contains('run') || lowerDesc.contains('jog')) {
      exercise = 'Running';
      calories = 300;
    } else if (lowerDesc.contains('walk')) {
      exercise = 'Walking';
      calories = 150;
    } else if (lowerDesc.contains('bike') || lowerDesc.contains('cycle')) {
      exercise = 'Cycling';
      calories = 250;
    } else if (lowerDesc.contains('swim')) {
      exercise = 'Swimming';
      calories = 400;
    } else if (lowerDesc.contains('weight') || lowerDesc.contains('lift')) {
      exercise = 'Weight Training';
      calories = 200;
    }
    
    // Extract duration
    final durationMatch = RegExp(r'(\d+)\s*(min|minute|hour)').firstMatch(lowerDesc);
    if (durationMatch != null) {
      duration = int.parse(durationMatch.group(1)!);
      if (durationMatch.group(2)!.contains('hour')) {
        duration *= 60;
      }
    }
    
    return {
      'exercise': exercise,
      'duration': duration,
      'intensity': intensity,
      'calories_burned': calories,
      'notes': description,
    };
  }

  Map<String, dynamic> _fallbackNutritionParsing(String description) {
    // Simple keyword-based parsing as fallback
    final lowerDesc = description.toLowerCase();
    
    String foodItem = 'Food Item';
    String quantity = '1 serving';
    int calories = 200;
    
    // Basic food recognition
    if (lowerDesc.contains('apple')) {
      foodItem = 'Apple';
      calories = 80;
    } else if (lowerDesc.contains('banana')) {
      foodItem = 'Banana';
      calories = 100;
    } else if (lowerDesc.contains('chicken')) {
      foodItem = 'Chicken';
      calories = 250;
    } else if (lowerDesc.contains('rice')) {
      foodItem = 'Rice';
      calories = 200;
    } else if (lowerDesc.contains('salad')) {
      foodItem = 'Salad';
      calories = 100;
    }
    
    return {
      'food_item': foodItem,
      'quantity': quantity,
      'calories': calories,
      'protein': 10,
      'carbs': 25,
      'fat': 5,
      'notes': description,
    };
  }
}