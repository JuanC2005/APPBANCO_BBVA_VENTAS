import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../data/buro_repository.dart';

class BuroState {
  final bool consentimiento;
  final bool consultando;
  final Map<String, dynamic>? resultado;
  final String? error;

  const BuroState({
    this.consentimiento = false,
    this.consultando = false,
    this.resultado,
    this.error,
  });

  BuroState copyWith({
    bool? consentimiento,
    bool? consultando,
    Map<String, dynamic>? resultado,
    String? error,
    bool clearError = false,
  }) {
    return BuroState(
      consentimiento: consentimiento ?? this.consentimiento,
      consultando: consultando ?? this.consultando,
      resultado: resultado ?? this.resultado,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class BuroViewModel extends StateNotifier<BuroState> {
  final BuroRepository _repository;
  final AuthViewModel _authViewModel;

  BuroViewModel(this._repository, this._authViewModel)
      : super(const BuroState());

  void setConsentimiento(bool v) {
    state = state.copyWith(consentimiento: v, clearError: true);
  }

  Future<void> consultar({
    required String clienteId,
    required String dni,
    required String firmaConsentimiento,
  }) async {
    state = state.copyWith(consultando: true, clearError: true);
    try {
      final asesor = _authViewModel.state.asesor;
      final resultado = await _repository.consultar(
        asesorId: asesor?.id ?? '',
        clienteId: clienteId,
        dni: dni,
        firmaConsentimiento: firmaConsentimiento,
      );
      state = state.copyWith(
        consultando: false,
        resultado: resultado,
      );
    } catch (e) {
      state = state.copyWith(
        consultando: false,
        error: 'Error al consultar: $e',
      );
    }
  }

  void limpiar() {
    state = const BuroState();
  }
}

final buroViewModelProvider =
    StateNotifierProvider<BuroViewModel, BuroState>((ref) {
  return BuroViewModel(
    ref.watch(buroRepositoryProvider),
    ref.watch(authViewModelProvider.notifier),
  );
});
