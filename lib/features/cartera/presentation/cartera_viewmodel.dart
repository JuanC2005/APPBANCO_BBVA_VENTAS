import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cartera_visita.dart';
import '../data/cartera_repository.dart';

class CarteraState {
  final List<CarteraVisita> visitas;
  final bool isLoading;
  final String? error;
  final String filtroBusqueda;

  const CarteraState({
    this.visitas = const [],
    this.isLoading = false,
    this.error,
    this.filtroBusqueda = '',
  });

  CarteraState copyWith({
    List<CarteraVisita>? visitas,
    bool? isLoading,
    String? error,
    String? filtroBusqueda,
  }) {
    return CarteraState(
      visitas: visitas ?? this.visitas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
    );
  }

  List<CarteraVisita> get visitasFiltradas {
    if (filtroBusqueda.isEmpty) return visitas;
    return visitas.where((v) =>
        v.clienteNombre.toLowerCase().contains(filtroBusqueda.toLowerCase())).toList();
  }

  int get totalVisitas => visitas.length;
  int get visitados => visitas.where((v) => v.resultadoVisita != null).length;
  int get pendientes => visitas.where((v) => v.resultadoVisita == null).length;
}

class CarteraViewModel extends StateNotifier<CarteraState> {
  final CarteraRepository _repository;

  CarteraViewModel(this._repository) : super(const CarteraState());

  Future<void> cargarCartera(String asesorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final visitas = await _repository.obtenerCarteraDiaria(asesorId);
      state = state.copyWith(visitas: visitas, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar cartera: $e');
    }
  }

  void setFiltroBusqueda(String filtro) {
    state = state.copyWith(filtroBusqueda: filtro);
  }

  Future<void> registrarResultado(
      String visitaId, String resultado, String observacion) async {
    final data = {
      'id': visitaId,
      'resultado_visita': resultado,
      'observacion_visita': observacion,
      'timestamp_visita': DateTime.now().toIso8601String(),
    };
    await _repository.registrarResultadoVisita(data);
    final idx = state.visitas.indexWhere((v) => v.id == visitaId);
    if (idx != -1) {
      final updated = state.visitas.toList();
      updated[idx] = CarteraVisita.fromJson({
        ...state.visitas[idx].toJson(),
        ...data,
      });
      state = state.copyWith(visitas: updated);
    }
  }
}

final carteraViewModelProvider =
    StateNotifierProvider<CarteraViewModel, CarteraState>((ref) {
  return CarteraViewModel(ref.watch(carteraRepositoryProvider));
});
