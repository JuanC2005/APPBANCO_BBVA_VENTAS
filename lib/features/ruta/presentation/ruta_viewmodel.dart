import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/osrm_service.dart';
import '../../cartera/domain/cartera_visita.dart';
import '../data/ruta_repository.dart';

class RutaState {
  final List<CarteraVisita> visitas;
  final List<CarteraVisita> rutaOptimizada;
  final LatLng? currentPosition;
  final bool isLoading;
  final bool isLoadingRuta;
  final String? error;
  final List<List<LatLng>> polylines;

  const RutaState({
    this.visitas = const [],
    this.rutaOptimizada = const [],
    this.currentPosition,
    this.isLoading = false,
    this.isLoadingRuta = false,
    this.error,
    this.polylines = const [],
  });

  RutaState copyWith({
    List<CarteraVisita>? visitas,
    List<CarteraVisita>? rutaOptimizada,
    LatLng? currentPosition,
    bool? isLoading,
    bool? isLoadingRuta,
    String? error,
    List<List<LatLng>>? polylines,
  }) {
    return RutaState(
      visitas: visitas ?? this.visitas,
      rutaOptimizada: rutaOptimizada ?? this.rutaOptimizada,
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      isLoadingRuta: isLoadingRuta ?? this.isLoadingRuta,
      error: error,
      polylines: polylines ?? this.polylines,
    );
  }
}

class RutaViewModel extends StateNotifier<RutaState> {
  final RutaRepository _repository;
  final OsrmService _osrmService = OsrmService();
  int _rutaGeneration = 0;

  RutaViewModel(this._repository) : super(const RutaState());

  Future<void> cargarRuta(String asesorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final visitas = await _repository.obtenerVisitasRuta(asesorId);
      state = state.copyWith(visitas: visitas, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Error al cargar ruta: $e');
    }
  }

  void optimizarRuta() {
    final current = state.currentPosition;
    if (current == null || state.visitas.isEmpty) {
      state = state.copyWith(rutaOptimizada: state.visitas);
      _fetchRuta();
      return;
    }
    final restantes = state.visitas.toList();
    final ruta = <CarteraVisita>[];
    var origen = LatLng(current.latitude, current.longitude);

    while (restantes.isNotEmpty) {
      var minDist = double.infinity;
      var minIdx = 0;
      for (var i = 0; i < restantes.length; i++) {
        final v = restantes[i];
        final d = _distancia(origen, LatLng(v.lat ?? v.latVisita!, v.lng ?? v.lngVisita!));
        if (d < minDist) {
          minDist = d;
          minIdx = i;
        }
      }
      final next = restantes.removeAt(minIdx);
      ruta.add(next);
      origen = LatLng(next.lat ?? next.latVisita!, next.lng ?? next.lngVisita!);
    }
    state = state.copyWith(rutaOptimizada: ruta);
    _fetchRuta();
  }

  Future<void> _fetchRuta() async {
    final ruta = state.rutaOptimizada;
    final origin = state.currentPosition;
    if (ruta.isEmpty) return;
    if (ruta.length < 2 && origin == null) return;
    final gen = ++_rutaGeneration;
    state = state.copyWith(isLoadingRuta: true);
    final polylines = await _osrmService.fetchRuta(ruta, origin: origin);
    if (gen != _rutaGeneration) return;
    state = state.copyWith(
      polylines: polylines ?? [],
      isLoadingRuta: false,
    );
  }

  double _distancia(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return dx * dx + dy * dy;
  }

  void setCurrentPosition(LatLng pos) {
    state = state.copyWith(currentPosition: pos);
  }

  Future<void> abrirNavegacion(CarteraVisita destino) async {
    final lat = destino.lat ?? destino.latVisita;
    final lng = destino.lng ?? destino.lngVisita;
    if (lat == null || lng == null) return;

    final googleUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'
        '&travelmode=driving');
    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      return;
    }
    final wazeUri =
        Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=true');
    if (await canLaunchUrl(wazeUri)) {
      await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> abrirNavegacionCompleta() async {
    if (state.rutaOptimizada.isEmpty) return;
    final current = state.currentPosition;
    if (current == null) {
      await abrirNavegacion(state.rutaOptimizada.first);
      return;
    }
    final destinos = state.rutaOptimizada.map((v) {
      final lat = v.lat ?? v.latVisita;
      final lng = v.lng ?? v.lngVisita;
      return '$lat,$lng';
    }).join('|');
    final last = state.rutaOptimizada.last;
    final lastLat = last.lat ?? last.latVisita;
    final lastLng = last.lng ?? last.lngVisita;
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${current.latitude},${current.longitude}'
        '&destination=$lastLat,$lastLng'
        '&waypoints=$destinos'
        '&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

final rutaViewModelProvider =
    StateNotifierProvider<RutaViewModel, RutaState>((ref) {
  return RutaViewModel(ref.watch(rutaRepositoryProvider));
});
