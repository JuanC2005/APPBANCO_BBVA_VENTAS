import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/campana.dart';
import '../data/campana_repository.dart';

class CampanasState {
  final List<Campana> campanas;
  final bool isLoading;
  final String? error;
  final String filtroTipo;

  const CampanasState({
    this.campanas = const [],
    this.isLoading = false,
    this.error,
    this.filtroTipo = 'TODOS',
  });

  CampanasState copyWith({
    List<Campana>? campanas,
    bool? isLoading,
    String? error,
    String? filtroTipo,
  }) {
    return CampanasState(
      campanas: campanas ?? this.campanas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filtroTipo: filtroTipo ?? this.filtroTipo,
    );
  }

  List<Campana> get filtradas {
    if (filtroTipo == 'TODOS') return campanas;
    return campanas.where((c) => c.tipo == filtroTipo).toList();
  }

  int get noLeidas => campanas.where((c) => !c.leida).length;
}

class CampanasViewModel extends StateNotifier<CampanasState> {
  final CampanaRepository _repository;

  CampanasViewModel(this._repository) : super(const CampanasState());

  Future<void> cargarActivas(String asesorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final campanas = await _repository.obtenerCampanasActivas(asesorId);
      state = state.copyWith(campanas: campanas, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: 'Error al cargar: $e');
    }
  }

  Future<void> cargarTodas() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final campanas = await _repository.obtenerTodasCampanas();
      state = state.copyWith(campanas: campanas, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: 'Error al cargar: $e');
    }
  }

  void setFiltroTipo(String t) {
    state = state.copyWith(filtroTipo: t);
  }

  Future<void> crearCampana(Campana campana, String creadoPorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.crearCampana(campana, creadoPorId);
      await cargarTodas();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<void> marcarLeida(String campanaId, String asesorId) async {
    await _repository.marcarLeida(campanaId, asesorId);
    final idx = state.campanas.indexWhere((c) => c.id == campanaId);
    if (idx != -1) {
      final list = state.campanas.toList();
      list[idx] = Campana(
        id: list[idx].id,
        titulo: list[idx].titulo,
        mensaje: list[idx].mensaje,
        tipo: list[idx].tipo,
        segmentoObjetivo: list[idx].segmentoObjetivo,
        productoSugerido: list[idx].productoSugerido,
        fechaInicio: list[idx].fechaInicio,
        fechaFin: list[idx].fechaFin,
        activa: list[idx].activa,
        leida: true,
        createdAt: list[idx].createdAt,
      );
      state = state.copyWith(campanas: list);
    }
  }

  Future<void> toggleActiva(String campanaId, bool activa) async {
    await _repository.toggleActiva(campanaId, activa);
    final idx = state.campanas.indexWhere((c) => c.id == campanaId);
    if (idx != -1) {
      final list = state.campanas.toList();
      list[idx] = Campana(
        id: list[idx].id,
        titulo: list[idx].titulo,
        mensaje: list[idx].mensaje,
        tipo: list[idx].tipo,
        segmentoObjetivo: list[idx].segmentoObjetivo,
        productoSugerido: list[idx].productoSugerido,
        fechaInicio: list[idx].fechaInicio,
        fechaFin: list[idx].fechaFin,
        activa: activa,
        leida: list[idx].leida,
        createdAt: list[idx].createdAt,
      );
      state = state.copyWith(campanas: list);
    }
  }
}

final campanasViewModelProvider =
    StateNotifierProvider<CampanasViewModel, CampanasState>((ref) {
  return CampanasViewModel(ref.watch(campanaRepositoryProvider));
});
