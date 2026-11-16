import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge_app/presentation/complexity/cubit/complexity_cubit.dart';
import 'package:skill_forge_app/presentation/complexity/cubit/complexity_state.dart';

void main() {
  late ComplexityCubit cubit;

  setUp(() {
    cubit = ComplexityCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('ComplexityCubit Tests (Sprint 1)', () {
    test('Initial state defaults to N=16 and includes standard classes', () {
      expect(cubit.state.dataSizeN, 16);
      expect(cubit.state.visibleClasses.contains(ComplexityClass.o1), true);
      expect(cubit.state.visibleClasses.contains(ComplexityClass.oLogN), true);
      expect(cubit.state.visibleClasses.contains(ComplexityClass.oN), true);
      expect(cubit.state.visibleClasses.contains(ComplexityClass.oNLogN), true);
      expect(cubit.state.isSpaceMode, false);
    });

    test('setDataSizeN clamps within range [1, 64]', () {
      cubit.setDataSizeN(32);
      expect(cubit.state.dataSizeN, 32);

      cubit.setDataSizeN(0);
      expect(cubit.state.dataSizeN, 1);

      cubit.setDataSizeN(100);
      expect(cubit.state.dataSizeN, 64);
    });

    test(
      'toggleVisibility adds and removes classes while preserving at least one',
      () {
        expect(cubit.state.visibleClasses.contains(ComplexityClass.oN2), false);

        cubit.toggleVisibility(ComplexityClass.oN2);
        expect(cubit.state.visibleClasses.contains(ComplexityClass.oN2), true);

        cubit.toggleVisibility(ComplexityClass.oN2);
        expect(cubit.state.visibleClasses.contains(ComplexityClass.oN2), false);
      },
    );

    test('toggleSpaceMode toggles between Time and Space modes', () {
      expect(cubit.state.isSpaceMode, false);
      cubit.toggleSpaceMode();
      expect(cubit.state.isSpaceMode, true);
      cubit.toggleSpaceMode();
      expect(cubit.state.isSpaceMode, false);
    });

    test('calculateOperations computes accurate mathematical values', () {
      final state = cubit.state;

      // O(1) at N=16 is 1.0
      expect(state.calculateOperations(ComplexityClass.o1, 16), 1.0);

      // O(log n) at N=16 (log2(16)) is 4.0
      expect(state.calculateOperations(ComplexityClass.oLogN, 16), 4.0);

      // O(n) at N=16 is 16.0
      expect(state.calculateOperations(ComplexityClass.oN, 16), 16.0);

      // O(n log n) at N=16 (16 * 4) is 64.0
      expect(state.calculateOperations(ComplexityClass.oNLogN, 16), 64.0);

      // O(n^2) at N=16 is 256.0
      expect(state.calculateOperations(ComplexityClass.oN2, 16), 256.0);

      // O(2^n) at N=4 is 16.0
      expect(state.calculateOperations(ComplexityClass.o2N, 4), 16.0);
    });

    test('getRatingForOperations returns correct qualitative benchmarks', () {
      final state = cubit.state;
      expect(state.getRatingForOperations(2.0), 'Optimal');
      expect(state.getRatingForOperations(15.0), 'Good');
      expect(state.getRatingForOperations(50.0), 'Fair');
      expect(state.getRatingForOperations(200.0), 'Poor');
      expect(state.getRatingForOperations(1000.0), 'Critical');
    });
  });
}
