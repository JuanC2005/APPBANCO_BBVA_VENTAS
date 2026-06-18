import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../data/cobranza_repository.dart';
import '../domain/cliente_mora.dart';

class CobranzaState {
  final List<ClienteMora> clientesMora;
  final bool isLoading;
  final String? error;
  final bool accionExitosa;

  const CobranzaState({
    this.clientesMora = const [],
    this.isLoading = false,
    this.error,
    this.accionExitosa = false,
  });

  CobranzaState copyWith({
    List<ClienteMora>? clientesMora,
    bool? isLoading,
    String? error,
    bool? accionExitosa,
    bool clearError = false,
  }) {
    return CobranzaState(
      clientesMora: clientesMora ?? this.clientesMora,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      accionExitosa: accionExitosa ?? this.accionExitosa,
    );
  }
}

class CobranzaViewModel extends StateNotifier<CobranzaState> {
  final CobranzaRepository _repository;
  final AuthViewModel _authViewModel;

  CobranzaViewModel(this._repository, this._authViewModel)
      : super(const CobranzaState());

  Future<void> cargarMora() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final asesor = _authViewModel.state.asesor;
      if (asesor == null) throw Exception('No autenticado');
      final lista = await _repository.listarMora(asesor.id);
      state = state.copyWith(clientesMora: lista, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<void> registrarAccion({
    required String clienteId,
    required String? creditoId,
    required String tipoGestion,
    required String resultado,
    required String observaciones,
    double? montoPagado,
    double? montoComprometido,
    DateTime? fechaCompromiso,
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final asesor = _authViewModel.state.asesor;
      if (asesor == null) throw Exception('No autenticado');
      await _repository.registrarAccion(
        asesorId: asesor.id,
        clienteId: clienteId,
        creditoId: creditoId,
        tipoGestion: tipoGestion,
        resultado: resultado,
        observaciones: observaciones,
        montoPagado: montoPagado,
        montoComprometido: montoComprometido,
        fechaCompromiso: fechaCompromiso,
        lat: lat,
        lng: lng,
      );
      state = state.copyWith(isLoading: false, accionExitosa: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  void resetAccion() {
    state = state.copyWith(accionExitosa: false);
  }
}

final cobranzaViewModelProvider =
    StateNotifierProvider<CobranzaViewModel, CobranzaState>((ref) {
  return CobranzaViewModel(
    ref.watch(cobranzaRepositoryProvider),
    ref.watch(authViewModelProvider.notifier),
  );
});
