
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Session session;

  const AuthAuthenticated(this.session);

  @override
  List<Object> get props => [session];
}

class AuthUnauthenticated extends AuthState {}
