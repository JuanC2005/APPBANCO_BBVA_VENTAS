import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cliente.dart';
import '../domain/credito.dart';
import '../domain/preaprobado.dart';
import '../data/ficha_repository.dart';

class FichaState {
  final Cliente? cliente;
  final List<Credito> creditos;
  final Preaprobado? preaprobado;
  final Map<String, dynamic>? score;
  final List<Map<String, dynamic>> movimientos;
  final Map<String, dynamic>? perfil;
  final bool isLoading;
  final String? error;

  const FichaState({
    this.cliente,
    this.creditos = const [],
    this.preaprobado,
    this.score,
    this.movimientos = const [],
    this.perfil,
    this.isLoading = false,
    this.error,
  });

  FichaState copyWith({
    Cliente? cliente,
    List<Credito>? creditos,
    Preaprobado? preaprobado,
    Map<String, dynamic>? score,
    List<Map<String, dynamic>>? movimientos,
    Map<String, dynamic>? perfil,
    bool? isLoading,
    String? error,
  }) {
    return FichaState(
      cliente: cliente ?? this.cliente,
      creditos: creditos ?? this.creditos,
      preaprobado: preaprobado ?? this.preaprobado,
      score: score ?? this.score,
      movimientos: movimientos ?? this.movimientos,
      perfil: perfil ?? this.perfil,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double? get scoreActual {
    if (score == null) return null;
    return (score!['score'] as num?)?.toDouble();
  }

  String? get segmento {
    return score?['segmento'] as String?;
  }
}

class FichaViewModel extends StateNotifier<FichaState> {
  final FichaRepository _repository;

  FichaViewModel(this._repository) : super(const FichaState());

  Future<void> cargarFicha(String clienteId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _repository.obtenerCliente(clienteId),
        _repository.obtenerCreditos(clienteId),
        _repository.obtenerScore(clienteId),
        _repository.obtenerMovimientos(clienteId),
        _repository.obtenerPreaprobado(clienteId),
        _repository.obtenerPerfil(clienteId),
      ]);
      state = state.copyWith(
        cliente: results[0] as Cliente?,
        creditos: results[1] as List<Credito>,
        score: results[2] as Map<String, dynamic>?,
        movimientos: results[3] as List<Map<String, dynamic>>,
        preaprobado: results[4] as Preaprobado?,
        perfil: results[5] as Map<String, dynamic>?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  String get scoreLabel {
    if (state.scoreActual == null) return 'N/D';
    final s = state.scoreActual!;
    final seg = state.segmento ?? '';
    return '$s ($seg)';
  }
}

final fichaViewModelProvider =
    StateNotifierProvider<FichaViewModel, FichaState>((ref) {
  return FichaViewModel(ref.watch(fichaRepositoryProvider));
});
