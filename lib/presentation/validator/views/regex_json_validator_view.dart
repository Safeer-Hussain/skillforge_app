import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_feedback.dart';
import '../../sandbox/bloc/sandbox_bloc.dart';
import '../../sandbox/bloc/sandbox_event.dart';
import '../cubit/regex_json_cubit.dart';
import '../cubit/regex_json_state.dart';

class RegexJsonValidatorView extends StatefulWidget {
  const RegexJsonValidatorView({super.key});

  @override
  State<RegexJsonValidatorView> createState() => _RegexJsonValidatorViewState();
}

class _RegexJsonValidatorViewState extends State<RegexJsonValidatorView> {
  late final TextEditingController _regexPatternController;
  late final TextEditingController _regexInputController;
  late final TextEditingController _jsonSchemaController;
  late final TextEditingController _jsonInputController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RegexJsonCubit>();
    _regexPatternController = TextEditingController(
      text: cubit.state.regexPattern,
    );
    _regexInputController = TextEditingController(text: cubit.state.regexInput);
    _jsonSchemaController = TextEditingController(text: cubit.state.jsonSchema);
    _jsonInputController = TextEditingController(text: cubit.state.jsonInput);
  }

  @override
  void dispose() {
    _regexPatternController.dispose();
    _regexInputController.dispose();
    _jsonSchemaController.dispose();
    _jsonInputController.dispose();
    super.dispose();
  }

  void _syncControllers(RegexJsonState state) {
    if (_regexPatternController.text != state.regexPattern) {
      _regexPatternController.text = state.regexPattern;
    }
    if (_regexInputController.text != state.regexInput) {
      _regexInputController.text = state.regexInput;
    }
    if (_jsonSchemaController.text != state.jsonSchema) {
      _jsonSchemaController.text = state.jsonSchema;
    }
    if (_jsonInputController.text != state.jsonInput) {
      _jsonInputController.text = state.jsonInput;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<RegexJsonCubit, RegexJsonState>(
      listener: (context, state) {
        _syncControllers(state);
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
              'Regex & JSON Schema Studio',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Select Preset Template',
                icon: Icon(
                  Icons.bookmarks_outlined,
                  size: isLandscape ? 18 : 20,
                  color: cs.primary,
                ),
                onPressed: () => _showPresetPicker(context, state),
              ),
              IconButton(
                tooltip: 'Save Custom Pattern',
                icon: Icon(
                  Icons.bookmark_add_outlined,
                  size: isLandscape ? 18 : 20,
                  color: cs.secondary,
                ),
                onPressed: () => _showSaveTemplateModal(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_regex_json_validate',
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            elevation: 4,
            icon: const Icon(Icons.code_outlined, size: 20),
            label: Text(
              state.mode == ValidatorMode.regex
                  ? 'Inject Regex into Sandbox'
                  : 'Generate Dart Model',
              style: TextStyle(
                fontSize: isLandscape ? 11 : 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              if (state.mode == ValidatorMode.regex) {
                _injectRegexIntoSandbox(context, state);
              } else {
                _showDartModelModal(context, state);
              }
            },
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, state)
              : _buildPortraitLayout(context, state),
        );
      },
    );
  }

  Widget _buildModeSegmentedControl(
    BuildContext context,
    RegexJsonState state,
  ) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<RegexJsonCubit>();

    return SegmentedButton<ValidatorMode>(
      segments: const [
        ButtonSegment<ValidatorMode>(
          value: ValidatorMode.regex,
          icon: Icon(Icons.find_replace_outlined, size: 16),
          label: Text('Regex Tester'),
        ),
        ButtonSegment<ValidatorMode>(
          value: ValidatorMode.jsonSchema,
          icon: Icon(Icons.data_object_outlined, size: 16),
          label: Text('JSON Schema'),
        ),
      ],
      selected: {state.mode},
      onSelectionChanged: (Set<ValidatorMode> newSelection) {
        cubit.setMode(newSelection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primaryContainer;
          }
          return cs.surfaceContainer;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.onPrimaryContainer;
          }
          return cs.onSurfaceVariant;
        }),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, RegexJsonState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModeSegmentedControl(context, state),
          const SizedBox(height: 14),
          if (state.mode == ValidatorMode.regex)
            _buildRegexEditorSection(context, state)
          else
            _buildJsonSchemaSection(context, state),
          const SizedBox(height: 80), // Room for FAB
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, RegexJsonState state) {
    return Row(
      children: [
        // Left Column: Inputs & Flags
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildModeSegmentedControl(context, state),
                const SizedBox(height: 10),
                if (state.mode == ValidatorMode.regex)
                  _buildRegexInputsOnly(context, state)
                else
                  _buildJsonInputsOnly(context, state),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
        Container(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        // Right Column: Live Match Results / Violations
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.mode == ValidatorMode.regex)
                  _buildRegexResultsOnly(context, state)
                else
                  _buildJsonResultsOnly(context, state),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegexEditorSection(BuildContext context, RegexJsonState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRegexInputsOnly(context, state),
        const SizedBox(height: 14),
        _buildRegexResultsOnly(context, state),
      ],
    );
  }

  Widget _buildRegexInputsOnly(BuildContext context, RegexJsonState state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<RegexJsonCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pattern Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: state.regexResult.isPatternValid
                  ? cs.outlineVariant
                  : cs.error,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'REGULAR EXPRESSION PATTERN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.regexResult.isPatternValid
                        ? '${state.regexResult.executionTimeMicros} µs'
                        : 'Syntax Error',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: state.regexResult.isPatternValid
                          ? cs.primary
                          : cs.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _regexPatternController,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: r'Enter regex, e.g. ^v?(\d+)\.(\d+)\.(\d+)$',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => cubit.updateRegexPattern(val),
              ),
              if (!state.regexResult.isPatternValid &&
                  state.regexResult.patternError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.regexResult.patternError!,
                    style: TextStyle(fontSize: 11, color: cs.error),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Flags Chips
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('Case Insensitive (i)'),
              selected: state.caseInsensitive,
              onSelected: (_) => cubit.toggleFlag('caseInsensitive'),
              selectedColor: cs.primaryContainer,
              side: BorderSide(
                color: state.caseInsensitive ? cs.primary : cs.outlineVariant,
              ),
              labelStyle: TextStyle(
                fontSize: 10.5,
                color: state.caseInsensitive
                    ? cs.onPrimaryContainer
                    : cs.onSurfaceVariant,
              ),
            ),
            FilterChip(
              label: const Text('Multi-line (m)'),
              selected: state.multiLine,
              onSelected: (_) => cubit.toggleFlag('multiLine'),
              selectedColor: cs.primaryContainer,
              side: BorderSide(
                color: state.multiLine ? cs.primary : cs.outlineVariant,
              ),
              labelStyle: TextStyle(
                fontSize: 10.5,
                color: state.multiLine
                    ? cs.onPrimaryContainer
                    : cs.onSurfaceVariant,
              ),
            ),
            FilterChip(
              label: const Text('DotAll (s)'),
              selected: state.dotAll,
              onSelected: (_) => cubit.toggleFlag('dotAll'),
              selectedColor: cs.primaryContainer,
              side: BorderSide(
                color: state.dotAll ? cs.primary : cs.outlineVariant,
              ),
              labelStyle: TextStyle(
                fontSize: 10.5,
                color: state.dotAll
                    ? cs.onPrimaryContainer
                    : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Sample Input String
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEST INPUT STRING',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _regexInputController,
                maxLines: 5,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.4,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter test string against which regex runs...',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => cubit.updateRegexInput(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegexResultsOnly(BuildContext context, RegexJsonState state) {
    final cs = Theme.of(context).colorScheme;
    final matches = state.regexResult.matches;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'MATCH CAPTURES & GROUPS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: matches.isNotEmpty
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${matches.length} Matches',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: matches.isNotEmpty
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (matches.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                'No match captured. Ensure pattern and test string are aligned.',
                style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final match = matches[idx];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Match #${match.index + 1} [idx: ${match.start}..${match.end}]',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: match.matchedText),
                              );
                              AppFeedback.showInfo(
                                context,
                                'Copied matched text to clipboard.',
                              );
                            },
                            child: Icon(
                              Icons.content_copy_outlined,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.matchedText,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: cs.onSurface,
                        ),
                      ),
                      if (match.groups.length > 1) ...[
                        const Divider(height: 12),
                        ...match.groups.skip(1).map((g) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '${g.groupName}: ',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: cs.secondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    g.value,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildJsonSchemaSection(BuildContext context, RegexJsonState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildJsonInputsOnly(context, state),
        const SizedBox(height: 14),
        _buildJsonResultsOnly(context, state),
      ],
    );
  }

  Widget _buildJsonInputsOnly(BuildContext context, RegexJsonState state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<RegexJsonCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Schema Editor
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'JSON SCHEMA DEFINITION (DRAFT-07)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      Icons.format_align_left_outlined,
                      size: 14,
                      color: cs.primary,
                    ),
                    label: Text(
                      'Prettify',
                      style: TextStyle(fontSize: 10.5, color: cs.primary),
                    ),
                    onPressed: () => cubit.formatJsonSchema(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _jsonSchemaController,
                maxLines: 8,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.4,
                  color: cs.onSurface,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => cubit.updateJsonSchema(val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Sample Payload Editor
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'TARGET JSON PAYLOAD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      Icons.format_align_left_outlined,
                      size: 14,
                      color: cs.primary,
                    ),
                    label: Text(
                      'Prettify',
                      style: TextStyle(fontSize: 10.5, color: cs.primary),
                    ),
                    onPressed: () => cubit.formatJsonInput(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _jsonInputController,
                maxLines: 7,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.4,
                  color: cs.onSurface,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => cubit.updateJsonInput(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJsonResultsOnly(BuildContext context, RegexJsonState state) {
    final cs = Theme.of(context).colorScheme;
    final res = state.jsonResult;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: res.isValid ? cs.primary.withValues(alpha: 0.5) : cs.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'SCHEMA CONFORMANCE DIAGNOSTICS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    res.isValid
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    size: 16,
                    color: res.isValid ? cs.primary : cs.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    res.isValid ? 'Valid Schema' : 'Violations Found',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: res.isValid ? cs.primary : cs.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (res.isValid)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payload strictly adheres to JSON Schema invariants.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All required keys, numeric bounds, and regex string patterns verified in ${res.parseLatencyMicros} µs.',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: res.violations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, idx) {
                final v = res.violations[idx];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 16, color: cs.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.path,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: cs.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              v.message,
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showPresetPicker(BuildContext context, RegexJsonState state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<RegexJsonCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Curated Engineering Presets',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...state.templates.map((tpl) {
                    final isCurrent = state.selectedTemplate?.id == tpl.id;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        tpl.type == 'regex'
                            ? Icons.find_replace_outlined
                            : Icons.data_object_outlined,
                        color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                      ),
                      title: Text(
                        tpl.title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrent ? cs.primary : cs.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        tpl.type == 'regex' ? 'Regex' : 'JSON Schema',
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      trailing: !tpl.isPreset
                          ? IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: cs.error,
                              ),
                              onPressed: () {
                                cubit.deleteTemplate(tpl.id);
                                Navigator.of(sheetContext).pop();
                                AppFeedback.showInfo(
                                  context,
                                  'Deleted custom pattern template.',
                                );
                              },
                            )
                          : null,
                      onTap: () {
                        cubit.selectTemplate(tpl);
                        Navigator.of(sheetContext).pop();
                        AppFeedback.showSuccess(context, 'Loaded ${tpl.title}');
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSaveTemplateModal(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<RegexJsonCubit>();
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Save Custom Pattern Template',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Template Title',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
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
                        return 'Template title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        cubit.saveCustomTemplate(titleController.text.trim());
                        Navigator.of(sheetContext).pop();
                        AppFeedback.showSuccess(
                          context,
                          'Template saved to SQLite database.',
                        );
                      }
                    },
                    child: const Text('Save Template'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDartModelModal(BuildContext context, RegexJsonState state) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<RegexJsonCubit>();
    cubit.generateDartModel('TelemetryEvent');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generated Dart Class Definition',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      cubit.state.generatedDartModel ?? '// No model generated',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        height: 1.4,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.content_copy_outlined, size: 16),
                    label: const Text('Copy Dart Class to Clipboard'),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: cubit.state.generatedDartModel ?? '',
                        ),
                      );
                      Navigator.of(sheetContext).pop();
                      AppFeedback.showSuccess(
                        context,
                        'Dart model code copied to clipboard.',
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

  void _injectRegexIntoSandbox(BuildContext context, RegexJsonState state) {
    final pattern = state.regexPattern.replaceAll(r'\', r'\\');
    final codeSnippet =
        '''
// Injected Regex Validator Model
void validateRegexMatch() {
  final regExp = RegExp(r'$pattern');
  final sample = '${state.regexInput}';
  final matches = regExp.allMatches(sample);
  print('Regex execution completed. Captured \${matches.length} matches.');
}
''';
    context.read<SandboxBloc>().add(InsertSymbolEvent('\n$codeSnippet'));
    AppFeedback.showSuccess(
      context,
      'Injected regex pattern and test runner into Sandbox source buffer.',
    );
  }
}
