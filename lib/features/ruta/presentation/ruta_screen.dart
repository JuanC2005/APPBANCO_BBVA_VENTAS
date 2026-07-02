import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../../cartera/domain/cartera_visita.dart';
import 'ruta_viewmodel.dart';

class RutaScreen extends ConsumerStatefulWidget {
  const RutaScreen({super.key});

  @override
  ConsumerState<RutaScreen> createState() => _RutaScreenState();
}

class _RutaScreenState extends ConsumerState<RutaScreen> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndLoad();
    });
  }

  Future<void> _initLocationAndLoad() async {
    final asesor = ref.read(authViewModelProvider).asesor;
    final vm = ref.read(rutaViewModelProvider.notifier);

    try {
      final pos = await Geolocator.getCurrentPosition();
      vm.setCurrentPosition(LatLng(pos.latitude, pos.longitude));
      if (asesor != null) {
        await vm.cargarRuta(asesor.id);
        vm.optimizarRuta();
      }
      _animateToFit();
    } catch (_) {}
  }

  void _animateToFit() {
    final state = ref.read(rutaViewModelProvider);
    if (state.rutaOptimizada.isEmpty && state.currentPosition == null) return;

    final bounds = _calculateBounds(state);
    if (bounds != null) {
      _mapController?.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(64),
        ),
      );
    }
  }

  LatLngBounds? _calculateBounds(RutaState state) {
    double? minLat, maxLat, minLng, maxLng;

    void addPoint(double lat, double lng) {
      minLat = minLat == null ? lat : lat < minLat! ? lat : minLat;
      maxLat = maxLat == null ? lat : lat > maxLat! ? lat : maxLat;
      minLng = minLng == null ? lng : lng < minLng! ? lng : minLng;
      maxLng = maxLng == null ? lng : lng > maxLng! ? lng : maxLng;
    }

    if (state.currentPosition != null) {
      addPoint(
          state.currentPosition!.latitude, state.currentPosition!.longitude);
    }
    for (final v in state.rutaOptimizada) {
      if (v.lat != null && v.lng != null || v.latVisita != null && v.lngVisita != null) {
        addPoint(v.lat ?? v.latVisita!, v.lng ?? v.lngVisita!);
      }
    }
    if (minLat == null) return null;
    return LatLngBounds(
      LatLng(minLat!, minLng!),
      LatLng(maxLat!, maxLng!),
    );
  }

  List<Marker> _buildMarkers(RutaState state) {
    final markers = <Marker>[];
    if (state.currentPosition != null) {
      markers.add(Marker(
        point: state.currentPosition!,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
      ));
    }
    for (var i = 0; i < state.rutaOptimizada.length; i++) {
      final v = state.rutaOptimizada[i];
      if (v.lat == null && v.latVisita == null || v.lng == null && v.lngVisita == null) continue;
      markers.add(Marker(
        point: LatLng(v.lat ?? v.latVisita!, v.lng ?? v.lngVisita!),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text('${i + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ));
    }
    return markers;
  }

  List<Polyline> _buildPolylines(RutaState state) {
    if (state.rutaOptimizada.length < 2) return [];
    final points = <LatLng>[];
    if (state.currentPosition != null) {
      points.add(state.currentPosition!);
    }
    for (final v in state.rutaOptimizada) {
      if (v.lat != null && v.lng != null || v.latVisita != null && v.lngVisita != null) {
        points.add(LatLng(v.lat ?? v.latVisita!, v.lng ?? v.lngVisita!));
      }
    }
    return [
      Polyline(
        points: points,
        color: BBVAColors.primaryBlue,
        strokeWidth: 4,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rutaViewModelProvider);
    final vm = ref.read(rutaViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta de Visitas'),
        actions: [
          if (state.rutaOptimizada.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.navigation),
              tooltip: 'Navegar ruta completa',
              onPressed: () => vm.abrirNavegacionCompleta(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initLocationAndLoad,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-12.046374, -77.042793),
              initialZoom: 12,
              onMapReady: () => _animateToFit(),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.appbanco_bbva_ventas',
              ),
              MarkerLayer(markers: _buildMarkers(state)),
              PolylineLayer(polylines: _buildPolylines(state)),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: () async {
                try {
                  final pos = await Geolocator.getCurrentPosition();
                  _mapController?.move(
                      LatLng(pos.latitude, pos.longitude), 15);
                } catch (_) {}
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          if (state.isLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: BBVAColors.errorRed,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(state.error!,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          if (state.visitas.isEmpty && !state.isLoading && state.error == null)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay visitas pendientes con ubicación'),
                  ),
                ),
              ),
            ),
          _buildBottomSheet(state, vm),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(RutaState state, RutaViewModel _) {
    final paradas = state.rutaOptimizada;
    if (paradas.isEmpty) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('${paradas.length} paradas',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.route, size: 18),
                    label: const Text('Optimizar'),
                    onPressed: () {
                      ref
                          .read(rutaViewModelProvider.notifier)
                          .optimizarRuta();
                      _animateToFit();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: paradas.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _ParadaTile(
                  index: i,
                  visita: paradas[i],
                  onNavigate: () =>
                      ref.read(rutaViewModelProvider.notifier).abrirNavegacion(paradas[i]),
                  onTap: () {
                    final v = paradas[i];
                    if (v.lat != null && v.lng != null || v.latVisita != null && v.lngVisita != null) {
                      _mapController?.move(
                          LatLng(v.lat!, v.lng!), 16);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParadaTile extends StatelessWidget {
  final int index;
  final CarteraVisita visita;
  final VoidCallback onNavigate;
  final VoidCallback onTap;

  const _ParadaTile({
    required this.index,
    required this.visita,
    required this.onNavigate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: BBVAColors.primaryBlue.withAlpha(25),
        child: Text('${index + 1}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: BBVAColors.primaryBlue)),
      ),
      title: Text(visita.clienteNombre,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        visita.direccion ?? visita.tipoGestion,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tag(visita.prioridadLabel),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.directions, color: BBVAColors.primaryBlue),
            onPressed: onNavigate,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _tag(String label) {
    Color color;
    switch (label) {
      case 'ALTA':
        color = BBVAColors.tagNueva;
        break;
      case 'MEDIA':
        color = BBVAColors.tagAmpliacion;
        break;
      default:
        color = BBVAColors.tagSeguimiento;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
