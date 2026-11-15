import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/curriculum_bloc.dart';
import '../bloc/curriculum_event.dart';
import '../bloc/curriculum_state.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/lesson_model.dart';
import '../../widgets/code_syntax_view.dart';
import '../../../core/utils/app_feedback.dart';

class LessonStudioView extends StatefulWidget {
  final TrackModel track;
  final Function(String challengeId)? onLaunchSandbox;

  const LessonStudioView({
    super.key,
    required this.track,
    this.onLaunchSandbox,
  });

  @override
  State<LessonStudioView> createState() => _LessonStudioViewState();
}

class _LessonStudioViewState extends State<LessonStudioView> {
  LessonModel? _selectedLesson;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CurriculumBloc>();
    bloc.add(SelectTrackEvent(widget.track));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocBuilder<CurriculumBloc, CurriculumState>(
      builder: (context, state) {
        final currentTrack = state.selectedTrack ?? widget.track;
        final lessons = state.currentLessons;
        final activeLesson =
            _selectedLesson ?? (lessons.isNotEmpty ? lessons.first : null);

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Text(
              currentTrack.title,
              style: TextStyle(
                fontSize: isLandscape ? 12.5 : 15,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Share Progress Credential',
                icon: Icon(
                  Icons.share_outlined,
                  size: isLandscape ? 18 : 20,
                  color: cs.primary,
                ),
                onPressed: () =>
                    _showShareProgressSheet(context, currentTrack, lessons),
              ),
            ],
          ),
          body: isLandscape
              ? Row(
                  children: [
                    // Left Pane: Module Accordion
                    SizedBox(
                      width: 320,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: cs.outlineVariant),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: _buildAccordion(
                            context,
                            currentTrack,
                            lessons,
                            activeLesson,
                          ),
                        ),
                      ),
                    ),
                    // Right Pane: Lesson Reader
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: activeLesson != null
                            ? _buildLessonReader(
                                context,
                                currentTrack,
                                activeLesson,
                              )
                            : Center(
                                child: Text(
                                  'No lesson selected',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTrackProgressHeader(context, currentTrack),
                      const SizedBox(height: 16),
                      Text(
                        'COURSE SYLLABUS & MODULES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAccordion(
                        context,
                        currentTrack,
                        lessons,
                        activeLesson,
                      ),
                      const SizedBox(height: 20),
                      if (activeLesson != null) ...[
                        Text(
                          'ACTIVE LESSON STUDIO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLessonReader(context, currentTrack, activeLesson),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTrackProgressHeader(BuildContext context, TrackModel track) {
    final cs = Theme.of(context).colorScheme;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Track Completion Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${(track.progressPercent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: track.progressPercent,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                '${track.completedLessonsCount}/${track.lessonsCount} Lessons Completed',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              Icon(Icons.bolt, size: 14, color: cs.secondary),
              const SizedBox(width: 4),
              Text(
                '+${track.totalXp} XP Available',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccordion(
    BuildContext context,
    TrackModel track,
    List<LessonModel> lessons,
    LessonModel? activeLesson,
  ) {
    final cs = Theme.of(context).colorScheme;

    // Group by moduleTitle
    final Map<String, List<LessonModel>> grouped = {};
    for (final l in lessons) {
      grouped.putIfAbsent(l.moduleTitle, () => []).add(l);
    }

    if (grouped.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: Text(
            'No lessons seeded for this track',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: grouped.entries.map((entry) {
        final moduleTitle = entry.key;
        final moduleLessons = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              title: Text(
                moduleTitle,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                '${moduleLessons.where((l) => l.isCompleted).length}/${moduleLessons.length} Completed',
                style: TextStyle(fontSize: 10.5, color: cs.onSurfaceVariant),
              ),
              children: moduleLessons.map((lesson) {
                final isSelected = activeLesson?.id == lesson.id;
                return Container(
                  color: isSelected
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                      : null,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    leading: Checkbox(
                      value: lesson.isCompleted,
                      activeColor: cs.primary,
                      onChanged: (_) {
                        context.read<CurriculumBloc>().add(
                          ToggleCompleteLessonEvent(
                            track: track,
                            lesson: lesson,
                          ),
                        );
                        AppFeedback.showSuccess(
                          context,
                          lesson.isCompleted
                              ? 'Marked "${lesson.title}" for review'
                              : 'Completed "${lesson.title}" (+${lesson.xpReward} XP)',
                        );
                      },
                    ),
                    title: Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: cs.onSurface,
                        decoration: lesson.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: Text(
                      '${lesson.durationMinutes}m',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLesson = lesson;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLessonReader(
    BuildContext context,
    TrackModel track,
    LessonModel lesson,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Time: ${lesson.timeComplexity}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Space: ${lesson.spaceComplexity}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '+${lesson.xpReward} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.contentNotes,
            style: TextStyle(fontSize: 13, height: 1.5, color: cs.onSurface),
          ),
          const SizedBox(height: 16),
          Text(
            'EXECUTABLE ARCHITECTURE PATTERN',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          CodeSyntaxView(code: lesson.codeSnippet),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text(
                    'Launch in Code Sandbox',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (widget.onLaunchSandbox != null) {
                      widget.onLaunchSandbox!(lesson.relatedChallengeId);
                    } else {
                      AppFeedback.showInfo(
                        context,
                        'Switched to Code Sandbox for ${lesson.title}',
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: lesson.isCompleted ? cs.primary : cs.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                icon: Icon(
                  lesson.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: lesson.isCompleted ? cs.primary : cs.onSurfaceVariant,
                  size: 18,
                ),
                label: Text(
                  lesson.isCompleted ? 'Completed' : 'Mark Done',
                  style: TextStyle(
                    fontSize: 12,
                    color: lesson.isCompleted ? cs.primary : cs.onSurface,
                  ),
                ),
                onPressed: () {
                  context.read<CurriculumBloc>().add(
                    ToggleCompleteLessonEvent(track: track, lesson: lesson),
                  );
                  AppFeedback.showSuccess(
                    context,
                    lesson.isCompleted
                        ? 'Marked lesson for review'
                        : 'Lesson completed! (+${lesson.xpReward} XP)',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareProgressSheet(
    BuildContext context,
    TrackModel track,
    List<LessonModel> lessons,
  ) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: cs.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Verified Track Progress Credential',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Candidate: Safeer Hussain\n'
                      'Track: ${track.title}\n'
                      'Domain: ${track.domain} (${track.difficulty})\n'
                      'Progress: ${(track.progressPercent * 100).toInt()}% completed (${track.completedLessonsCount}/${track.lessonsCount} lessons)\n'
                      'Verified Hash: SKILLFORGE-TRK-${track.id.toUpperCase()}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Progress Summary to Clipboard'),
                    onPressed: () {
                      final summary =
                          'SkillForge Verified Progress: ${track.title} (${(track.progressPercent * 100).toInt()}% Complete)';
                      Clipboard.setData(ClipboardData(text: summary));
                      Navigator.of(bottomSheetContext).pop();
                      AppFeedback.showSuccess(
                        context,
                        'Copied progress summary to clipboard.',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export JSON Skill Transcript'),
                    onPressed: () {
                      final transcript = jsonEncode({
                        'trackId': track.id,
                        'trackTitle': track.title,
                        'progress': track.progressPercent,
                        'completedLessons': track.completedLessonsCount,
                        'totalLessons': track.lessonsCount,
                        'xp': track.totalXp,
                        'timestamp': DateTime.now().toIso8601String(),
                      });
                      Clipboard.setData(ClipboardData(text: transcript));
                      Navigator.of(bottomSheetContext).pop();
                      AppFeedback.showSuccess(
                        context,
                        'JSON skill transcript copied to clipboard.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
