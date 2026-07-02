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
  final _mapController = MapController();

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

    if (asesor != null) {
      await vm.cargarRuta(asesor.id);
    }

    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación denegada permanentemente. Actívala en Ajustes de tu dispositivo.'),
          ),
        );
      }
    } else {
      try {
        final pos = await Geolocator.getCurrentPosition();
        vm.setCurrentPosition(LatLng(pos.latitude, pos.longitude));
      } catch (_) {}
    }

    vm.optimizarRuta();
    if (!mounted) return;
    _animateToFit();
  }

  void _animateToFit() {
    if (!mounted) return;
    final state = ref.read(rutaViewModelProvider);
    if (state.rutaOptimizada.isEmpty && state.currentPosition == null) return;

    final bounds = _calculateBounds(state);
    if (bounds != null) {
      _mapController.fitCamera(
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
    if (state.rutaOptimizada.isEmpty) return [];
    final hasGps = state.currentPosition != null;
    if (state.rutaOptimizada.length < 2 && !hasGps) return [];

    if (state.polylines.isNotEmpty) {
      return state.polylines.asMap().entries.map((e) {
        final t = state.polylines.length > 1
            ? e.key / (state.polylines.length - 1)
            : 1.0;
        return Polyline(
          points: e.value,
          color: Color.lerp(const Color(0xFF1565C0), const Color(0xFF2E7D32), t)!,
          strokeWidth: 5,
        );
      }).toList();
    }

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
          if (state.isLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.isLoadingRuta)
            const Positioned(
              top: 64,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 8),
                        Text('Calculando ruta...', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
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
          if (state.rutaOptimizada.isNotEmpty && !state.isLoadingRuta)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  color: state.polylines.isNotEmpty
                      ? Color(0xFF1B5E20)
                      : Color(0xFFE65100),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      state.polylines.isNotEmpty
                          ? 'Ruta OSRM: ${state.polylines.length} segmentos'
                          : 'Fallback: línea recta',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          _buildBottomSheet(state, vm),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () async {
          try {
            final pos = await Geolocator.getCurrentPosition();
            _mapController.move(
                LatLng(pos.latitude, pos.longitude), 15);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo obtener ubicación. Verifica que el GPS esté activado.')),
              );
            }
          }
        },
        child: const Icon(Icons.my_location),
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
                    final lat = v.lat ?? v.latVisita;
                    final lng = v.lng ?? v.lngVisita;
                    if (lat != null && lng != null) {
                      _mapController.move(LatLng(lat, lng), 16);
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
