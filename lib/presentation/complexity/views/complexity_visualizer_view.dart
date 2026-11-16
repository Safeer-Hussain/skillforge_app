import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cubit/complexity_cubit.dart';
import '../cubit/complexity_state.dart';
import '../../widgets/code_syntax_view.dart';
import '../../../core/utils/app_feedback.dart';

class ComplexityVisualizerView extends StatelessWidget {
  const ComplexityVisualizerView({super.key});

  Color _getColorForClass(ComplexityClass comp, ColorScheme cs) {
    switch (comp) {
      case ComplexityClass.o1:
        return cs.primary;
      case ComplexityClass.oLogN:
        return cs.tertiary;
      case ComplexityClass.oN:
        return cs.secondary;
      case ComplexityClass.oNLogN:
        return cs.error;
      case ComplexityClass.oN2:
        return cs.outline;
      case ComplexityClass.o2N:
        return cs.onSurfaceVariant;
    }
  }

  String _getCodeSnippetForClass(ComplexityClass comp) {
    switch (comp) {
      case ComplexityClass.o1:
        return '''// Constant Time: Direct Hash Lookup
V? getElement<K, V>(Map<K, V> map, K key) {
  return map[key]; // Direct address offset calculation
}''';
      case ComplexityClass.oLogN:
        return '''// Logarithmic Time: Binary Search
int binarySearch(List<int> sorted, int target) {
  int low = 0, high = sorted.length - 1;
  while (low <= high) {
    int mid = (low + high) ~/ 2;
    if (sorted[mid] == target) return mid;
    if (sorted[mid] < target) low = mid + 1;
    else high = mid - 1;
  }
  return -1;
}''';
      case ComplexityClass.oN:
        return '''// Linear Time: Array Scan
bool containsValue(List<int> items, int target) {
  for (int i = 0; i < items.length; i++) {
    if (items[i] == target) return true;
  }
  return false;
}''';
      case ComplexityClass.oNLogN:
        return '''// Linearithmic Time: Merge Sort
List<int> mergeSort(List<int> list) {
  if (list.length <= 1) return list;
  int mid = list.length ~/ 2;
  var left = mergeSort(list.sublist(0, mid));
  var right = mergeSort(list.sublist(mid));
  return merge(left, right); // O(N) merge at each O(log N) depth
}''';
      case ComplexityClass.oN2:
        return '''// Quadratic Time: Nested Cross-Product
List<List<int>> findPairs(List<int> a, List<int> b) {
  final pairs = <List<int>>[];
  for (final x in a) {
    for (final y in b) {
      pairs.add([x, y]); // N * N total operations
    }
  }
  return pairs;
}''';
      case ComplexityClass.o2N:
        return '''// Exponential Time: Unmemoized Recursion
int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2); // 2^N recursion tree
}''';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocBuilder<ComplexityCubit, ComplexityState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Text(
              'Big-O Complexity Visualizer',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              TextButton.icon(
                icon: Icon(
                  state.isSpaceMode ? Icons.memory : Icons.speed,
                  size: isLandscape ? 16 : 18,
                  color: cs.primary,
                ),
                label: Text(
                  state.isSpaceMode ? 'Space Complexity' : 'Time Complexity',
                  style: TextStyle(
                    fontSize: isLandscape ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                onPressed: () {
                  context.read<ComplexityCubit>().toggleSpaceMode();
                  AppFeedback.showInfo(
                    context,
                    state.isSpaceMode
                        ? 'Switched to Time Complexity (CPU Cycles)'
                        : 'Switched to Space Complexity (Heap/Stack Memory)',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_complexity_reset', // Explicit unique heroTag
            backgroundColor: cs.surfaceContainerHighest,
            foregroundColor: cs.onSurface,
            elevation: 3,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text(
              'Reset N = 16',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              context.read<ComplexityCubit>().setDataSizeN(16);
              AppFeedback.showInfo(context, 'Reset input data size to N = 16.');
            },
          ),
          body: isLandscape
              ? Row(
                  children: [
                    // Left Pane: Interactive Chart
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildChartCard(context, state, cs, isLandscape),
                            const SizedBox(height: 12),
                            _buildInputSlider(context, state, cs),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    // Right Pane: Controls, Operations Breakdown & Code
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFilterChips(context, state, cs),
                            const SizedBox(height: 12),
                            _buildMetricsBreakdown(context, state, cs),
                            const SizedBox(height: 12),
                            _buildCodeSample(context, state, cs),
                            const SizedBox(height: 60),
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
                      _buildChartCard(context, state, cs, isLandscape),
                      const SizedBox(height: 12),
                      _buildInputSlider(context, state, cs),
                      const SizedBox(height: 12),
                      _buildFilterChips(context, state, cs),
                      const SizedBox(height: 12),
                      _buildMetricsBreakdown(context, state, cs),
                      const SizedBox(height: 12),
                      _buildCodeSample(context, state, cs),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    ComplexityState state,
    ColorScheme cs,
    bool isLandscape,
  ) {
    final maxN = state.dataSizeN;
    final lineBars = <LineChartBarData>[];

    for (final comp in state.visibleClasses) {
      final spots = <FlSpot>[];
      final step = (maxN / 20).clamp(1.0, 5.0);

      for (double x = 1; x <= maxN; x += step) {
        final ops = state.calculateOperations(comp, x.toInt());
        // Bound y to avoid flattening lower curves
        final boundedY = ops.clamp(0.0, 300.0);
        spots.add(FlSpot(x, boundedY));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getColorForClass(comp, cs),
          barWidth: state.selectedClass == comp ? 3.5 : 2.0,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
      );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.isSpaceMode
                      ? 'SPACE ALLOCATION CURVE'
                      : 'ASYMPTOTIC RUNTIME CURVE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'N = ${state.dataSizeN}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: isLandscape ? 200 : 220,
            width: double.infinity,
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
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (maxN / 4).clamp(1.0, 16.0),
                      getTitlesWidget: (val, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'N=${val.toInt()}',
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
                      interval: 75,
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
                maxX: maxN.toDouble(),
                minY: 0,
                maxY: 300,
                lineBarsData: lineBars,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSlider(
    BuildContext context,
    ComplexityState state,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              Text(
                'Data Set Size (N Elements):',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.dataSizeN}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: state.dataSizeN.toDouble(),
            min: 1,
            max: 64,
            divisions: 63,
            activeColor: cs.primary,
            inactiveColor: cs.surfaceContainerHighest,
            onChanged: (val) {
              context.read<ComplexityCubit>().setDataSizeN(val.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    ComplexityState state,
    ColorScheme cs,
  ) {
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
          Text(
            'ACTIVE COMPLEXITY CLASSES',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ComplexityClass.values.map((comp) {
              final isVisible = state.visibleClasses.contains(comp);
              final isSelected = state.selectedClass == comp;
              final compColor = _getColorForClass(comp, cs);

              return FilterChip(
                selected: isVisible,
                showCheckmark: false,
                avatar: isVisible
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: compColor,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                label: Text(
                  comp.notation,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isVisible ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
                backgroundColor: cs.surfaceContainerHighest,
                selectedColor: compColor.withValues(alpha: 0.2),
                side: BorderSide(
                  color: isSelected ? compColor : cs.outlineVariant,
                  width: isSelected ? 1.5 : 1.0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                onSelected: (_) {
                  context.read<ComplexityCubit>().toggleVisibility(comp);
                  context.read<ComplexityCubit>().selectClass(comp);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsBreakdown(
    BuildContext context,
    ComplexityState state,
    ColorScheme cs,
  ) {
    final comp = state.selectedClass;
    final ops = state.calculateOperations(comp, state.dataSizeN);
    final rating = state.getRatingForOperations(ops);

    return Container(
      padding: const EdgeInsets.all(14),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getColorForClass(comp, cs).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  comp.notation,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForClass(comp, cs),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comp.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
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
                  rating,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: rating == 'Optimal' || rating == 'Good'
                        ? cs.primary
                        : cs.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comp.description,
            style: TextStyle(
              fontSize: 11.5,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Operations at N=${state.dataSizeN}:',
                  style: TextStyle(fontSize: 12, color: cs.onSurface),
                ),
              ),
              Text(
                ops > 10000 ? '> 10,000' : ops.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
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

  Widget _buildCodeSample(
    BuildContext context,
    ComplexityState state,
    ColorScheme cs,
  ) {
    final comp = state.selectedClass;
    final snippet = _getCodeSnippetForClass(comp);

    return Container(
      padding: const EdgeInsets.all(14),
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
                  'CANONICAL PATTERN IMPLEMENTATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comp.notation,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CodeSyntaxView(code: snippet, fontSize: 11.5),
        ],
      ),
    );
  }
}
