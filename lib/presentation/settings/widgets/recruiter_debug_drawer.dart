import 'package:flutter/material.dart';

import '../../../injection.dart';
import '../../../data/datasources/preferences_service.dart';
import '../../../core/utils/app_feedback.dart';

class RecruiterDebugDrawer extends StatefulWidget {
  final VoidCallback? onDataReset;
  const RecruiterDebugDrawer({super.key, this.onDataReset});

  @override
  State<RecruiterDebugDrawer> createState() => _RecruiterDebugDrawerState();
}

class _RecruiterDebugDrawerState extends State<RecruiterDebugDrawer> {
  final PreferencesService _prefs = sl<PreferencesService>();
  late bool _latencyEnabled;
  late bool _force503;

  @override
  void initState() {
    super.initState();
    _latencyEnabled = _prefs.simulatedLatencyEnabled;
    _force503 = _prefs.forceHttp503Enabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                border: Border(bottom: BorderSide(color: cs.outlineVariant)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    color: cs.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recruiter Debug Drawer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Telemetry & Network Resilience Controls',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  Text(
                    'NETWORK SIMULATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    tileColor: cs.surfaceContainer,
                    title: Text(
                      'Simulate Latency (400-850ms)',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Simulates mobile edge network jitter and packet overhead.',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    value: _latencyEnabled,
                    activeColor: cs.primary,
                    onChanged: (val) async {
                      await _prefs.setSimulatedLatencyEnabled(val);
                      setState(() => _latencyEnabled = val);
                      if (context.mounted) {
                        AppFeedback.showInfo(
                          context,
                          val
                              ? 'Simulated latency enabled (400-850ms)'
                              : 'Simulated latency disabled (instant)',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    tileColor: cs.surfaceContainer,
                    title: Text(
                      'Force HTTP 503 Service Unavailable',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Tests error boundary screens, offline fallbacks, and retry logic.',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    value: _force503,
                    activeColor: cs.error,
                    onChanged: (val) async {
                      await _prefs.setForceHttp503Enabled(val);
                      setState(() => _force503 = val);
                      if (context.mounted) {
                        if (val) {
                          AppFeedback.showWarning(
                            context,
                            'Forced HTTP 503 activated on all mock network requests.',
                          );
                        } else {
                          AppFeedback.showSuccess(
                            context,
                            'HTTP 503 override cleared.',
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DEVELOPER ACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    tileColor: cs.surfaceContainer,
                    leading: Icon(Icons.bolt, color: cs.secondary),
                    title: Text(
                      'Inject XP Boost (+250 XP)',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Simulate passing an architectural benchmark.',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    onTap: () async {
                      await _prefs.addXp(250);
                      if (context.mounted) {
                        AppFeedback.showSuccess(
                          context,
                          'Awarded +250 XP. New balance: ${_prefs.userXp} XP',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    tileColor: cs.surfaceContainer,
                    leading: Icon(Icons.group_add_outlined, color: cs.tertiary),
                    title: Text(
                      'Inject Cohort Peer Review Invite',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Simulate receiving a live pull request review request.',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      AppFeedback.showInfo(
                        context,
                        'Cohort Notification: Marcus Vance requested your review on "Non-blocking Ring Buffer RFC".',
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.close, color: cs.onSurfaceVariant, size: 18),
                label: Text(
                  'Close Drawer',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
