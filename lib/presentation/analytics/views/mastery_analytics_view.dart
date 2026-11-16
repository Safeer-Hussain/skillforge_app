import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/theme_cubit.dart';
import '../../settings/widgets/recruiter_debug_drawer.dart';
import '../../complexity/views/complexity_visualizer_view.dart';
import '../../../injection.dart';
import '../../../data/datasources/preferences_service.dart';
import '../../../core/utils/app_feedback.dart';

class MasteryAnalyticsView extends StatelessWidget {
  const MasteryAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final prefs = sl<PreferencesService>();
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        toolbarHeight: isLandscape ? 36 : 48,
        title: Text(
          'Mastery Analytics & Telemetry',
          style: TextStyle(
            fontSize: isLandscape ? 13 : 16,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Big-O Complexity Visualizer',
            icon: Icon(
              Icons.show_chart,
              size: isLandscape ? 18 : 20,
              color: cs.primary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ComplexityVisualizerView(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Toggle Obsidian Dark / Crisp Light Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: isLandscape ? 18 : 20,
              color: cs.onSurface,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
              AppFeedback.showInfo(
                context,
                isDark
                    ? 'Switched to Crisp Academic Light Mode'
                    : 'Switched to Obsidian IDE Dark Mode',
              );
            },
          ),
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Recruiter Debug Drawer',
              icon: Icon(
                Icons.bug_report_outlined,
                size: isLandscape ? 18 : 20,
                color: cs.secondary,
              ),
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const RecruiterDebugDrawer(),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 12 : 16,
          vertical: isLandscape ? 8 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI Summary Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total XP',
                    value: '${prefs.userXp}',
                    subtitle: '+180 XP today',
                    icon: Icons.bolt,
                    iconColor: cs.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Study Streak',
                    value: '${prefs.streakDays} Days',
                    subtitle: 'Top 5% consistency',
                    icon: Icons.local_fire_department_outlined,
                    iconColor: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Retention',
                    value: '92.4%',
                    subtitle: 'SM-2 memory curve',
                    icon: Icons.psychology_outlined,
                    iconColor: cs.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Big-O Complexity Interactive Visualizer Banner
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ComplexityVisualizerView(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.show_chart,
                        size: 20,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Big-O Complexity Visualizer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            'Simulate O(1), O(log n), O(n), O(n log n), and O(2^n) curves against input size N',
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: cs.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 14-Day XP Velocity Chart (Full width, reservedSize: 0 on hidden axes)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '14-DAY XP VELOCITY & RETENTION CURVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Edge-to-Edge Vector',
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    width: double.infinity, // Full width requirement
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 50,
                          getDrawingHorizontalLine: (val) => FlLine(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 0,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 0,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 2,
                              getTitlesWidget: (val, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'D${val.toInt()}',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 100,
                              getTitlesWidget: (val, meta) {
                                return Text(
                                  '${val.toInt()}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: cs.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 1,
                        maxX: 14,
                        minY: 0,
                        maxY: 350,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(1, 40),
                              FlSpot(2, 65),
                              FlSpot(3, 90),
                              FlSpot(4, 120),
                              FlSpot(5, 110),
                              FlSpot(6, 175),
                              FlSpot(7, 210),
                              FlSpot(8, 190),
                              FlSpot(9, 230),
                              FlSpot(10, 260),
                              FlSpot(11, 240),
                              FlSpot(12, 290),
                              FlSpot(13, 310),
                              FlSpot(14, 340),
                            ],
                            isCurved: true,
                            color: cs.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: cs.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          LineChartBarData(
                            spots: const [
                              FlSpot(1, 80),
                              FlSpot(2, 82),
                              FlSpot(3, 85),
                              FlSpot(4, 88),
                              FlSpot(5, 87),
                              FlSpot(6, 91),
                              FlSpot(7, 93),
                              FlSpot(8, 92),
                              FlSpot(9, 94),
                              FlSpot(10, 95),
                              FlSpot(11, 93),
                              FlSpot(12, 96),
                              FlSpot(13, 97),
                              FlSpot(14, 98),
                            ],
                            isCurved: true,
                            color: cs.secondary,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Skill Breakdown Metrics
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARCHITECTURAL COMPETENCY MATRIX',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _skillProgressRow(
                    context,
                    'Flutter Engine & Impeller Shaders',
                    0.85,
                    cs.primary,
                  ),
                  const SizedBox(height: 10),
                  _skillProgressRow(
                    context,
                    'Dart Isolate Concurrency & Buffers',
                    0.72,
                    cs.tertiary,
                  ),
                  const SizedBox(height: 10),
                  _skillProgressRow(
                    context,
                    'Raft Consensus & Distributed Systems',
                    0.65,
                    cs.secondary,
                  ),
                  const SizedBox(height: 10),
                  _skillProgressRow(
                    context,
                    'Vector Indexing & Hybrid Search RAG',
                    0.80,
                    cs.primary,
                  ),
                  const SizedBox(height: 10),
                  _skillProgressRow(
                    context,
                    'System Design & Distributed Rate Limiting',
                    0.60,
                    cs.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recruiter Debug Drawer Long-press Trigger
            Center(
              child: GestureDetector(
                onLongPress: () {
                  Scaffold.of(context).openEndDrawer();
                  AppFeedback.showInfo(
                    context,
                    'Opened Recruiter Debug Drawer.',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'SkillForge v1.0.0+1 (Build 1)',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tip: Long-press version to open Recruiter Debug Drawer',
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillProgressRow(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 11.5, color: cs.onSurface)),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
