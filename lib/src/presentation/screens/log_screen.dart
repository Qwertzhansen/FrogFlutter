
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/blocs/nutrition/nutrition_bloc.dart';
import '../../data/blocs/workout/workout_bloc.dart';
import '../../services/speech_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isListening = false;
  String _speechText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechService.initialize();
    } catch (e) {
      // Handle speech initialization failure silently
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Logging'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: 'Nutrition'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Workout'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNutritionTab(),
          _buildWorkoutTab(),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Log Your Food', 'Use AI to track nutrition effortlessly'),
          const SizedBox(height: 20),
          _buildInputMethods(isNutrition: true),
          const SizedBox(height: 20),
          _buildRecentEntries(isNutrition: true),
        ],
      ),
    );
  }

  Widget _buildWorkoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Log Your Workout', 'Track exercises with natural language'),
          const SizedBox(height: 20),
          _buildInputMethods(isNutrition: false),
          const SizedBox(height: 20),
          _buildRecentEntries(isNutrition: false),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInputMethods({required bool isNutrition}) {
    return Column(
      children: [
        _buildTextInput(isNutrition: isNutrition),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildVoiceInput(isNutrition: isNutrition)),
            if (isNutrition) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildImageInput()),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTextInput({required bool isNutrition}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Type Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: isNutrition 
                  ? 'e.g., "I had a chicken salad with olive oil dressing"'
                  : 'e.g., "I ran for 30 minutes at moderate pace"',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitTextEntry(isNutrition: isNutrition),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Entry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInput({required bool isNutrition}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        children: [
          Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.red : Colors.orange.shade700,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Voice Input',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          if (_speechText.isNotEmpty) ...[
            Text(
              _speechText,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: () => _toggleListening(isNutrition: isNutrition),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isListening ? Colors.red : Colors.orange.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_isListening ? 'Stop' : 'Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.camera_alt, color: Colors.green.shade700, size: 32),
          const SizedBox(height: 8),
          Text(
            'Photo Input',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _takePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries({required bool isNutrition}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (isNutrition)
          BlocBuilder<NutritionBloc, NutritionState>(
            builder: (context, state) {
              if (state is NutritionLoadSuccess) {
                return _buildNutritionList(state.entries.take(5).toList());
              } else if (state is NutritionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Text('No recent nutrition entries');
            },
          )
        else
          BlocBuilder<WorkoutBloc, WorkoutState>(
            builder: (context, state) {
              if (state is WorkoutLoadSuccess) {
                return _buildWorkoutList(state.entries.take(5).toList());
              } else if (state is WorkoutLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Text('No recent workout entries');
            },
          ),
      ],
    );
  }

  Widget _buildNutritionList(List entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.restaurant, color: Colors.green.shade700),
            ),
            title: Text(entry.foodItem),
            subtitle: Text('${entry.calories} cal • ${entry.quantity}'),
            trailing: Text(
              entry.inputMethod.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutList(List entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.fitness_center, color: Colors.purple.shade700),
            ),
            title: Text(entry.exercise),
            subtitle: Text('${entry.duration} min • ${entry.intensity} intensity'),
            trailing: Text(
              entry.inputMethod.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitTextEntry({required bool isNutrition}) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (isNutrition) {
      context.read<NutritionBloc>().add(NutritionEntryAddedFromText(text));
    } else {
      context.read<WorkoutBloc>().add(WorkoutEntryAddedFromText(text));
    }

    _textController.clear();
    _showSuccessSnackBar('Entry logged successfully!');
  }

  void _toggleListening({required bool isNutrition}) async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() {
        _isListening = false;
      });
      
      if (_speechText.isNotEmpty) {
        if (!mounted) return;
        if (isNutrition) {
          context.read<NutritionBloc>().add(NutritionEntryAddedFromVoice(_speechText));
        } else {
          context.read<WorkoutBloc>().add(WorkoutEntryAddedFromVoice(_speechText));
        }
        _showSuccessSnackBar('Voice entry logged successfully!');
      }
    } else {
      setState(() {
        _isListening = true;
        _speechText = '';
      });
      
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _speechText = text;
          });
        },
      );
    }
  }

  void _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        final file = File(image.path);
        if (!mounted) return;
        context.read<NutritionBloc>().add(NutritionEntryAddedFromImage(file));
        _showSuccessSnackBar('Photo uploaded! AI is analyzing...');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
