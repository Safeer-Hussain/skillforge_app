import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cohort_cubit.dart';
import '../cubit/cohort_state.dart';
import '../../../data/models/cohort_and_mentor_models.dart';
import '../../widgets/code_syntax_view.dart';
import '../../../core/utils/app_feedback.dart';

class CohortView extends StatefulWidget {
  const CohortView({super.key});

  @override
  State<CohortView> createState() => _CohortViewState();
}

class _CohortViewState extends State<CohortView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final cubit = context.read<CohortCubit>();
    if (cubit.state.studyRooms.isEmpty) {
      cubit.loadCohortData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        toolbarHeight: isLandscape ? 36 : 48,
        title: Text(
          'Cohort Rooms & Peer Reviews',
          style: TextStyle(
            fontSize: isLandscape ? 13 : 16,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Study Rooms'),
            Tab(text: 'Code Reviews'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_cohort_host_room', // Explicit unique heroTag
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.group_add, size: 18),
        label: const Text(
          'Host Study Room',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showHostRoomSheet(context),
      ),
      body: BlocConsumer<CohortCubit, CohortState>(
        listener: (context, state) {
          if (state.status == CohortStatus.error &&
              state.errorMessage != null) {
            AppFeedback.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == CohortStatus.loading) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildStudyRoomsTab(context, state, isLandscape),
              _buildCodeReviewsTab(context, state, isLandscape),
              _buildLeaderboardTab(context, state, isLandscape),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudyRoomsTab(
    BuildContext context,
    CohortState state,
    bool isLandscape,
  ) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 12 : 16,
        vertical: isLandscape ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Pomodoro Card (if joined)
          if (state.isPomodoroRunning && state.activePomodoroRoom != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: cs.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deep Work Sprint: ${state.activePomodoroRoom!.title}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Remaining: ${_formatTimer(state.pomodoroRemainingSeconds)}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                    onPressed: () {
                      context.read<CohortCubit>().stopPomodoro();
                      AppFeedback.showInfo(
                        context,
                        'Exited active deep-work focus sprint.',
                      );
                    },
                    child: Text(
                      'Leave',
                      style: TextStyle(color: cs.error, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          Text(
            'ACTIVE DEEP-WORK STUDY ROOMS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          ...state.studyRooms.map((room) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: room.userJoined ? cs.primary : cs.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          room.topic,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.people_alt_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${room.participantsCount} Engineers',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Host: ${room.hostName} | ${room.pomodoroMinutes}m Focus Blocks',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: room.userJoined
                              ? cs.secondary
                              : cs.primary,
                          foregroundColor: room.userJoined
                              ? cs.onSecondary
                              : cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        icon: Icon(
                          room.userJoined ? Icons.check : Icons.login,
                          size: 16,
                        ),
                        label: Text(
                          room.userJoined
                              ? 'Joined (Focusing)'
                              : 'Join Focus Room',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          context.read<CohortCubit>().toggleJoinRoom(room);
                          AppFeedback.showSuccess(
                            context,
                            room.userJoined
                                ? 'Left study room "${room.title}"'
                                : 'Joined "${room.title}" with Pomodoro timer (+20 XP)',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 70), // Room for FAB
        ],
      ),
    );
  }

  Widget _buildCodeReviewsTab(
    BuildContext context,
    CohortState state,
    bool isLandscape,
  ) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 12 : 16,
        vertical: isLandscape ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PEER ARCHITECTURE & CODE REVIEWS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: cs.onSurfaceVariant,
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.edit_note, size: 16, color: cs.primary),
                label: Text(
                  'Post RFC / Question',
                  style: TextStyle(fontSize: 11.5, color: cs.primary),
                ),
                onPressed: () => _showPostReviewSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...state.codeReviews.map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: cs.surfaceContainerHighest,
                        child: Text(
                          review.authorName.isNotEmpty
                              ? review.authorName[0]
                              : 'U',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.authorName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              '${review.authorRole} • ${review.createdAt}',
                              style: TextStyle(
                                fontSize: 10,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          review.tags,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    review.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface,
                      height: 1.4,
                    ),
                  ),
                  if (review.codeSnippet.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    CodeSyntaxView(code: review.codeSnippet, fontSize: 11),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          review.isUpvoted
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color: review.isUpvoted
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                        onPressed: () {
                          context.read<CohortCubit>().toggleUpvoteReview(
                            review,
                          );
                          AppFeedback.showSuccess(
                            context,
                            review.isUpvoted
                                ? 'Upvote removed'
                                : 'Upvoted review (+10 XP)',
                          );
                        },
                      ),
                      Text(
                        '${review.upvotesCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: review.isUpvoted ? cs.primary : cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          Icons.mode_comment_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () => _showCommentsSheet(context, review),
                      ),
                      Text(
                        '${review.commentsCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          Icons.share_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: 'SkillForge RFC: ${review.title}',
                            ),
                          );
                          AppFeedback.showInfo(
                            context,
                            'Copied RFC link to clipboard.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(
    BuildContext context,
    CohortState state,
    bool isLandscape,
  ) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 12 : 16,
        vertical: isLandscape ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'WEEKLY ARCHITECTURAL XP LEADERBOARD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          ...state.leaderboard.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: entry.isCurrentUser
                    ? cs.primaryContainer.withValues(alpha: 0.25)
                    : cs.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: entry.isCurrentUser ? cs.primary : cs.outlineVariant,
                  width: entry.isCurrentUser ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: entry.rank <= 3
                          ? cs.secondaryContainer
                          : cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.rank}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: entry.rank <= 3 ? cs.secondary : cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: entry.isCurrentUser
                                ? cs.primary
                                : cs.onSurface,
                          ),
                        ),
                        Text(
                          '${entry.title} • ${entry.streakDays} Day Streak',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.xp} XP',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      Text(
                        'Rank #${entry.rank}',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  void _showHostRoomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleController = TextEditingController();
    final topicController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int durationMinutes = 25;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              color: cs.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Host Deep-Work Study Room',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: titleController,
                          style: TextStyle(fontSize: 13, color: cs.onSurface),
                          decoration: const InputDecoration(
                            labelText: 'Study Room Title (e.g., Silent Sprint: Memory Leak Profiling)',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a room title.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: topicController,
                          style: TextStyle(fontSize: 13, color: cs.onSurface),
                          decoration: const InputDecoration(
                            labelText: 'Topic / Track Tag (e.g., Engine Internals, Raft Consensus)',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a topic tag.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Sprint Duration:',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface,
                              ),
                            ),
                            const Spacer(),
                            ChoiceChip(
                              label: const Text(
                                '25m',
                                style: TextStyle(fontSize: 11),
                              ),
                              selected: durationMinutes == 25,
                              onSelected: (_) =>
                                  setSheetState(() => durationMinutes = 25),
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text(
                                '50m',
                                style: TextStyle(fontSize: 11),
                              ),
                              selected: durationMinutes == 50,
                              onSelected: (_) =>
                                  setSheetState(() => durationMinutes = 50),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Launch Focus Room',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final ok = await context
                                  .read<CohortCubit>()
                                  .hostNewRoom(
                                    title: titleController.text,
                                    topic: topicController.text,
                                    pomodoroMinutes: durationMinutes,
                                  );
                              if (ok && sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                                AppFeedback.showSuccess(
                                  context,
                                  'Launched and joined study room (+50 XP).',
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPostReviewSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final snippetController = TextEditingController();
    final tagsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          color: cs.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Post Architecture Review / RFC',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: titleController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Title / RFC Proposal',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a title.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText:
                            'Dilemma or Architectural Trade-off Description',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: snippetController,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: cs.onSurface,
                      ),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Optional Code Snippet',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: tagsController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Tags (e.g., Concurrency, BLoC, Impeller)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Publish to Peer Cohort Feed',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final ok = await context
                              .read<CohortCubit>()
                              .postArchitectureQuestion(
                                title: titleController.text,
                                description: descController.text,
                                codeSnippet: snippetController.text,
                                tags: tagsController.text,
                              );
                          if (ok && sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                            AppFeedback.showSuccess(
                              context,
                              'RFC posted to cohort peer review feed (+40 XP).',
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCommentsSheet(BuildContext context, CodeReviewModel review) {
    final cs = Theme.of(context).colorScheme;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return FutureBuilder<List<ReviewCommentModel>>(
          future: context.read<CohortCubit>().loadComments(review.id),
          builder: (context, snapshot) {
            final comments = snapshot.data ?? [];

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Peer Review Feedback (${review.title})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      if (comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No peer comments yet. Be the first to review!',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ...comments.map((cm) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      cm.authorName,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: cs.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cm.createdAt,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cm.content,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: cs.onSurface,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Write technical critique or suggestion...',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.send_rounded, color: cs.primary),
                            onPressed: () async {
                              if (commentController.text.trim().isNotEmpty) {
                                await context.read<CohortCubit>().addComment(
                                  reviewId: review.id,
                                  content: commentController.text,
                                );
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                  AppFeedback.showSuccess(
                                    context,
                                    'Peer comment submitted (+15 XP).',
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
