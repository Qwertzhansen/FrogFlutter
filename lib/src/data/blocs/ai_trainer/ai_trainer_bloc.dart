import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../services/ai_trainer_service.dart';

// Events
abstract class AITrainerEvent extends Equatable {
  const AITrainerEvent();

  @override
  List<Object?> get props => [];
}

class AIAdviceRequested extends AITrainerEvent {}

class AIWorkoutPlanRequested extends AITrainerEvent {
  final String preferences;
  
  const AIWorkoutPlanRequested(this.preferences);
  
  @override
  List<Object> get props => [preferences];
}

class AINutritionAdviceRequested extends AITrainerEvent {
  final String dietaryPreferences;
  
  const AINutritionAdviceRequested(this.dietaryPreferences);
  
  @override
  List<Object> get props => [dietaryPreferences];
}

class AIProgressAnalysisRequested extends AITrainerEvent {}

class AIQuestionAsked extends AITrainerEvent {
  final String question;
  
  const AIQuestionAsked(this.question);
  
  @override
  List<Object> get props => [question];
}

class AIMotivationRequested extends AITrainerEvent {}

// States
abstract class AITrainerState extends Equatable {
  const AITrainerState();

  @override
  List<Object?> get props => [];
}

class AITrainerInitial extends AITrainerState {}

class AITrainerLoading extends AITrainerState {}

class AIAdviceSuccess extends AITrainerState {
  final String advice;
  
  const AIAdviceSuccess(this.advice);
  
  @override
  List<Object> get props => [advice];
}

class AIWorkoutPlanSuccess extends AITrainerState {
  final String workoutPlan;
  
  const AIWorkoutPlanSuccess(this.workoutPlan);
  
  @override
  List<Object> get props => [workoutPlan];
}

class AINutritionAdviceSuccess extends AITrainerState {
  final String nutritionAdvice;
  
  const AINutritionAdviceSuccess(this.nutritionAdvice);
  
  @override
  List<Object> get props => [nutritionAdvice];
}

class AIProgressAnalysisSuccess extends AITrainerState {
  final Map<String, dynamic> analysis;
  
  const AIProgressAnalysisSuccess(this.analysis);
  
  @override
  List<Object> get props => [analysis];
}

class AIQuestionAnswered extends AITrainerState {
  final String question;
  final String answer;
  
  const AIQuestionAnswered(this.question, this.answer);
  
  @override
  List<Object> get props => [question, answer];
}

class AIMotivationSuccess extends AITrainerState {
  final List<String> messages;
  
  const AIMotivationSuccess(this.messages);
  
  @override
  List<Object> get props => [messages];
}

class AITrainerFailure extends AITrainerState {
  final String error;
  
  const AITrainerFailure(this.error);
  
  @override
  List<Object> get props => [error];
}

// Bloc
class AITrainerBloc extends Bloc<AITrainerEvent, AITrainerState> {
  final AITrainerService _aiTrainerService;
  final String userId;

  AITrainerBloc({
    required AITrainerService aiTrainerService,
    required this.userId,
  })  : _aiTrainerService = aiTrainerService,
        super(AITrainerInitial()) {
    on<AIAdviceRequested>(_onAIAdviceRequested);
    on<AIWorkoutPlanRequested>(_onAIWorkoutPlanRequested);
    on<AINutritionAdviceRequested>(_onAINutritionAdviceRequested);
    on<AIProgressAnalysisRequested>(_onAIProgressAnalysisRequested);
    on<AIQuestionAsked>(_onAIQuestionAsked);
    on<AIMotivationRequested>(_onAIMotivationRequested);
  }

  Future<void> _onAIAdviceRequested(
    AIAdviceRequested event,
    Emitter<AITrainerState> emit,
  ) async {
    emit(AITrainerLoading());
    try {
      final advice = await _aiTrainerService.getPersonalizedAdvice(userId);
      emit(AIAdviceSuccess(advice));
    } catch (e) {
      emit(AITrainerFailure(e.toString()));
    }
  }

  Future<void> _onAIWorkoutPlanRequested(
    AIWorkoutPlanRequested event,
    Emitter<AITrainerState> emit,
  ) async {
    emit(AITrainerLoading());
    try {
      final workoutPlan = await _aiTrainerService.generateWorkoutPlan(
        userId,
        event.preferences,
      );
      emit(AIWorkoutPlanSuccess(workoutPlan));
    } catch (e) {
      emit(AITrainerFailure(e.toString()));
    }
  }

  Future<void> _onAINutritionAdviceRequested(
    AINutritionAdviceRequested event,
    Emitter<AITrainerState> emit,
  ) async {
    emit(AITrainerLoading());
    try {
      final nutritionAdvice = await _aiTrainerService.generateNutritionAdvice(
        userId,
        event.dietaryPreferences,
      );
      emit(AINutritionAdviceSuccess(nutritionAdvice));
    } catch (e) {
      emit(AITrainerFailure(e.toString()));
    }
  }

  Future<void> _onAIProgressAnalysisRequested(
    AIProgressAnalysisRequested event,
    Emitter<AITrainerState> emit,
  ) async {
    emit(AITrainerLoading());
    try {
      final analysis = await _aiTrainerService.analyzeProgress(userId);
      emit(AIProgressAnalysisSuccess(analysis));
    } catch (e) {
      emit(AITrainerFailure(e.toString()));
    }
  }

  Future<void> _onAIQuestionAsked(
    AIQuestionAsked event,
    Emitter<AITrainerState> emit,
  ) async {
    emit(AITrainerLoading());
    try {
      final answer = await _aiTrainerService.answerFitnessQuestion(
        event.question,
        userId,
      );
      emit(AIQuestionAnswered(event.question, answer));
    } catch (e) {
      emit(AITrainerFailure(e.toString()));
    }
  }

  Future<void> _onAIMotivationRequested(
    AIMotivationRequested event,
    Emitter<AITrainerState> emit,
  ) async {
    emit(AITrainerLoading());
    try {
      final messages = await _aiTrainerService.generateMotivationalMessages(userId);
      emit(AIMotivationSuccess(messages));
    } catch (e) {
      emit(AITrainerFailure(e.toString()));
    }
  }
}