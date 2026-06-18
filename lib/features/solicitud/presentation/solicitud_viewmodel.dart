import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../domain/solicitud.dart';
import '../data/solicitud_repository.dart';

class SolicitudWizardState {
  final SolicitudCredito? solicitud;
  final int pasoActual;
  final bool isLoading;
  final String? error;
  final String? enviadoExitoso;

  const SolicitudWizardState({
    this.solicitud,
    this.pasoActual = 1,
    this.isLoading = false,
    this.error,
    this.enviadoExitoso,
  });

  SolicitudWizardState copyWith({
    SolicitudCredito? solicitud,
    int? pasoActual,
    bool? isLoading,
    String? error,
    String? enviadoExitoso,
    bool clearError = false,
    bool clearEnviado = false,
  }) {
    return SolicitudWizardState(
      solicitud: solicitud ?? this.solicitud,
      pasoActual: pasoActual ?? this.pasoActual,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      enviadoExitoso: clearEnviado ? null : enviadoExitoso ?? this.enviadoExitoso,
    );
  }
}

class SolicitudViewModel extends StateNotifier<SolicitudWizardState> {
  final SolicitudRepository _repository;
  final AuthViewModel _authViewModel;

  SolicitudViewModel(this._repository, this._authViewModel)
      : super(const SolicitudWizardState());

  Future<void> iniciar(String clienteId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearEnviado: true);
    try {
      final asesor = _authViewModel.state.asesor;
      final s = await _repository.crearBorrador(
        asesorId: asesor?.id ?? '',
        clienteId: clienteId,
        agenciaId: asesor?.agenciaId,
      );
      state = state.copyWith(solicitud: s, pasoActual: 1, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al iniciar: $e');
    }
  }

  Future<void> cargar(String solicitudId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearEnviado: true);
    try {
      final s = await _repository.cargarBorrador(solicitudId);
      state = state.copyWith(
        solicitud: s,
        pasoActual: s != null ? _deducirPaso(s) : 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar: $e');
    }
  }

  int _deducirPaso(SolicitudCredito s) {
    if (s.montoSolicitado > 0) return 4;
    if (s.ingresosEstimados != null) return 3;
    if (s.tipoNegocio != null) return 2;
    return 1;
  }

  Future<void> guardarPaso1(Map<String, dynamic> datos) async {
    if (state.solicitud == null) return;
    await _repository.guardarPaso(state.solicitud!.id, {
      ...datos,
      'paso_actual': 2,
    });
    final updated = await _repository.cargarBorrador(state.solicitud!.id);
    state = state.copyWith(solicitud: updated, pasoActual: 2);
  }

  Future<void> guardarPaso2(Map<String, dynamic> datos) async {
    if (state.solicitud == null) return;
    await _repository.guardarPaso(state.solicitud!.id, {
      ...datos,
      'paso_actual': 3,
    });
    final updated = await _repository.cargarBorrador(state.solicitud!.id);
    state = state.copyWith(solicitud: updated, pasoActual: 3);
  }

  Future<void> guardarPaso3(Map<String, dynamic> datos) async {
    if (state.solicitud == null) return;
    await _repository.guardarPaso(state.solicitud!.id, {
      ...datos,
      'paso_actual': 4,
    });
    final updated = await _repository.cargarBorrador(state.solicitud!.id);
    state = state.copyWith(solicitud: updated, pasoActual: 4);
  }

  Future<void> enviar(String firmaBase64) async {
    if (state.solicitud == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.guardarPaso(state.solicitud!.id, {
        'firma_cliente_base64': firmaBase64,
        'paso_actual': 4,
      });
      final s = await _repository.cargarBorrador(state.solicitud!.id);
      if (s == null) throw Exception('Borrador no encontrado');
      await _repository.enviarSolicitud(s);
      state = state.copyWith(
        isLoading: false,
        enviadoExitoso: s.id,
        solicitud: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al enviar: $e');
    }
  }

  void irAPaso(int paso) {
    if (paso >= 1 && paso <= 4) {
      state = state.copyWith(pasoActual: paso);
    }
  }

  void limpiar() {
    state = const SolicitudWizardState();
  }
}

final solicitudViewModelProvider =
    StateNotifierProvider<SolicitudViewModel, SolicitudWizardState>((ref) {
  return SolicitudViewModel(
    ref.watch(solicitudRepositoryProvider),
    ref.watch(authViewModelProvider.notifier),
  );
});
