import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frogg_flutter/src/auth/auth_repository.dart';
import 'package:frogg_flutter/src/auth/bloc/auth_bloc.dart';
import 'package:frogg_flutter/src/presentation/screens/auth_screen.dart';
import 'package:frogg_flutter/src/presentation/screens/home_screen.dart';
import 'package:frogg_flutter/src/data/repositories/profile_repository.dart';
import 'package:frogg_flutter/src/data/blocs/profile/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ugmgculhvzfzynpcxxdc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnbWdjdWxodnpmenlucGN4eGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2NTI1MDAsImV4cCI6MjA2OTIyODUwMH0.vnSLYvsZajqm7Qxem4BLmPeDoSySsKaFO6Q-sHiAR58',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: RepositoryProvider(
        create: (context) => ProfileRepository(),
        child: BlocProvider(
          create: (context) => AuthBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          )..add(AuthSessionRefreshed()),
          child: MaterialApp(
            title: 'FroggFlutter',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return BlocProvider(
                    create: (context) => ProfileBloc(
                      profileRepository: RepositoryProvider.of<ProfileRepository>(context),
                      userId: state.session.user.id!,
                    )..add(ProfileLoaded()),
                    child: const HomeScreen(),
                  );
                }
                return const AuthScreen();
              },
            ),
          ),
        ),
      ),
    );
  }
}