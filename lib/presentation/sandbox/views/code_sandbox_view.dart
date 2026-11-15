import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sandbox_bloc.dart';
import '../bloc/sandbox_event.dart';
import '../bloc/sandbox_state.dart';
import '../../../data/models/challenge_model.dart';
import '../../../core/utils/app_feedback.dart';

class CodeSandboxView extends StatefulWidget {
  final String? initialChallengeId;

  const CodeSandboxView({super.key, this.initialChallengeId});

  @override
  State<CodeSandboxView> createState() => _CodeSandboxViewState();
}

class _CodeSandboxViewState extends State<CodeSandboxView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _codeController;
  late final TabController _outputTabController;

  final List<String> _quickSymbols = [
    '{ }',
    '( )',
    '=>',
    'async',
    'await',
    ';',
    'final',
    'return',
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _outputTabController = TabController(length: 2, vsync: this);

    final bloc = context.read<SandboxBloc>();
    if (bloc.state.challenges.isEmpty) {
      bloc.add(const LoadChallengesEvent());
    } else if (widget.initialChallengeId != null) {
      final challenge = bloc.state.challenges.firstWhere(
        (c) => c.id == widget.initialChallengeId,
        orElse: () => bloc.state.challenges.first,
      );
      bloc.add(SelectChallengeEvent(challenge));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _outputTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<SandboxBloc, SandboxState>(
      listener: (context, state) {
        if (_codeController.text != state.currentCode) {
          final sel = _codeController.selection;
          _codeController.text = state.currentCode;
          if (sel.start <= state.currentCode.length &&
              sel.end <= state.currentCode.length) {
            _codeController.selection = sel;
          }
        }

        if (state.status == SandboxStatus.success) {
          AppFeedback.showSuccess(
            context,
            'All ${state.testResult?.totalCount ?? 4} Unit Tests Passed! (+${state.selectedChallenge?.xpReward ?? 100} XP)',
          );
        } else if (state.status == SandboxStatus.failed &&
            state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final challenge = state.selectedChallenge;
        final telemetry = state.telemetry;

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Text(
              'Live Code & AST Sandbox',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              if (telemetry != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.memory, size: 13, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${telemetry.sandboxHeapMemoryMb}MB | ${telemetry.astParseLatencyMs}ms',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                tooltip: 'Reset to Template',
                icon: Icon(
                  Icons.refresh,
                  size: isLandscape ? 18 : 20,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () {
                  context.read<SandboxBloc>().add(const ResetTemplateEvent());
                  AppFeedback.showInfo(
                    context,
                    'Reset code template to challenge initial state.',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_sandbox_run_code', // Explicit unique heroTag
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            elevation: 4,
            icon: state.status == SandboxStatus.running
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              state.status == SandboxStatus.running
                  ? 'Verifying AST...'
                  : 'Run & Verify Tests',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: state.status == SandboxStatus.running
                ? null
                : () {
                    context.read<SandboxBloc>().add(
                      const RunVerifyTestsEvent(),
                    );
                  },
          ),
          body: isLandscape
              ? Row(
                  children: [
                    // Left Pane: Challenge description & Quick Picker
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildChallengePicker(context, state),
                              const SizedBox(height: 10),
                              if (challenge != null)
                                _buildChallengeOverview(context, challenge),
                              const SizedBox(height: 12),
                              _buildSymbolBar(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Right Pane: Code Editor & Console/Test Output
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildEditor(context, state),
                            const SizedBox(height: 12),
                            _buildConsoleOutput(context, state),
                            const SizedBox(height: 60), // Room for FAB
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildChallengePicker(context, state),
                      const SizedBox(height: 10),
                      if (challenge != null)
                        _buildChallengeOverview(context, challenge),
                      const SizedBox(height: 10),
                      _buildSymbolBar(context),
                      const SizedBox(height: 10),
                      _buildEditor(context, state),
                      const SizedBox(height: 12),
                      _buildConsoleOutput(context, state),
                      const SizedBox(height: 80), // Room for FAB
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildChallengePicker(BuildContext context, SandboxState state) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChallengeModel>(
          value: state.selectedChallenge,
          isExpanded: true,
          dropdownColor: cs.surfaceContainer,
          icon: Icon(Icons.keyboard_arrow_down, color: cs.primary),
          hint: Text(
            'Select Challenge...',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          items: state.challenges.map((c) {
            return DropdownMenuItem<ChallengeModel>(
              value: c,
              child: Row(
                children: [
                  Icon(
                    c.isCompleted ? Icons.check_circle : Icons.code,
                    size: 16,
                    color: c.isCompleted ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (c) {
            if (c != null) {
              context.read<SandboxBloc>().add(SelectChallengeEvent(c));
            }
          },
        ),
      ),
    );
  }

  Widget _buildChallengeOverview(
    BuildContext context,
    ChallengeModel challenge,
  ) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  challenge.domain,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  challenge.difficulty,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '+${challenge.xpReward} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: TextStyle(fontSize: 12, height: 1.4, color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickSymbols.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final symbol = _quickSymbols[index];
          return ActionChip(
            label: Text(
              symbol,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            backgroundColor: cs.surfaceContainerHighest,
            side: BorderSide(color: cs.outlineVariant),
            padding: EdgeInsets.zero,
            onPressed: () {
              context.read<SandboxBloc>().add(InsertSymbolEvent(' $symbol '));
            },
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context, SandboxState state) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DART SOURCE EDITOR',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                'Isolate Sandboxed',
                style: TextStyle(
                  fontSize: 10,
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _codeController,
            maxLines: 12,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.45,
              color: cs.onSurface,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (val) {
              context.read<SandboxBloc>().add(UpdateCodeEvent(val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleOutput(BuildContext context, SandboxState state) {
    final cs = Theme.of(context).colorScheme;
    final testResult = state.testResult;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _outputTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: cs.primary,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Console Output'),
              Tab(text: 'Assertion Verification'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: TabBarView(
              controller: _outputTabController,
              children: [
                // Console Tab
                SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      state.consoleOutput,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        height: 1.4,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                // Assertion Tab
                testResult == null
                    ? Center(
                        child: Text(
                          'No unit assertions run yet. Press "Run & Verify Tests".',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: testResult.assertions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, idx) {
                          final a = testResult.assertions[idx];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: a.passed
                                  ? cs.primaryContainer.withValues(alpha: 0.3)
                                  : cs.errorContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: a.passed
                                    ? cs.primary.withValues(alpha: 0.5)
                                    : cs.error.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  a.passed ? Icons.check_circle : Icons.cancel,
                                  size: 16,
                                  color: a.passed ? cs.primary : cs.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a.name,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${a.latencyMs} ms',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontFamily: 'monospace',
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
