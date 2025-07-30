
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<AuthState> _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthSessionRefreshed>(_onAuthSessionRefreshed);
    on<AuthSignedOut>(_onAuthSignedOut);

    _authStateSubscription = _authRepository.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        add(AuthSessionRefreshed());
      } else if (authState.event == AuthChangeEvent.signedOut) {
        add(AuthSignedOut());
      }
    });
  }

  Future<void> _onAuthSessionRefreshed(
    AuthSessionRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    final session = _authRepository.currentSession;
    if (session != null) {
      emit(AuthAuthenticated(session));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignedOut(
    AuthSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
