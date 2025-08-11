import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:frogg_flutter/src/auth/auth_repository.dart';
import 'package:frogg_flutter/src/auth/bloc/auth_bloc.dart';
import 'package:frogg_flutter/src/presentation/screens/auth_screen.dart';
import 'package:frogg_flutter/src/presentation/screens/home_screen.dart';
import 'package:frogg_flutter/src/data/repositories/profile_repository.dart';
import 'package:frogg_flutter/src/data/repositories/nutrition_repository.dart';
import 'package:frogg_flutter/src/data/repositories/workout_repository.dart';
import 'package:frogg_flutter/src/data/blocs/profile/profile_bloc.dart';
import 'package:frogg_flutter/src/data/blocs/nutrition/nutrition_bloc.dart';
import 'package:frogg_flutter/src/data/blocs/workout/workout_bloc.dart';
import 'package:frogg_flutter/src/data/blocs/ai_trainer/ai_trainer_bloc.dart';
import 'package:frogg_flutter/src/services/ai_trainer_service.dart';
import 'package:frogg_flutter/src/services/app_config.dart';
import 'package:frogg_flutter/src/services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Load app config
  await AppConfig.instance.load();

  // Initialize notifications and schedule simple defaults
  await NotificationsService.instance.init();
  await NotificationsService.instance.scheduleDailyReminder(
    id: 1001,
    time: const TimeOfDay(hour: 13, minute: 0),
    title: 'Log your lunch',
    body: 'Track your meal to keep your streak going! 💪',
  );
  await NotificationsService.instance.scheduleDailyReminder(
    id: 1002,
    time: const TimeOfDay(hour: 20, minute: 0),
    title: 'Plan tomorrow',
    body: 'Prepare your workout and meals for tomorrow.',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
        RepositoryProvider(create: (context) => NutritionRepository()),
        RepositoryProvider(create: (context) => WorkoutRepository()),
        RepositoryProvider(create: (context) => AITrainerService()),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        )..add(AuthSessionRefreshed()),
        child: MaterialApp(
          title: 'AI Personal Trainer',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
          home: BlocBuilder<AuthBloc, AppAuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => ProfileBloc(
                        profileRepository: RepositoryProvider.of<ProfileRepository>(context),
                        userId: state.session.user.id,
                      )..add(ProfileLoaded()),
                    ),
                    BlocProvider(
                      create: (context) => NutritionBloc(
                        nutritionRepository: RepositoryProvider.of<NutritionRepository>(context),
                        userId: state.session.user.id,
                      )..add(const NutritionEntriesLoaded()),
                    ),
                    BlocProvider(
                      create: (context) => WorkoutBloc(
                        workoutRepository: RepositoryProvider.of<WorkoutRepository>(context),
                        userId: state.session.user.id,
                      )..add(const WorkoutEntriesLoaded()),
                    ),
                    BlocProvider(
                      create: (context) => AITrainerBloc(
                        aiTrainerService: RepositoryProvider.of<AITrainerService>(context),
                        userId: state.session.user.id,
                      ),
                    ),
                  ],
                  child: const HomeScreen(),
                );
              }
              // MOCK LOGIN: Skip authentication and go directly to home screen
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => ProfileBloc(
                      profileRepository: RepositoryProvider.of<ProfileRepository>(context),
                      userId: 'mock-user-id', // Mock user ID
                    )..add(ProfileLoaded()),
                  ),
                  BlocProvider(
                    create: (context) => NutritionBloc(
                      nutritionRepository: RepositoryProvider.of<NutritionRepository>(context),
                      userId: 'mock-user-id', // Mock user ID
                    )..add(const NutritionEntriesLoaded()),
                  ),
                  BlocProvider(
                    create: (context) => WorkoutBloc(
                      workoutRepository: RepositoryProvider.of<WorkoutRepository>(context),
                      userId: 'mock-user-id', // Mock user ID
                    )..add(const WorkoutEntriesLoaded()),
                  ),
                  BlocProvider(
                    create: (context) => AITrainerBloc(
                      aiTrainerService: RepositoryProvider.of<AITrainerService>(context),
                      userId: 'mock-user-id', // Mock user ID
                    ),
                  ),
                ],
                child: const HomeScreen(),
              );
              // Uncomment the line below to show the auth screen instead
              // return const AuthScreen();
            },
          ),
        ),
      ),
    );
  }
}