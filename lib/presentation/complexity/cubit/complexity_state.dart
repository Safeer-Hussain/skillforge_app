import 'dart:math';

enum ComplexityClass {
  o1('O(1)', 'Constant', 'Hash map lookup, array index, stack push/pop'),
  oLogN(
    'O(log n)',
    'Logarithmic',
    'Binary search, balanced BST lookup, divide & conquer',
  ),
  oN('O(n)', 'Linear', 'Linear scan, array traversal, counting elements'),
  oNLogN(
    'O(n log n)',
    'Linearithmic',
    'Merge sort, heap sort, quick sort average case',
  ),
  oN2(
    'O(n^2)',
    'Quadratic',
    'Bubble sort, nested loops, adjacency matrix search',
  ),
  o2N(
    'O(2^n)',
    'Exponential',
    'Recursive Fibonacci, power set generation, TSP brute force',
  );

  final String notation;
  final String label;
  final String description;

  const ComplexityClass(this.notation, this.label, this.description);
}

class ComplexityState {
  final int dataSizeN;
  final Set<ComplexityClass> visibleClasses;
  final ComplexityClass selectedClass;
  final bool isSpaceMode; // false = Time Complexity, true = Space Complexity

  const ComplexityState({
    this.dataSizeN = 16,
    this.visibleClasses = const {
      ComplexityClass.o1,
      ComplexityClass.oLogN,
      ComplexityClass.oN,
      ComplexityClass.oNLogN,
    },
    this.selectedClass = ComplexityClass.oN,
    this.isSpaceMode = false,
  });

  ComplexityState copyWith({
    int? dataSizeN,
    Set<ComplexityClass>? visibleClasses,
    ComplexityClass? selectedClass,
    bool? isSpaceMode,
  }) {
    return ComplexityState(
      dataSizeN: dataSizeN ?? this.dataSizeN,
      visibleClasses: visibleClasses ?? this.visibleClasses,
      selectedClass: selectedClass ?? this.selectedClass,
      isSpaceMode: isSpaceMode ?? this.isSpaceMode,
    );
  }

  double calculateOperations(ComplexityClass comp, int n) {
    if (n <= 0) return 0;
    switch (comp) {
      case ComplexityClass.o1:
        return 1.0;
      case ComplexityClass.oLogN:
        return (log(n) / ln2);
      case ComplexityClass.oN:
        return n.toDouble();
      case ComplexityClass.oNLogN:
        return n * (log(n) / ln2);
      case ComplexityClass.oN2:
        return (n * n).toDouble();
      case ComplexityClass.o2N:
        return n > 20 ? pow(2, 20).toDouble() : pow(2, n).toDouble();
    }
  }

  String getRatingForOperations(double ops) {
    if (ops <= 5) return 'Optimal';
    if (ops <= 25) return 'Good';
    if (ops <= 100) return 'Fair';
    if (ops <= 500) return 'Poor';
    return 'Critical';
  }
}
