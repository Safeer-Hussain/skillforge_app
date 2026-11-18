import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/platform/sandbox_platform_bridge.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/local_database.dart';
import 'data/datasources/preferences_service.dart';
import 'data/repositories/curriculum_repository.dart';
import 'data/repositories/sandbox_repository.dart';
import 'data/repositories/flashcard_repository.dart';
import 'data/repositories/cohort_repository.dart';
import 'data/repositories/mentor_repository.dart';
import 'data/repositories/study_activity_repository.dart';
import 'data/repositories/regex_json_repository.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Preferences Service
  sl.registerLazySingleton<PreferencesService>(
    () => PreferencesService(prefs: sl()),
  );

  // App Database (SQLite)
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Sandbox Platform Bridge
  sl.registerLazySingleton<SandboxPlatformBridge>(
    () => SandboxPlatformBridge(),
  );

  // Dio Client
  sl.registerLazySingleton<DioClient>(() => DioClient(prefs: sl()));

  // Repositories
  sl.registerLazySingleton<CurriculumRepository>(
    () => CurriculumRepository(database: sl(), preferencesService: sl()),
  );

  sl.registerLazySingleton<SandboxRepository>(
    () => SandboxRepository(
      database: sl(),
      preferencesService: sl(),
      platformBridge: sl(),
    ),
  );

  sl.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepository(database: sl(), preferencesService: sl()),
  );

  sl.registerLazySingleton<CohortRepository>(
    () => CohortRepository(database: sl(), preferencesService: sl()),
  );

  sl.registerLazySingleton<MentorRepository>(
    () => MentorRepository(database: sl(), preferencesService: sl()),
  );

  sl.registerLazySingleton<StudyActivityRepository>(
    () => StudyActivityRepository(database: sl(), preferencesService: sl()),
  );

  sl.registerLazySingleton<RegexJsonRepository>(
    () => RegexJsonRepository(database: sl()),
  );
}
