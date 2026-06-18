import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/preevaluacion_cliente.dart';
import '../data/preevaluacion_repository.dart';

class PreevaluacionState {
  final List<PreevaluacionCliente> items;
  final String filtroSegmento;
  final String busqueda;
  final bool isLoading;
  final String? error;

  const PreevaluacionState({
    this.items = const [],
    this.filtroSegmento = 'TODOS',
    this.busqueda = '',
    this.isLoading = false,
    this.error,
  });

  PreevaluacionState copyWith({
    List<PreevaluacionCliente>? items,
    String? filtroSegmento,
    String? busqueda,
    bool? isLoading,
    String? error,
  }) {
    return PreevaluacionState(
      items: items ?? this.items,
      filtroSegmento: filtroSegmento ?? this.filtroSegmento,
      busqueda: busqueda ?? this.busqueda,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<PreevaluacionCliente> get filtrados {
    var result = items;
    if (filtroSegmento != 'TODOS') {
      result = result.where((i) => i.segmento == filtroSegmento).toList();
    }
    if (busqueda.isNotEmpty) {
      result = result
          .where((i) => i.clienteNombre
              .toLowerCase()
              .contains(busqueda.toLowerCase()))
          .toList();
    }
    return result;
  }

  int get totalEvaluados => items.length;
  int get segmentoA => items.where((i) => i.segmento == 'A').length;
  int get segmentoB => items.where((i) => i.segmento == 'B').length;
  int get segmentoC => items.where((i) => i.segmento == 'C').length;
}

class PreevaluacionViewModel extends StateNotifier<PreevaluacionState> {
  final PreevaluacionRepository _repository;

  PreevaluacionViewModel(this._repository)
      : super(const PreevaluacionState());

  Future<void> cargar(String asesorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.obtenerPreevaluaciones(asesorId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Error al cargar preevaluaciones: $e');
    }
  }

  void setFiltroSegmento(String s) {
    state = state.copyWith(filtroSegmento: s);
  }

  void setBusqueda(String b) {
    state = state.copyWith(busqueda: b);
  }

  Future<void> recalcular(String clienteId) async {
    try {
      await _repository.recalcularScore(clienteId);
    } catch (e) {
      state = state.copyWith(error: 'Error al recalcular: $e');
    }
  }
}

final preevaluacionViewModelProvider =
    StateNotifierProvider<PreevaluacionViewModel, PreevaluacionState>(
        (ref) {
  return PreevaluacionViewModel(ref.watch(preevaluacionRepositoryProvider));
});
