import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../features/cartera/domain/cartera_visita.dart';

class OsrmService {
  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<List<LatLng>>?> fetchRuta(List<CarteraVisita> visitas, {LatLng? origin}) async {
    final coords = StringBuffer();
    if (origin != null) {
      coords.write('${origin.longitude},${origin.latitude};');
    }
    coords.write(visitas.map((v) {
      final lat = v.lat ?? v.latVisita!;
      final lng = v.lng ?? v.lngVisita!;
      return '$lng,$lat';
    }).join(';'));

    final url = Uri.parse('$_baseUrl/${coords.toString()}?geometries=geojson&overview=full&steps=false');
    print('[OSRM] URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('[OSRM] Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('[OSRM] Body: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        print('[OSRM] No routes found: $body');
        return null;
      }

      final geometry = routes[0]['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;
      print('[OSRM] Points received: ${coordinates.length}');

      final polylines = <List<LatLng>>[];
      var startIdx = 0;

      final waypoints = <LatLng>[];
      if (origin != null) waypoints.add(origin);
      for (final v in visitas) {
        waypoints.add(LatLng(v.lat ?? v.latVisita!, v.lng ?? v.lngVisita!));
      }

      for (var i = 0; i < waypoints.length - 1; i++) {
        final targetLat = waypoints[i + 1].latitude;
        final targetLng = waypoints[i + 1].longitude;

        var endIdx = startIdx;
        var minDist = double.infinity;
        for (var j = startIdx; j < coordinates.length; j++) {
          final c = coordinates[j] as List;
          final clat = (c[1] as num).toDouble();
          final clng = (c[0] as num).toDouble();
          final d = (clat - targetLat) * (clat - targetLat) + (clng - targetLng) * (clng - targetLng);
          if (d < minDist) {
            minDist = d;
            endIdx = j;
          }
        }

        final segment = <LatLng>[];
        for (var j = startIdx; j <= endIdx; j++) {
          final c = coordinates[j] as List;
          segment.add(LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()));
        }
        polylines.add(segment);
        startIdx = endIdx;
      }

      print('[OSRM] Waypoints: ${waypoints.length}, Segments: ${polylines.length}');
      return polylines;
    } catch (e) {
      print('[OSRM] Error: $e');
      return null;
    }
  }
}
