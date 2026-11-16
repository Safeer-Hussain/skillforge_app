import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_forge_app/core/theme/app_theme.dart';
import 'package:skill_forge_app/presentation/complexity/cubit/complexity_cubit.dart';
import 'package:skill_forge_app/presentation/complexity/views/complexity_visualizer_view.dart';

void main() {
  Widget createTestWidget({
    ThemeMode themeMode = ThemeMode.dark,
    required Widget child,
  }) {
    return BlocProvider<ComplexityCubit>(
      create: (_) => ComplexityCubit(),
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        home: child,
      ),
    );
  }

  group('ComplexityVisualizerView Widget Tests (Sprint 1)', () {
    testWidgets('Renders all primary visualizer elements in portrait', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const ComplexityVisualizerView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Big-O Complexity Visualizer'), findsOneWidget);
      expect(find.text('ASYMPTOTIC RUNTIME CURVE'), findsOneWidget);
      expect(find.text('ACTIVE COMPLEXITY CLASSES'), findsOneWidget);
      expect(find.text('CANONICAL PATTERN IMPLEMENTATION'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Toggles Space and Time complexity mode without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const ComplexityVisualizerView()),
      );
      await tester.pumpAndSettle();

      // Find Time Complexity button
      final toggleFinder = find.text('Time Complexity');
      expect(toggleFinder, findsOneWidget);

      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(find.text('Space Complexity'), findsOneWidget);
      expect(find.text('SPACE ALLOCATION CURVE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Zero RenderFlex overflow errors on an 800x360 landscape viewport',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          createTestWidget(child: const ComplexityVisualizerView()),
        );
        await tester.pumpAndSettle();

        // Verify two-pane layout rendered smoothly without overflow
        expect(find.byType(VerticalDivider), findsOneWidget);
        expect(tester.takeException(), isNull);

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      },
    );

    testWidgets('Unique heroTag on FloatingActionButton', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const ComplexityVisualizerView()),
      );
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.heroTag, 'fab_complexity_reset');
    });
  });
}
