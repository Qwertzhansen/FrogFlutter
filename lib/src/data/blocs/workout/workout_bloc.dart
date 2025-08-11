import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/workout_entry.dart';
import '../../repositories/workout_repository.dart';

// Events
abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class WorkoutEntriesLoaded extends WorkoutEvent {
  final DateTime? date;
  
  const WorkoutEntriesLoaded({this.date});
  
  @override
  List<Object?> get props => [date];
}

class WorkoutEntryAddedFromText extends WorkoutEvent {
  final String description;
  
  const WorkoutEntryAddedFromText(this.description);
  
  @override
  List<Object> get props => [description];
}

class WorkoutEntryAddedFromVoice extends WorkoutEvent {
  final String voiceDescription;
  
  const WorkoutEntryAddedFromVoice(this.voiceDescription);
  
  @override
  List<Object> get props => [voiceDescription];
}

class WorkoutEntryDeleted extends WorkoutEvent {
  final String entryId;
  
  const WorkoutEntryDeleted(this.entryId);
  
  @override
  List<Object> get props => [entryId];
}

class WorkoutEntryUpdated extends WorkoutEvent {
  final WorkoutEntry entry;
  
  const WorkoutEntryUpdated(this.entry);
  
  @override
  List<Object> get props => [entry];
}

// States
abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoadSuccess extends WorkoutState {
  final List<WorkoutEntry> entries;
  final Map<String, dynamic>? dailySummary;
  
  const WorkoutLoadSuccess({
    required this.entries,
    this.dailySummary,
  });
  
  @override
  List<Object?> get props => [entries, dailySummary];
}

class WorkoutLoadFailure extends WorkoutState {
  final String error;
  
  const WorkoutLoadFailure(this.error);
  
  @override
  List<Object> get props => [error];
}

class WorkoutEntryAdding extends WorkoutState {}

class WorkoutEntryAddSuccess extends WorkoutState {
  final WorkoutEntry entry;
  
  const WorkoutEntryAddSuccess(this.entry);
  
  @override
  List<Object> get props => [entry];
}

class WorkoutEntryAddFailure extends WorkoutState {
  final String error;
  
  const WorkoutEntryAddFailure(this.error);
  
  @override
  List<Object> get props => [error];
}

// Bloc
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository _workoutRepository;
  final String userId;

  WorkoutBloc({
    required WorkoutRepository workoutRepository,
    required this.userId,
  })  : _workoutRepository = workoutRepository,
        super(WorkoutInitial()) {
    on<WorkoutEntriesLoaded>(_onWorkoutEntriesLoaded);
    on<WorkoutEntryAddedFromText>(_onWorkoutEntryAddedFromText);
    on<WorkoutEntryAddedFromVoice>(_onWorkoutEntryAddedFromVoice);
    on<WorkoutEntryDeleted>(_onWorkoutEntryDeleted);
    on<WorkoutEntryUpdated>(_onWorkoutEntryUpdated);
  }

  Future<void> _onWorkoutEntriesLoaded(
    WorkoutEntriesLoaded event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final entries = await _workoutRepository.getWorkoutEntries(
        userId,
        date: event.date,
      );
      
      Map<String, dynamic>? summary;
      if (event.date != null) {
        summary = await _workoutRepository.getDailyWorkoutSummary(
          userId,
          event.date!,
        );
      }
      
      emit(WorkoutLoadSuccess(entries: entries, dailySummary: summary));
    } catch (e) {
      emit(WorkoutLoadFailure(e.toString()));
    }
  }

  Future<void> _onWorkoutEntryAddedFromText(
    WorkoutEntryAddedFromText event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutEntryAdding());
    try {
      final entry = await _workoutRepository.addWorkoutEntryFromText(
        userId,
        event.description,
      );
      emit(WorkoutEntryAddSuccess(entry));
      // Reload entries
      add(const WorkoutEntriesLoaded());
    } catch (e) {
      emit(WorkoutEntryAddFailure(e.toString()));
    }
  }

  Future<void> _onWorkoutEntryAddedFromVoice(
    WorkoutEntryAddedFromVoice event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutEntryAdding());
    try {
      final entry = await _workoutRepository.addWorkoutEntryFromVoice(
        userId,
        event.voiceDescription,
      );
      emit(WorkoutEntryAddSuccess(entry));
      // Reload entries
      add(const WorkoutEntriesLoaded());
    } catch (e) {
      emit(WorkoutEntryAddFailure(e.toString()));
    }
  }

  Future<void> _onWorkoutEntryDeleted(
    WorkoutEntryDeleted event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.deleteWorkoutEntry(event.entryId);
      // Reload entries
      add(const WorkoutEntriesLoaded());
    } catch (e) {
      emit(WorkoutLoadFailure(e.toString()));
    }
  }

  Future<void> _onWorkoutEntryUpdated(
    WorkoutEntryUpdated event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.updateWorkoutEntry(event.entry);
      // Reload entries
      add(const WorkoutEntriesLoaded());
    } catch (e) {
      emit(WorkoutLoadFailure(e.toString()));
    }
  }
}