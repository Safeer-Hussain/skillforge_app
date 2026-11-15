import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences prefs;

  PreferencesService({required this.prefs});

  bool get simulatedLatencyEnabled =>
      prefs.getBool(AppConstants.simulatedLatencyKey) ?? true;

  Future<void> setSimulatedLatencyEnabled(bool value) async {
    await prefs.setBool(AppConstants.simulatedLatencyKey, value);
  }

  bool get forceHttp503Enabled =>
      prefs.getBool(AppConstants.forceHttp503Key) ?? false;

  Future<void> setForceHttp503Enabled(bool value) async {
    await prefs.setBool(AppConstants.forceHttp503Key, value);
  }

  int get userXp => prefs.getInt(AppConstants.userXpKey) ?? 1420;

  Future<void> addXp(int points) async {
    final current = userXp;
    await prefs.setInt(AppConstants.userXpKey, current + points);
  }

  int get streakDays => prefs.getInt(AppConstants.userStreakKey) ?? 14;

  Future<void> incrementStreak() async {
    final current = streakDays;
    await prefs.setInt(AppConstants.userStreakKey, current + 1);
  }
}
