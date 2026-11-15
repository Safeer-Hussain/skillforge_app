import 'package:flutter/material.dart';

import '../curriculum/views/curriculum_catalog_view.dart';
import '../sandbox/views/code_sandbox_view.dart';
import '../flashcards/views/flashcard_deck_view.dart';
import '../cohort/views/cohort_view.dart';
import '../ai_mentor/views/ai_socratic_mentor_view.dart';
import '../analytics/views/mastery_analytics_view.dart';
import '../widgets/offline_banner.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;
  String? _pendingChallengeId;

  void _onLaunchSandbox(String challengeId) {
    setState(() {
      _pendingChallengeId = challengeId;
      _currentIndex = 1; // Switch to Code Sandbox tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school),
        label: 'Tracks',
      ),
      NavigationDestination(
        icon: Icon(Icons.terminal_outlined),
        selectedIcon: Icon(Icons.terminal),
        label: 'Sandbox',
      ),
      NavigationDestination(
        icon: Icon(Icons.style_outlined),
        selectedIcon: Icon(Icons.style),
        label: 'Flashcards',
      ),
      NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        selectedIcon: Icon(Icons.groups),
        label: 'Cohort',
      ),
      NavigationDestination(
        icon: Icon(Icons.psychology_outlined),
        selectedIcon: Icon(Icons.psychology),
        label: 'AI Mentor',
      ),
      NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: 'Analytics',
      ),
    ];

    final railDestinations = const [
      NavigationRailDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school),
        label: Text('Tracks'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.terminal_outlined),
        selectedIcon: Icon(Icons.terminal),
        label: Text('Sandbox'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.style_outlined),
        selectedIcon: Icon(Icons.style),
        label: Text('Flashcards'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.groups_outlined),
        selectedIcon: Icon(Icons.groups),
        label: Text('Cohort'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.psychology_outlined),
        selectedIcon: Icon(Icons.psychology),
        label: Text('AI Mentor'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: Text('Analytics'),
      ),
    ];

    final pages = [
      CurriculumCatalogView(onLaunchSandbox: _onLaunchSandbox),
      CodeSandboxView(
        key: ValueKey(_pendingChallengeId ?? 'sandbox_default'),
        initialChallengeId: _pendingChallengeId,
      ),
      const FlashcardDeckView(),
      const CohortView(),
      const AiSocraticMentorView(),
      const MasteryAnalyticsView(),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: isLandscape
                  ? Row(
                      children: [
                        // Landscape 360dp viewport safe NavigationRail
                        SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              minWidth: 56,
                              labelType: NavigationRailLabelType.none,
                              backgroundColor: cs.surface,
                              selectedIndex: _currentIndex,
                              onDestinationSelected: (idx) {
                                setState(() {
                                  _currentIndex = idx;
                                });
                              },
                              destinations: railDestinations,
                            ),
                          ),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(
                          child: IndexedStack(
                            index: _currentIndex,
                            children: pages,
                          ),
                        ),
                      ],
                    )
                  : IndexedStack(index: _currentIndex, children: pages),
            ),
          ],
        ),
        bottomNavigationBar: isLandscape
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                backgroundColor: cs.surface,
                elevation: 3,
                height: 64,
                onDestinationSelected: (idx) {
                  setState(() {
                    _currentIndex = idx;
                  });
                },
                destinations: destinations,
              ),
      ),
    );
  }
}
