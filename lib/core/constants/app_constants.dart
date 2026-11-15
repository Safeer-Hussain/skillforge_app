class AppConstants {
  static const String appName = 'SkillForge';
  static const String appVersion = '1.0.0+1';
  static const String buildNumber = '1';

  // Platform Channels
  static const String sandboxMethodChannel =
      'com.safeer.skillforge/sandbox_runtime';
  static const String telemetryEventChannel =
      'com.safeer.skillforge/focus_telemetry';

  // Storage Keys
  static const String themeKey = 'skillforge_theme_mode';
  static const String simulatedLatencyKey = 'skillforge_simulated_latency';
  static const String forceHttp503Key = 'skillforge_force_http_503';
  static const String userXpKey = 'skillforge_user_xp';
  static const String userStreakKey = 'skillforge_user_streak';

  // Socratic System Prompts
  static const String socraticPersona =
      'You are the SkillForge Socratic Engineering Mentor. You evaluate code efficiency, concurrency, and architecture by asking probing, first-principles questions rather than giving immediate answers.';
}
