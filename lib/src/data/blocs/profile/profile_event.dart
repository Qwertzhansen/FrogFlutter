
part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoaded extends ProfileEvent {}

class ProfileUpdated extends ProfileEvent {
  final String username;
  final String avatarUrl;

  const ProfileUpdated({required this.username, required this.avatarUrl});

  @override
  List<Object> get props => [username, avatarUrl];
}
