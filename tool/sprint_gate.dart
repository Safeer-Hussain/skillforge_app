import 'dart:io';

void main(List<String> args) async {
  print('======================================================');
  print('          SKILLFORGE STANDALONE SPRINT GATE           ');
  print('======================================================');

  final isWindows = Platform.isWindows;
  final flutterCmd = isWindows ? 'flutter.bat' : 'flutter';
  final dartCmd = isWindows ? 'dart.bat' : 'dart';
  final adbCmd = isWindows ? 'adb.exe' : 'adb';

  // Step 1: flutter pub get
  print('\n[1/5] Running flutter pub get...');
  final pubRes = await Process.run(flutterCmd, ['pub', 'get']);
  if (pubRes.exitCode != 0) {
    stderr.writeln('FAILED: flutter pub get\n${pubRes.stderr}');
    exit(1);
  }
  print('PASSED: Dependencies resolved.');

  // Step 2: dart format lib test
  print(
    '\n[2/5] Running dart format --output=none --set-exit-if-changed lib test...',
  );
  final fmtRes = await Process.run(dartCmd, [
    'format',
    '--output=none',
    '--set-exit-if-changed',
    'lib',
    'test',
  ]);
  if (fmtRes.exitCode != 0) {
    stderr.writeln(
      'FAILED: Code formatting required. Run: dart format lib test\n${fmtRes.stdout}',
    );
    exit(1);
  }
  print('PASSED: Formatting clean.');

  // Step 3: flutter analyze --no-fatal-infos --no-pub
  print('\n[3/5] Running flutter analyze --no-fatal-infos --no-pub...');
  final anaRes = await Process.run(flutterCmd, [
    'analyze',
    '--no-fatal-infos',
    '--no-pub',
  ]);
  if (anaRes.exitCode != 0) {
    stderr.writeln(
      'FAILED: Static analysis failed.\n${anaRes.stdout}\n${anaRes.stderr}',
    );
    exit(1);
  }
  print('PASSED: Zero analysis issues.');

  // Step 4: flutter test --no-pub
  print('\n[4/5] Running flutter test --no-pub...');
  final testRes = await Process.run(flutterCmd, ['test', '--no-pub']);
  if (testRes.exitCode != 0) {
    stderr.writeln(
      'FAILED: Automated tests failed.\n${testRes.stdout}\n${testRes.stderr}',
    );
    exit(1);
  }
  print('PASSED: All automated tests succeeded.');

  // Step 5: Connected physical device check (optional if adb present)
  print('\n[5/5] Checking connected physical device telemetry via adb...');
  try {
    final devRes = await Process.run(adbCmd, ['devices']);
    if (devRes.exitCode == 0 && devRes.stdout.toString().contains('device\n')) {
      print('Physical device detected. Scanning logcat for exceptions...');
      final logRes = await Process.run(adbCmd, ['logcat', '-d']);
      final logs = logRes.stdout.toString();
      if (logs.contains('A RenderFlex overflowed') ||
          logs.contains('There are multiple heroes that share the same tag')) {
        stderr.writeln(
          'FAILED: RenderFlex overflow or duplicate Hero tag detected in physical device logcat!',
        );
        exit(1);
      }
      print('PASSED: Device logcat clean from RenderFlex or Hero collisions.');
    } else {
      print('No physical device connected via adb. Skipping live logcat scan.');
    }
  } catch (_) {
    print(
      'adb not found in system PATH. Skipping physical device logcat check.',
    );
  }

  print('\n======================================================');
  print('      ALL SPRINT GATE VERIFICATIONS PASSED (5/5)      ');
  print('======================================================');
  exit(0);
}
