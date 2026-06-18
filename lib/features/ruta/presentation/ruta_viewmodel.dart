import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cartera/domain/cartera_visita.dart';
import '../data/ruta_repository.dart';

class RutaState {
  final List<CarteraVisita> visitas;
  final List<CarteraVisita> rutaOptimizada;
  final LatLng? currentPosition;
  final bool isLoading;
  final String? error;

  const RutaState({
    this.visitas = const [],
    this.rutaOptimizada = const [],
    this.currentPosition,
    this.isLoading = false,
    this.error,
  });

  RutaState copyWith({
    List<CarteraVisita>? visitas,
    List<CarteraVisita>? rutaOptimizada,
    LatLng? currentPosition,
    bool? isLoading,
    String? error,
  }) {
    return RutaState(
      visitas: visitas ?? this.visitas,
      rutaOptimizada: rutaOptimizada ?? this.rutaOptimizada,
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RutaViewModel extends StateNotifier<RutaState> {
  final RutaRepository _repository;

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
        final d = _distancia(origen, LatLng(v.lat!, v.lng!));
        if (d < minDist) {
          minDist = d;
          minIdx = i;
        }
      }
      final next = restantes.removeAt(minIdx);
      ruta.add(next);
      origen = LatLng(next.lat!, next.lng!);
    }
    state = state.copyWith(rutaOptimizada: ruta);
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
    if (destino.lat == null || destino.lng == null) return;
    final lat = destino.lat!;
    final lng = destino.lng!;

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
    final destinos =
        state.rutaOptimizada.map((v) => '${v.lat},${v.lng}').join('|');
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${current.latitude},${current.longitude}'
        '&destination=${state.rutaOptimizada.last.lat},'
        '${state.rutaOptimizada.last.lng}'
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
