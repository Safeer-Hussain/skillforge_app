import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_forge_app/main.dart';
import 'package:skill_forge_app/injection.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'skillforge_theme_mode': 'dark'});
    if (!sl.isRegistered<SharedPreferences>()) {
      await initInjection();
    }
  });

  testWidgets(
    'SkillForgeApp initializes and renders SplashView without errors',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SkillForgeApp());
      expect(find.text('SkillForge'), findsOneWidget);
      expect(
        find.text('Enterprise Technical Mastery & Architecture Sandbox'),
        findsOneWidget,
      );

      // Settle all splash transition timers
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    },
  );
}
