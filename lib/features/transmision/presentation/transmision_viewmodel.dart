import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transmision_repository.dart';

class TransmisionState {
  final double progreso;
  final bool transmitiendo;
  final bool completado;
  final bool error;
  final String? mensaje;

  const TransmisionState({
    this.progreso = 0,
    this.transmitiendo = false,
    this.completado = false,
    this.error = false,
    this.mensaje,
  });

  TransmisionState copyWith({
    double? progreso,
    bool? transmitiendo,
    bool? completado,
    bool? error,
    String? mensaje,
  }) {
    return TransmisionState(
      progreso: progreso ?? this.progreso,
      transmitiendo: transmitiendo ?? this.transmitiendo,
      completado: completado ?? this.completado,
      error: error ?? this.error,
      mensaje: mensaje ?? this.mensaje,
    );
  }
}

class TransmisionViewModel extends StateNotifier<TransmisionState> {
  final TransmisionRepository _repository;

  TransmisionViewModel(this._repository) : super(const TransmisionState());

  Future<void> iniciar(String solicitudId) async {
    state = state.copyWith(transmitiendo: true, progreso: 0, error: false);
    final pasos = [
      'Validando datos de solicitud...',
      'Adjuntando documentos...',
      'Procesando firma digital...',
      'Transmitiendo a core bancario...',
      'Confirmando recepción...',
    ];

    for (int i = 0; i < pasos.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(
        progreso: (i + 1) / pasos.length,
        mensaje: pasos[i],
      );
    }

    final exito = await _repository.transmitir(solicitudId);
    state = state.copyWith(
      transmitiendo: false,
      completado: exito,
      error: !exito,
      mensaje: exito
          ? 'Transmisión completada exitosamente'
          : 'Error al transmitir. Intente nuevamente.',
    );
  }

  void reset() {
    state = const TransmisionState();
  }
}

final transmisionViewModelProvider =
    StateNotifierProvider<TransmisionViewModel, TransmisionState>((ref) {
  return TransmisionViewModel(ref.watch(transmisionRepositoryProvider));
});
