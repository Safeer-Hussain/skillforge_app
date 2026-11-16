import 'package:flutter_bloc/flutter_bloc.dart';

import 'complexity_state.dart';

class ComplexityCubit extends Cubit<ComplexityState> {
  ComplexityCubit() : super(const ComplexityState());

  void setDataSizeN(int n) {
    emit(state.copyWith(dataSizeN: n.clamp(1, 64)));
  }

  void toggleVisibility(ComplexityClass comp) {
    final updated = Set<ComplexityClass>.from(state.visibleClasses);
    if (updated.contains(comp)) {
      if (updated.length > 1) {
        updated.remove(comp);
      }
    } else {
      updated.add(comp);
    }
    emit(state.copyWith(visibleClasses: updated));
  }

  void selectClass(ComplexityClass comp) {
    emit(state.copyWith(selectedClass: comp));
  }

  void toggleSpaceMode() {
    emit(state.copyWith(isSpaceMode: !state.isSpaceMode));
  }
}
