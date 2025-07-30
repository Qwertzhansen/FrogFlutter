
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frogg_flutter/src/data/models/profile.dart';
import 'package:frogg_flutter/src/data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final String userId;

  ProfileBloc({required ProfileRepository profileRepository, required this.userId})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<ProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadInProgress());
    try {
      final profile = await _profileRepository.fetchProfile(userId);
      if (profile != null) {
        emit(ProfileLoadSuccess(profile));
      } else {
        emit(const ProfileLoadFailure('Profile not found'));
      }
    } catch (e) {
      emit(ProfileLoadFailure(e.toString()));
    }
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _profileRepository.updateProfile(
        userId: userId,
        username: event.username,
        avatarUrl: event.avatarUrl,
      );
      add(ProfileLoaded()); // Reload profile after update
    } catch (e) {
      emit(ProfileLoadFailure(e.toString()));
    }
  }
}
