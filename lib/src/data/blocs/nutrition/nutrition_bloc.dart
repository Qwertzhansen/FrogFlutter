import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/nutrition_entry.dart';
import '../../repositories/nutrition_repository.dart';

// Events
abstract class NutritionEvent extends Equatable {
  const NutritionEvent();

  @override
  List<Object?> get props => [];
}

class NutritionEntriesLoaded extends NutritionEvent {
  final DateTime? date;
  
  const NutritionEntriesLoaded({this.date});
  
  @override
  List<Object?> get props => [date];
}

class NutritionEntryAddedFromText extends NutritionEvent {
  final String description;
  
  const NutritionEntryAddedFromText(this.description);
  
  @override
  List<Object> get props => [description];
}

class NutritionEntryAddedFromVoice extends NutritionEvent {
  final String voiceDescription;
  
  const NutritionEntryAddedFromVoice(this.voiceDescription);
  
  @override
  List<Object> get props => [voiceDescription];
}

class NutritionEntryAddedFromImage extends NutritionEvent {
  final File imageFile;
  
  const NutritionEntryAddedFromImage(this.imageFile);
  
  @override
  List<Object> get props => [imageFile];
}

class NutritionEntryDeleted extends NutritionEvent {
  final String entryId;
  
  const NutritionEntryDeleted(this.entryId);
  
  @override
  List<Object> get props => [entryId];
}

class NutritionEntryUpdated extends NutritionEvent {
  final NutritionEntry entry;
  
  const NutritionEntryUpdated(this.entry);
  
  @override
  List<Object> get props => [entry];
}

// States
abstract class NutritionState extends Equatable {
  const NutritionState();

  @override
  List<Object?> get props => [];
}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class NutritionLoadSuccess extends NutritionState {
  final List<NutritionEntry> entries;
  final Map<String, dynamic>? dailySummary;
  
  const NutritionLoadSuccess({
    required this.entries,
    this.dailySummary,
  });
  
  @override
  List<Object?> get props => [entries, dailySummary];
}

class NutritionLoadFailure extends NutritionState {
  final String error;
  
  const NutritionLoadFailure(this.error);
  
  @override
  List<Object> get props => [error];
}

class NutritionEntryAdding extends NutritionState {}

class NutritionEntryAddSuccess extends NutritionState {
  final NutritionEntry entry;
  
  const NutritionEntryAddSuccess(this.entry);
  
  @override
  List<Object> get props => [entry];
}

class NutritionEntryAddFailure extends NutritionState {
  final String error;
  
  const NutritionEntryAddFailure(this.error);
  
  @override
  List<Object> get props => [error];
}

// Bloc
class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionRepository _nutritionRepository;
  final String userId;

  NutritionBloc({
    required NutritionRepository nutritionRepository,
    required this.userId,
  })  : _nutritionRepository = nutritionRepository,
        super(NutritionInitial()) {
    on<NutritionEntriesLoaded>(_onNutritionEntriesLoaded);
    on<NutritionEntryAddedFromText>(_onNutritionEntryAddedFromText);
    on<NutritionEntryAddedFromVoice>(_onNutritionEntryAddedFromVoice);
    on<NutritionEntryAddedFromImage>(_onNutritionEntryAddedFromImage);
    on<NutritionEntryDeleted>(_onNutritionEntryDeleted);
    on<NutritionEntryUpdated>(_onNutritionEntryUpdated);
  }

  Future<void> _onNutritionEntriesLoaded(
    NutritionEntriesLoaded event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionLoading());
    try {
      final entries = await _nutritionRepository.getNutritionEntries(
        userId,
        date: event.date,
      );
      
      Map<String, dynamic>? summary;
      if (event.date != null) {
        summary = await _nutritionRepository.getDailyNutritionSummary(
          userId,
          event.date!,
        );
      }
      
      emit(NutritionLoadSuccess(entries: entries, dailySummary: summary));
    } catch (e) {
      emit(NutritionLoadFailure(e.toString()));
    }
  }

  Future<void> _onNutritionEntryAddedFromText(
    NutritionEntryAddedFromText event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionEntryAdding());
    try {
      final entry = await _nutritionRepository.addNutritionEntryFromText(
        userId,
        event.description,
      );
      emit(NutritionEntryAddSuccess(entry));
      // Reload entries
      add(const NutritionEntriesLoaded());
    } catch (e) {
      emit(NutritionEntryAddFailure(e.toString()));
    }
  }

  Future<void> _onNutritionEntryAddedFromVoice(
    NutritionEntryAddedFromVoice event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionEntryAdding());
    try {
      final entry = await _nutritionRepository.addNutritionEntryFromVoice(
        userId,
        event.voiceDescription,
      );
      emit(NutritionEntryAddSuccess(entry));
      // Reload entries
      add(const NutritionEntriesLoaded());
    } catch (e) {
      emit(NutritionEntryAddFailure(e.toString()));
    }
  }

  Future<void> _onNutritionEntryAddedFromImage(
    NutritionEntryAddedFromImage event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionEntryAdding());
    try {
      final entry = await _nutritionRepository.addNutritionEntryFromImage(
        userId,
        event.imageFile,
      );
      emit(NutritionEntryAddSuccess(entry));
      // Reload entries
      add(const NutritionEntriesLoaded());
    } catch (e) {
      emit(NutritionEntryAddFailure(e.toString()));
    }
  }

  Future<void> _onNutritionEntryDeleted(
    NutritionEntryDeleted event,
    Emitter<NutritionState> emit,
  ) async {
    try {
      await _nutritionRepository.deleteNutritionEntry(event.entryId);
      // Reload entries
      add(const NutritionEntriesLoaded());
    } catch (e) {
      emit(NutritionLoadFailure(e.toString()));
    }
  }

  Future<void> _onNutritionEntryUpdated(
    NutritionEntryUpdated event,
    Emitter<NutritionState> emit,
  ) async {
    try {
      await _nutritionRepository.updateNutritionEntry(event.entry);
      // Reload entries
      add(const NutritionEntriesLoaded());
    } catch (e) {
      emit(NutritionLoadFailure(e.toString()));
    }
  }
}