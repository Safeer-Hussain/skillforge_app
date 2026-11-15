import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/flashcard_sm2_cubit.dart';
import '../cubit/flashcard_sm2_state.dart';
import '../../../core/utils/app_feedback.dart';

class CertificationExamView extends StatelessWidget {
  const CertificationExamView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocBuilder<FlashcardSm2Cubit, FlashcardSm2State>(
      builder: (context, state) {
        final exam = state.examState;

        if (!exam.isExamActive && !exam.isSubmitted) {
          return _buildExamLanding(context);
        }

        if (exam.isSubmitted) {
          return _buildExamResults(context, exam);
        }

        final currentQuestion =
            FlashcardSm2Cubit.sampleExamQuestions[exam.currentQuestionIndex];
        final selectedOption = exam.selectedAnswers[exam.currentQuestionIndex];

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 12 : 16,
            vertical: isLandscape ? 8 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer & Header Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: cs.secondary),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimer(exam.remainingSeconds),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Question ${exam.currentQuestionIndex + 1} of ${FlashcardSm2Cubit.sampleExamQuestions.length}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Question Navigator Pills
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: FlashcardSm2Cubit.sampleExamQuestions.length,
                  itemBuilder: (context, idx) {
                    final isCurrent = exam.currentQuestionIndex == idx;
                    final isAnswered = exam.selectedAnswers.containsKey(idx);

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? cs.onPrimary
                                : isAnswered
                                ? cs.primary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        backgroundColor: isCurrent
                            ? cs.primary
                            : isAnswered
                            ? cs.primaryContainer.withValues(alpha: 0.3)
                            : cs.surfaceContainer,
                        side: BorderSide(
                          color: isCurrent
                              ? cs.primary
                              : isAnswered
                              ? cs.primary
                              : cs.outlineVariant,
                        ),
                        onPressed: () {
                          context
                              .read<FlashcardSm2Cubit>()
                              .setExamQuestionIndex(idx);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Question Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(currentQuestion.options.length, (optIdx) {
                      final optionText = currentQuestion.options[optIdx];
                      final isSelected = selectedOption == optIdx;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primaryContainer.withValues(alpha: 0.25)
                              : cs.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? cs.primary : cs.outlineVariant,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: RadioListTile<int>(
                          dense: true,
                          value: optIdx,
                          groupValue: selectedOption,
                          activeColor: cs.primary,
                          title: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: cs.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              context
                                  .read<FlashcardSm2Cubit>()
                                  .selectExamAnswer(
                                    exam.currentQuestionIndex,
                                    val,
                                  );
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  if (exam.currentQuestionIndex > 0)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Previous'),
                      onPressed: () {
                        context.read<FlashcardSm2Cubit>().setExamQuestionIndex(
                          exam.currentQuestionIndex - 1,
                        );
                      },
                    ),
                  const Spacer(),
                  if (exam.currentQuestionIndex <
                      FlashcardSm2Cubit.sampleExamQuestions.length - 1)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Next'),
                      onPressed: () {
                        context.read<FlashcardSm2Cubit>().setExamQuestionIndex(
                          exam.currentQuestionIndex + 1,
                        );
                      },
                    )
                  else
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.secondary,
                        foregroundColor: cs.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Submit Certification Exam'),
                      onPressed: () {
                        context.read<FlashcardSm2Cubit>().submitExam();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamLanding(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(
                Icons.assignment_turned_in_outlined,
                size: 36,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Architectural Certification Exam',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Timed senior/staff level assessment covering Flutter rendering pipeline, Dart isolates, Raft consensus, and clean system design.',
              style: TextStyle(
                fontSize: 12.5,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  _infoRow(context, Icons.timelapse, 'Duration', '10 Minutes'),
                  const Divider(height: 16),
                  _infoRow(
                    context,
                    Icons.help_outline,
                    'Questions',
                    '5 Architecture Scenarios',
                  ),
                  const Divider(height: 16),
                  _infoRow(
                    context,
                    Icons.verified_outlined,
                    'Passing Benchmark',
                    '>= 80% (Digital Certificate)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text(
                'Start Certification Exam',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context.read<FlashcardSm2Cubit>().startExam();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamResults(BuildContext context, ExamState exam) {
    final cs = Theme.of(context).colorScheme;
    final percentage = (exam.score / exam.totalQuestions) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: exam.isPassed ? cs.primary : cs.error),
            ),
            child: Column(
              children: [
                Icon(
                  exam.isPassed
                      ? Icons.workspace_premium
                      : Icons.unpublished_outlined,
                  size: 48,
                  color: exam.isPassed ? cs.secondary : cs.error,
                ),
                const SizedBox(height: 12),
                Text(
                  exam.isPassed
                      ? 'Certification Benchmark Passed'
                      : 'Assessment Incomplete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: exam.isPassed ? cs.primary : cs.error,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Score: ${exam.score} / ${exam.totalQuestions} (${percentage.toInt()}%)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                if (exam.isPassed) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Digital Credential Seal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Credential Hash: ${exam.certificateHash}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Digital Certificate Hash'),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: exam.certificateHash),
                      );
                      AppFeedback.showSuccess(
                        context,
                        'Certificate hash copied to clipboard.',
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Retake Assessment'),
            onPressed: () {
              context.read<FlashcardSm2Cubit>().startExam();
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
