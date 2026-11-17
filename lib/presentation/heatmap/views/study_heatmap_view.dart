import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../data/models/daily_activity_model.dart';
import '../cubit/study_heatmap_cubit.dart';
import '../cubit/study_heatmap_state.dart';

class StudyHeatmapView extends StatefulWidget {
  const StudyHeatmapView({super.key});

  @override
  State<StudyHeatmapView> createState() => _StudyHeatmapViewState();
}

class _StudyHeatmapViewState extends State<StudyHeatmapView> {
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to the latest weeks (rightmost side) on initial layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gridScrollController.hasClients) {
        _gridScrollController.jumpTo(
          _gridScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<StudyHeatmapCubit, StudyHeatmapState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Text(
              'Study Activity Heatmap',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh Matrix',
                icon: Icon(
                  Icons.refresh,
                  size: isLandscape ? 18 : 20,
                  color: cs.onSurface,
                ),
                onPressed: () {
                  context.read<StudyHeatmapCubit>().loadActivityMatrix();
                  AppFeedback.showInfo(context, 'Activity matrix refreshed.');
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_heatmap_log_activity',
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            icon: const Icon(Icons.add_task_outlined),
            label: Text(
              'Log Session',
              style: TextStyle(
                fontSize: isLandscape ? 11 : 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _showLogActivityBottomSheet(context),
          ),
          body: state.isLoading
              ? Center(child: CircularProgressIndicator(color: cs.primary))
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 12 : 16,
                    vertical: isLandscape ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // KPI Metrics Row
                      _buildKpiMetricsRow(context, state, isLandscape),
                      const SizedBox(height: 14),

                      // Filter Chips
                      _buildFilterChips(context, state),
                      const SizedBox(height: 14),

                      // 52-Week GitHub Contribution Grid Container
                      _buildContributionGridCard(context, state, isLandscape),
                      const SizedBox(height: 14),

                      // Selected Day Detail Inspector
                      _buildDayDetailCard(context, state),
                      const SizedBox(height: 14),

                      // Activity Breakdown Distribution
                      _buildActivityBreakdownCard(context, state),
                      const SizedBox(height: 80), // Padding for FAB
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildKpiMetricsRow(
    BuildContext context,
    StudyHeatmapState state,
    bool isLandscape,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            context,
            title: 'Current Streak',
            value: '${state.currentStreak} Days',
            subtitle: 'Consecutive study',
            icon: Icons.local_fire_department_outlined,
            iconColor: cs.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            context,
            title: 'Longest Streak',
            value: '${state.longestStreak} Days',
            subtitle: 'Annual peak record',
            icon: Icons.emoji_events_outlined,
            iconColor: cs.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            context,
            title: 'Contributions',
            value: '${state.totalContributions}',
            subtitle: '52-week actions',
            icon: Icons.commit_outlined,
            iconColor: cs.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            context,
            title: 'Active Days',
            value: '${state.activeDaysCount}',
            subtitle:
                '${(state.activeDaysRatio * 100).toStringAsFixed(1)}% of year',
            icon: Icons.calendar_month_outlined,
            iconColor: cs.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, StudyHeatmapState state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<StudyHeatmapCubit>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: ActivityFilter.values.map((filter) {
          final isSelected = state.filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => cubit.setFilter(filter),
              selectedColor: cs.primaryContainer,
              backgroundColor: cs.surfaceContainer,
              side: BorderSide(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContributionGridCard(
    BuildContext context,
    StudyHeatmapState state,
    bool isLandscape,
  ) {
    final cs = Theme.of(context).colorScheme;

    // Group the 364 days into 52 columns of 7 days
    final weeks = <List<DailyActivityModel>>[];
    for (int i = 0; i < state.activities.length; i += 7) {
      final end = (i + 7 <= state.activities.length)
          ? i + 7
          : state.activities.length;
      weeks.add(state.activities.sublist(i, end));
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '52-WEEK ACTIVITY CONTRIBUTION MATRIX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '${state.totalContributions} Contributions',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable 52-Week Grid
          SingleChildScrollView(
            controller: _gridScrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day of Week Labels Column
                _buildDayLabelsColumn(context),
                const SizedBox(width: 6),

                // Columns for each week (52 weeks)
                Row(
                  children: weeks.map((week) {
                    return _buildWeekColumn(context, week, state);
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              ...List.generate(5, (index) {
                return Container(
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _getColorForIntensity(cs, index),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text(
                'More',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabelsColumn(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const dayLabels = ['Mon', '', 'Wed', '', 'Fri', '', 'Sun'];

    return Column(
      children: dayLabels.map((label) {
        return Container(
          height: 14,
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekColumn(
    BuildContext context,
    List<DailyActivityModel> week,
    StudyHeatmapState state,
  ) {
    final cubit = context.read<StudyHeatmapCubit>();
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: week.map((day) {
        final intensity = state.getFilteredIntensity(day);
        final isSelected = state.selectedDay?.dateKey == day.dateKey;
        final count = state.getFilteredCount(day);

        return GestureDetector(
          onTap: () => cubit.selectDay(day),
          child: Tooltip(
            message:
                '${day.dateKey}: $count ${state.filter.label.toLowerCase()}',
            child: Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical: 1.5,
              ),
              decoration: BoxDecoration(
                color: _getColorForIntensity(cs, intensity),
                borderRadius: BorderRadius.circular(2.5),
                border: Border.all(
                  color: isSelected
                      ? cs.onSurface
                      : cs.outlineVariant.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForIntensity(ColorScheme cs, int intensity) {
    switch (intensity) {
      case 0:
        return cs.surfaceContainerHighest.withValues(alpha: 0.35);
      case 1:
        return cs.primary.withValues(alpha: 0.30);
      case 2:
        return cs.primary.withValues(alpha: 0.58);
      case 3:
        return cs.primary.withValues(alpha: 0.82);
      case 4:
      default:
        return cs.primary;
    }
  }

  Widget _buildDayDetailCard(BuildContext context, StudyHeatmapState state) {
    final cs = Theme.of(context).colorScheme;
    final day = state.selectedDay;

    if (day == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: Text(
            'Tap any day cell in the matrix to inspect activity telemetry.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final intensity = state.getFilteredIntensity(day);
    final intensityLabel = _getIntensityLabel(intensity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDisplayDate(day.date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getColorForIntensity(
                    cs,
                    intensity,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getColorForIntensity(cs, intensity),
                  ),
                ),
                child: Text(
                  intensityLabel,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailBadge(
                  context,
                  title: 'Lessons',
                  count: '${day.completedLessons}',
                  icon: Icons.menu_book_outlined,
                  iconColor: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailBadge(
                  context,
                  title: 'AST Sandbox',
                  count: '${day.sandboxExecutions}',
                  icon: Icons.terminal_outlined,
                  iconColor: cs.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailBadge(
                  context,
                  title: 'Flashcards',
                  count: '${day.flashcardsReviewed}',
                  icon: Icons.psychology_outlined,
                  iconColor: cs.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailBadge(
                  context,
                  title: 'XP Earned',
                  count: '+${day.xpEarned}',
                  icon: Icons.bolt_outlined,
                  iconColor: cs.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdownCard(
    BuildContext context,
    StudyHeatmapState state,
  ) {
    final cs = Theme.of(context).colorScheme;
    final total = state.totalContributions > 0 ? state.totalContributions : 1;

    final lessonRatio = state.totalLessons / total;
    final sandboxRatio = state.totalSandboxRuns / total;
    final flashcardRatio = state.totalFlashcards / total;

    return Container(
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
            '52-WEEK DOMAIN CONTRIBUTION BREAKDOWN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _buildBreakdownProgressBar(
            context,
            title: 'Curriculum Lessons Completed',
            count: state.totalLessons,
            ratio: lessonRatio,
            color: cs.primary,
          ),
          const SizedBox(height: 10),
          _buildBreakdownProgressBar(
            context,
            title: 'Native AST & Sandbox Executions',
            count: state.totalSandboxRuns,
            ratio: sandboxRatio,
            color: cs.secondary,
          ),
          const SizedBox(height: 10),
          _buildBreakdownProgressBar(
            context,
            title: 'SM-2 Spaced-Repetition Reviews',
            count: state.totalFlashcards,
            ratio: flashcardRatio,
            color: cs.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownProgressBar(
    BuildContext context, {
    required String title,
    required int count,
    required double ratio,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: cs.onSurface)),
            Text(
              '$count actions (${(ratio * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  String _getIntensityLabel(int intensity) {
    switch (intensity) {
      case 0:
        return 'No Activity';
      case 1:
        return 'Level 1: Moderate Practice';
      case 2:
        return 'Level 2: Consistent Effort';
      case 3:
        return 'Level 3: High Velocity';
      case 4:
      default:
        return 'Level 4: Mastery Sprint';
    }
  }

  String _formatDisplayDate(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[d.weekday - 1];
    final month = months[d.month - 1];
    return '$weekday, $month ${d.day}, ${d.year}';
  }

  void _showLogActivityBottomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<StudyHeatmapCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _LogActivityForm(
          onSave: (type, count, xp) {
            cubit.logActivity(type: type, count: count, xp: xp);
            Navigator.of(sheetContext).pop();
            AppFeedback.showSuccess(
              context,
              'Successfully logged $count $type study sessions (+$xp XP)!',
            );
          },
        );
      },
    );
  }
}

class _LogActivityForm extends StatefulWidget {
  final void Function(String type, int count, int xp) onSave;

  const _LogActivityForm({required this.onSave});

  @override
  State<_LogActivityForm> createState() => _LogActivityFormState();
}

class _LogActivityFormState extends State<_LogActivityForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'lesson';
  final _countController = TextEditingController(text: '1');
  final _xpController = TextEditingController(text: '100');

  @override
  void dispose() {
    _countController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log Study Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Activity Category',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  dropdownColor: cs.surfaceContainerHighest,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'lesson',
                      child: Text('Curriculum Lesson Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'sandbox',
                      child: Text('Native Sandbox AST Code Execution'),
                    ),
                    DropdownMenuItem(
                      value: 'flashcard',
                      child: Text('SM-2 Spaced-Repetition Review'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedType = val;
                        if (val == 'lesson') {
                          _xpController.text = '100';
                        } else if (val == 'sandbox') {
                          _xpController.text = '60';
                        } else {
                          _xpController.text = '25';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Session Count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Session count is required';
                    }
                    final numVal = int.tryParse(val.trim());
                    if (numVal == null || numVal <= 0) {
                      return 'Enter a valid count greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'XP Reward Points',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _xpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'XP reward is required';
                    }
                    final numVal = int.tryParse(val.trim());
                    if (numVal == null || numVal < 0) {
                      return 'Enter a non-negative XP amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Commit Study Activity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final count = int.parse(_countController.text.trim());
                      final xp = int.parse(_xpController.text.trim());
                      widget.onSave(_selectedType, count, xp);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
