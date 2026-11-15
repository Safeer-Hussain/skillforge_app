import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/curriculum_bloc.dart';
import '../bloc/curriculum_event.dart';
import '../bloc/curriculum_state.dart';
import '../../../data/models/track_model.dart';
import 'lesson_studio_view.dart';
import '../../../core/utils/app_feedback.dart';

class CurriculumCatalogView extends StatefulWidget {
  final Function(String challengeId)? onLaunchSandbox;

  const CurriculumCatalogView({super.key, this.onLaunchSandbox});

  @override
  State<CurriculumCatalogView> createState() => _CurriculumCatalogViewState();
}

class _CurriculumCatalogViewState extends State<CurriculumCatalogView> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _domains = [
    'All Domains',
    'Mobile Architecture',
    'Clean Architecture',
    'Distributed Systems',
    'AI Engineering',
    'System Design',
  ];

  final List<String> _difficulties = [
    'All Levels',
    'Associate',
    'Senior',
    'Staff/Principal',
  ];

  final List<String> _enrollmentFilters = ['All', 'Enrolled', 'Bookmarked'];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CurriculumBloc>();
    if (bloc.state.allTracks.isEmpty) {
      bloc.add(const LoadCurriculumEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<CurriculumBloc, CurriculumState>(
      listener: (context, state) {
        if (state.status == CurriculumStatus.error &&
            state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Text(
              'Engineering Career Tracks',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: cs.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${state.totalUserXp} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search & Filter Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 12 : 16,
                  vertical: isLandscape ? 4 : 8,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText:
                            'Search 18+ tracks, protocols, or internals...',
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: cs.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<CurriculumBloc>().add(
                                    const FilterCurriculumEvent(
                                      searchQuery: '',
                                    ),
                                  );
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        context.read<CurriculumBloc>().add(
                          FilterCurriculumEvent(searchQuery: val),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._enrollmentFilters.map((e) {
                            final isSel = state.selectedEnrollmentStatus == e;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                selected: isSel,
                                label: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSel ? cs.onPrimary : cs.onSurface,
                                  ),
                                ),
                                selectedColor: cs.primary,
                                backgroundColor: cs.surfaceContainer,
                                side: BorderSide(
                                  color: isSel ? cs.primary : cs.outlineVariant,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (_) {
                                  context.read<CurriculumBloc>().add(
                                    FilterCurriculumEvent(enrollmentStatus: e),
                                  );
                                },
                              ),
                            );
                          }),
                          const VerticalDivider(
                            width: 12,
                            indent: 4,
                            endIndent: 4,
                          ),
                          ..._domains.map((d) {
                            final isSel = state.selectedDomain == d;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                selected: isSel,
                                label: Text(
                                  d,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSel ? cs.onPrimary : cs.onSurface,
                                  ),
                                ),
                                selectedColor: cs.primary,
                                backgroundColor: cs.surfaceContainer,
                                side: BorderSide(
                                  color: isSel ? cs.primary : cs.outlineVariant,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (_) {
                                  context.read<CurriculumBloc>().add(
                                    FilterCurriculumEvent(domain: d),
                                  );
                                },
                              ),
                            );
                          }),
                          const VerticalDivider(
                            width: 12,
                            indent: 4,
                            endIndent: 4,
                          ),
                          ..._difficulties.map((diff) {
                            final isSel = state.selectedDifficulty == diff;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                selected: isSel,
                                label: Text(
                                  diff,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSel ? cs.onPrimary : cs.onSurface,
                                  ),
                                ),
                                selectedColor: cs.secondary,
                                backgroundColor: cs.surfaceContainer,
                                side: BorderSide(
                                  color: isSel
                                      ? cs.secondary
                                      : cs.outlineVariant,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (_) {
                                  context.read<CurriculumBloc>().add(
                                    FilterCurriculumEvent(difficulty: diff),
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tracks List or Grid
              Expanded(
                child: state.status == CurriculumStatus.loading
                    ? Center(
                        child: CircularProgressIndicator(color: cs.primary),
                      )
                    : state.filteredTracks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 40,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No engineering tracks match active criteria',
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : isLandscape
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent:
                                  145, // Explicit mainAxisExtent rule
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: state.filteredTracks.length,
                        itemBuilder: (context, index) {
                          final track = state.filteredTracks[index];
                          return _buildTrackCard(
                            context,
                            track,
                            isCompact: true,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.filteredTracks.length,
                        itemBuilder: (context, index) {
                          final track = state.filteredTracks[index];
                          return _buildTrackCard(
                            context,
                            track,
                            isCompact: false,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackCard(
    BuildContext context,
    TrackModel track, {
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: isCompact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      color: cs.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<CurriculumBloc>().add(SelectTrackEvent(track));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LessonStudioView(
                track: track,
                onLaunchSandbox: widget.onLaunchSandbox,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isCompact
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      track.iconPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.code, size: 20, color: cs.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                track.domain,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                track.difficulty,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: cs.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    icon: Icon(
                      track.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: track.isBookmarked
                          ? cs.secondary
                          : cs.onSurfaceVariant,
                    ),
                    onPressed: () {
                      context.read<CurriculumBloc>().add(
                        ToggleBookmarkTrackEvent(track),
                      );
                      AppFeedback.showInfo(
                        context,
                        track.isBookmarked
                            ? 'Removed from bookmarked tracks'
                            : 'Saved to bookmarked tracks',
                      );
                    },
                  ),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 6),
                Text(
                  track.description,
                  style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${track.completedLessonsCount}/${track.lessonsCount} Lessons (${(track.progressPercent * 100).toInt()}%)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${track.totalXp} XP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: track.progressPercent,
                            minHeight: 4,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: const Size(60, 28),
                      side: BorderSide(
                        color: track.isEnrolled
                            ? cs.primary
                            : cs.outlineVariant,
                      ),
                      backgroundColor: track.isEnrolled
                          ? cs.primaryContainer.withValues(alpha: 0.2)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      track.isEnrolled ? 'Enrolled' : 'Enroll',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: track.isEnrolled ? cs.primary : cs.onSurface,
                      ),
                    ),
                    onPressed: () {
                      context.read<CurriculumBloc>().add(
                        ToggleEnrollTrackEvent(track),
                      );
                      AppFeedback.showSuccess(
                        context,
                        track.isEnrolled
                            ? 'Unenrolled from track'
                            : 'Enrolled in ${track.title}',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
