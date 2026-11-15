import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/flashcard_sm2_cubit.dart';
import '../cubit/flashcard_sm2_state.dart';
import '../../../core/utils/sm2_algorithm.dart';
import '../../../data/models/flashcard_model.dart';
import '../../widgets/code_syntax_view.dart';
import 'certification_exam_view.dart';
import '../../../core/utils/app_feedback.dart';

class FlashcardDeckView extends StatefulWidget {
  const FlashcardDeckView({super.key});

  @override
  State<FlashcardDeckView> createState() => _FlashcardDeckViewState();
}

class _FlashcardDeckViewState extends State<FlashcardDeckView>
    with SingleTickerProviderStateMixin {
  late final TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    final cubit = context.read<FlashcardSm2Cubit>();
    if (cubit.state.deck.isEmpty) {
      cubit.loadDeck();
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
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
          'Mastery Spaced-Repetition Studio',
          style: TextStyle(
            fontSize: isLandscape ? 13 : 16,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          tabs: const [
            Tab(text: 'SM-2 Flashcards'),
            Tab(text: 'Mock Certification Exam'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_flashcard_create', // Explicit unique heroTag
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          'Create Flashcard',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showCreateCardSheet(context),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildDeckStudio(context, isLandscape),
          const CertificationExamView(),
        ],
      ),
    );
  }

  Widget _buildDeckStudio(BuildContext context, bool isLandscape) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<FlashcardSm2Cubit, FlashcardSm2State>(
      listener: (context, state) {
        if (state.status == FlashcardDeckStatus.error &&
            state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state.status == FlashcardDeckStatus.loading) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        }

        if (state.deck.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.style_outlined,
                  size: 40,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No flashcards in deck',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        if (state.status == FlashcardDeckStatus.completed) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_outlined, size: 48, color: cs.primary),
                  const SizedBox(height: 14),
                  Text(
                    'Deck Session Completed!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reviewed ${state.reviewedCount} cards. SM-2 intervals and ease factors updated in SQLite.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Review Deck Again'),
                    onPressed: () {
                      context.read<FlashcardSm2Cubit>().resetDeckProgress();
                    },
                  ),
                ],
              ),
            ),
          );
        }

        final card = state.currentCard!;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 12 : 16,
            vertical: isLandscape ? 8 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Deck Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card ${state.currentIndex + 1} of ${state.deck.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'Ease Factor: ${card.easeFactor}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (state.currentIndex + 1) / state.deck.length,
                  minHeight: 5,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Interactive 3D Flip Card
              GestureDetector(
                onTap: () {
                  context.read<FlashcardSm2Cubit>().flipCard();
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final rotate = Tween<double>(
                      begin: pi,
                      end: 0.0,
                    ).animate(animation);
                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, widget) {
                        final isUnder =
                            (ValueKey(state.isFlipped) != widget?.key);
                        var tilt = (animation.value - 0.5).abs() - 0.5;
                        tilt *= isUnder ? -0.003 : 0.003;
                        final value = isUnder
                            ? min(rotate.value, pi / 2)
                            : rotate.value;
                        return Transform(
                          transform: Matrix4.rotationY(value)
                            ..setEntry(3, 0, tilt),
                          alignment: Alignment.center,
                          child: widget,
                        );
                      },
                    );
                  },
                  child: state.isFlipped
                      ? _buildCardBack(context, card)
                      : _buildCardFront(context, card),
                ),
              ),
              const SizedBox(height: 16),

              // SM-2 4-Tier Recall Rating Buttons
              if (state.isFlipped) ...[
                Text(
                  'SM-2 RECALL RATING',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ratingButton(
                        context,
                        label: 'Again',
                        subtext: '<1m',
                        color: cs.error,
                        onPressed: () {
                          context.read<FlashcardSm2Cubit>().rateCurrentCard(
                            Sm2Algorithm.gradeAgain,
                          );
                          AppFeedback.showInfo(
                            context,
                            'Reset card interval (<1m)',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ratingButton(
                        context,
                        label: 'Hard',
                        subtext: '12h',
                        color: cs.secondary,
                        onPressed: () {
                          context.read<FlashcardSm2Cubit>().rateCurrentCard(
                            Sm2Algorithm.gradeHard,
                          );
                          AppFeedback.showInfo(
                            context,
                            'Scheduled for next 12h review',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ratingButton(
                        context,
                        label: 'Good',
                        subtext: '2d',
                        color: cs.tertiary,
                        onPressed: () {
                          context.read<FlashcardSm2Cubit>().rateCurrentCard(
                            Sm2Algorithm.gradeGood,
                          );
                          AppFeedback.showSuccess(
                            context,
                            'Interval expanded to 2 days (+15 XP)',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ratingButton(
                        context,
                        label: 'Easy',
                        subtext: '5d',
                        color: cs.primary,
                        onPressed: () {
                          context.read<FlashcardSm2Cubit>().rateCurrentCard(
                            Sm2Algorithm.gradeEasy,
                          );
                          AppFeedback.showSuccess(
                            context,
                            'Mastery interval set to 5+ days (+15 XP)',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Text(
                    'Tap card to reveal architectural answer & code sample',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 70), // Room for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardFront(BuildContext context, FlashcardModel card) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cs.outlineVariant.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  card.topicTag,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  card.status,
                  style: TextStyle(fontSize: 10.5, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            card.frontPrompt,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.45,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.touch_app_outlined, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                'Tap to flip',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, FlashcardModel card) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ARCHITECTURAL ANSWER',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              Icon(Icons.check_circle_outline, size: 16, color: cs.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.backAnswer,
            style: TextStyle(fontSize: 13, height: 1.45, color: cs.onSurface),
          ),
          if (card.codeExample.isNotEmpty) ...[
            const SizedBox(height: 12),
            CodeSyntaxView(code: card.codeExample, fontSize: 11),
          ],
        ],
      ),
    );
  }

  Widget _ratingButton(
    BuildContext context, {
    required String label,
    required String subtext,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        backgroundColor: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtext,
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showCreateCardSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topicController = TextEditingController();
    final promptController = TextEditingController();
    final answerController = TextEditingController();
    final codeController = TextEditingController();
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
                        Icon(Icons.add_card, color: cs.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Create Custom Flashcard',
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
                      controller: topicController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      decoration: const InputDecoration(
                        labelText:
                            'Topic Tag (e.g., Concurrency, Shaders, Consensus)',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a topic tag.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: promptController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Front Question / Architecture Scenario',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter the question prompt.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: answerController,
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Back Answer (In-depth explanation)',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter the detailed answer.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: codeController,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: cs.onSurface,
                      ),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Optional Code Example / AST Pattern',
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
                        'Add to SM-2 Repetition Deck',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final success = await context
                              .read<FlashcardSm2Cubit>()
                              .createCustomCard(
                                topicTag: topicController.text,
                                frontPrompt: promptController.text,
                                backAnswer: answerController.text,
                                codeExample: codeController.text,
                              );
                          if (success && sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                            AppFeedback.showSuccess(
                              context,
                              'Flashcard added to repetition graph (+25 XP).',
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
}
