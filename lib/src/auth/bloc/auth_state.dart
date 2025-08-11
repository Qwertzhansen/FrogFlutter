
part of 'auth_bloc.dart';

abstract class AppAuthState extends Equatable {
  const AppAuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AppAuthState {}

class AuthAuthenticated extends AppAuthState {
  final supabase.Session session;

  const AuthAuthenticated(this.session);

  @override
  List<Object> get props => [session];
}

class AuthUnauthenticated extends AppAuthState {}
