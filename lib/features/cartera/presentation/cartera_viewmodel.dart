import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cartera_visita.dart';
import '../data/cartera_repository.dart';

class CarteraState {
  final List<CarteraVisita> visitas;
  final bool isLoading;
  final String? error;
  final String filtroBusqueda;
  final String? filtroTipo;
  final String? filtroResultado;

  const CarteraState({
    this.visitas = const [],
    this.isLoading = false,
    this.error,
    this.filtroBusqueda = '',
    this.filtroTipo,
    this.filtroResultado,
  });

  CarteraState copyWith({
    List<CarteraVisita>? visitas,
    bool? isLoading,
    String? error,
    String? filtroBusqueda,
    String? filtroTipo,
    String? filtroResultado,
  }) {
    return CarteraState(
      visitas: visitas ?? this.visitas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
      filtroTipo: filtroTipo ?? this.filtroTipo,
      filtroResultado: filtroResultado ?? this.filtroResultado,
    );
  }

  List<CarteraVisita> get visitasFiltradas {
    var result = visitas;
    if (filtroBusqueda.isNotEmpty) {
      result = result.where((v) =>
          v.clienteNombre.toLowerCase().contains(filtroBusqueda.toLowerCase())).toList();
    }
    if (filtroTipo != null) {
      result = result.where((v) => v.tipoVisita == filtroTipo).toList();
    }
    if (filtroResultado != null) {
      result = result.where((v) => v.resultado == filtroResultado || (v.resultado == null && filtroResultado == 'pendiente')).toList();
    }
    return result;
  }

  int get totalVisitas => visitas.length;
  int get visitados => visitas.where((v) => v.resultado != null).length;
  int get pendientes => visitas.where((v) => v.resultado == null).length;
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
      state = state.copyWith(
          isLoading: false, error: 'Error al cargar cartera: $e');
    }
  }

  void setFiltroBusqueda(String filtro) {
    state = state.copyWith(filtroBusqueda: filtro);
  }

  void setFiltroTipo(String? tipo) {
    state = state.copyWith(filtroTipo: tipo, filtroResultado: null);
  }

  void setFiltroResultado(String? resultado) {
    state = state.copyWith(filtroResultado: resultado, filtroTipo: null);
  }

  Future<void> registrarResultado(
      String visitaId, String resultado, String observacion) async {
    final data = {
      'id': visitaId,
      'resultado': resultado,
      'observacion': observacion,
      'fecha_visita': DateTime.now().toIso8601String(),
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
