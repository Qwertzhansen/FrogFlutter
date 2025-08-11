# AI Personal Trainer Setup Guide

## Overview
This Flutter app is an AI-powered personal trainer that allows users to track nutrition and workouts using natural language processing, voice input, and image recognition.

## Features
- 🤖 **AI-Powered Logging**: Use natural language to log workouts and nutrition
- 🎤 **Voice Input**: Speak your entries instead of typing
- 📸 **Image Recognition**: Take photos of food for automatic nutrition tracking
- 💬 **AI Chat**: Get personalized advice, workout plans, and motivation
- 📊 **Progress Tracking**: Comprehensive analytics and insights
- 🏋️ **Smart Recommendations**: AI-generated workout and nutrition plans

## Prerequisites
1. **Flutter SDK** (3.8.1 or higher)
2. **Dart SDK** (included with Flutter)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Supabase Account** (for backend services)
5. **OpenAI API Key** (for AI features)

## Setup Instructions

### 1. Clone and Install Dependencies
```bash
cd Desktop/frogg_flutter
flutter pub get
```

### 2. Supabase Setup
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Create the following tables in your Supabase database:

#### Profiles Table
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  username TEXT UNIQUE,
  avatar_url TEXT,
  fitness_goal TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (id)
);
```

#### Nutrition Entries Table
```sql
CREATE TABLE nutrition_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  food_item TEXT NOT NULL,
  quantity TEXT NOT NULL,
  calories INTEGER NOT NULL,
  protein DECIMAL NOT NULL DEFAULT 0,
  carbs DECIMAL NOT NULL DEFAULT 0,
  fat DECIMAL NOT NULL DEFAULT 0,
  image_url TEXT,
  notes TEXT,
  input_method TEXT NOT NULL CHECK (input_method IN ('text', 'voice', 'image')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

#### Workout Entries Table
```sql
CREATE TABLE workout_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  exercise TEXT NOT NULL,
  duration INTEGER NOT NULL,
  intensity TEXT NOT NULL CHECK (intensity IN ('low', 'medium', 'high')),
  calories_burned INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  input_method TEXT NOT NULL CHECK (input_method IN ('text', 'voice')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

#### Storage Bucket
Create a storage bucket named `nutrition-images` for food photos.

### 3. Environment Configuration
1. Update `lib/main.dart` with your Supabase credentials:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

2. Update `lib/src/services/ai_service.dart` with your OpenAI API key:
```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY';
```

### 4. Permissions Setup

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of food</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select food images</string>
```

### 5. Run the App
```bash
flutter run
```

## AI Service Configuration

### OpenAI Integration
The app uses OpenAI's GPT models for natural language processing. You can also configure it to use:
- **Local LLMs** (Ollama, LM Studio)
- **Other AI APIs** (Anthropic Claude, Google Gemini)

### Alternative AI Setup (Ollama - Local)
1. Install Ollama: [ollama.ai](https://ollama.ai)
2. Pull a model: `ollama pull llama2`
3. Update `ai_service.dart`:
```dart
static const String _baseUrl = 'http://localhost:11434/api';
// Remove API key requirement
```

## Features Guide

### 1. Natural Language Logging
- **Nutrition**: "I had a chicken salad with olive oil dressing"
- **Workouts**: "I ran for 30 minutes at moderate pace"

### 2. Voice Input
- Tap the microphone icon
- Speak your entry
- The AI will process and log it automatically

### 3. Image Recognition
- Take a photo of your food
- AI analyzes the image and estimates nutrition
- Review and confirm the details

### 4. AI Chat
- Ask questions about fitness and nutrition
- Get personalized workout plans
- Receive motivation and tips
- Analyze your progress

## Troubleshooting

### Common Issues
1. **Speech Recognition Not Working**
   - Check microphone permissions
   - Ensure device has speech recognition support

2. **Image Upload Fails**
   - Verify Supabase storage bucket configuration
   - Check camera permissions

3. **AI Responses Are Slow**
   - Consider using a local LLM for faster responses
   - Check internet connection

4. **Database Errors**
   - Verify Supabase table schemas
   - Check Row Level Security policies

### Performance Tips
- Use local AI models for faster responses
- Implement caching for frequent queries
- Optimize image compression before upload

## Development

### Project Structure
```
lib/
├── src/
│   ├── auth/                 # Authentication logic
│   ├── data/
│   │   ├── models/          # Data models
│   │   ├── repositories/    # Data access layer
│   │   └── blocs/          # State management
│   ├── presentation/
│   │   └── screens/        # UI screens
│   └── services/           # External services
└── main.dart              # App entry point
```

### Adding New Features
1. Create models in `data/models/`
2. Add repository in `data/repositories/`
3. Create BLoC in `data/blocs/`
4. Build UI in `presentation/screens/`

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License
This project is licensed under the MIT License.