import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'presentation/curriculum/bloc/curriculum_bloc.dart';
import 'presentation/sandbox/bloc/sandbox_bloc.dart';
import 'presentation/flashcards/cubit/flashcard_sm2_cubit.dart';
import 'presentation/cohort/cubit/cohort_cubit.dart';
import 'presentation/ai_mentor/cubit/ai_socratic_mentor_cubit.dart';
import 'presentation/complexity/cubit/complexity_cubit.dart';
import 'presentation/heatmap/cubit/study_heatmap_cubit.dart';
import 'presentation/validator/cubit/regex_json_cubit.dart';
import 'presentation/splash/splash_view.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint(
          'SkillForge Framework Error: ${details.exceptionAsString()}',
        );
      };

      // Keep pre-runApp() minimal in defensive try/catch
      try {
        await initInjection();
      } catch (e, stack) {
        debugPrint('SkillForge pre-runApp injection error: $e\n$stack');
      }

      runApp(const SkillForgeApp());
    },
    (error, stack) {
      debugPrint('SkillForge Uncaught Zone Error: $error\n$stack');
    },
  );
}

class SkillForgeApp extends StatelessWidget {
  const SkillForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs: sl())),
        BlocProvider<CurriculumBloc>(
          create: (_) => CurriculumBloc(repository: sl()),
        ),
        BlocProvider<SandboxBloc>(create: (_) => SandboxBloc(repository: sl())),
        BlocProvider<FlashcardSm2Cubit>(
          create: (_) => FlashcardSm2Cubit(repository: sl()),
        ),
        BlocProvider<CohortCubit>(create: (_) => CohortCubit(repository: sl())),
        BlocProvider<AiSocraticMentorCubit>(
          create: (_) => AiSocraticMentorCubit(repository: sl()),
        ),
        BlocProvider<ComplexityCubit>(create: (_) => ComplexityCubit()),
        BlocProvider<StudyHeatmapCubit>(
          create: (_) => StudyHeatmapCubit(repository: sl()),
        ),
        BlocProvider<RegexJsonCubit>(
          create: (_) => RegexJsonCubit(repository: sl()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'SkillForge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            home: const SplashView(),
          );
        },
      ),
    );
  }
}
