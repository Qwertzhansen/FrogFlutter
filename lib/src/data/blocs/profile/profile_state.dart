
part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoadInProgress extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final Profile profile;

  const ProfileLoadSuccess(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileLoadFailure extends ProfileState {
  final String error;

  const ProfileLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
