import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_db.dart';
import '../../../core/network/network_monitor.dart';
import '../domain/cartera_visita.dart';

final carteraRepositoryProvider = Provider<CarteraRepository>((ref) {
  return CarteraRepository(
    ref.watch(localDbProvider),
    ref.watch(networkMonitorProvider),
    ref.watch(apiClientProvider),
  );
});

class CarteraRepository {
  final LocalDatabase _localDb;
  final NetworkMonitor _networkMonitor;
  final ApiClient _api;

  CarteraRepository(this._localDb, this._networkMonitor, this._api);

  Future<List<CarteraVisita>> obtenerCarteraDiaria(String asesorId) async {
    if (_networkMonitor.isOnline) {
      try {
        final list = await _api.getList('/cartera/completa');
        final visitas = list
            .map((j) => CarteraVisita.fromJson(j as Map<String, dynamic>))
            .toList();
        await _localDb.cacheCartera(
          visitas.map((v) => v.toJson()).toList(),
        );
        return visitas;
      } catch (e) {
        print('CarteraRepository.obtenerCarteraDiaria: error remoto: $e');
      }
    }
    final cache = await _localDb.obtenerCarteraCache();
    final rows = cache.map((r) {
      try {
        final json = jsonDecode(r['datos_json'] as String);
        return CarteraVisita.fromJson(json as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<CarteraVisita>().toList();
    return rows.where((v) => v.asesorId == asesorId).toList();
  }

  Future<void> registrarResultadoVisita(Map<String, dynamic> data) async {
    await _localDb.guardarVisitaPendiente(data);
    if (_networkMonitor.isOnline) {
      try {
        final visitaId = data['cartera_id'] ?? data['id'];
        await _api.put('/cartera/$visitaId/visita', {
          'resultado_visita': data['resultado'],
          'observacion_visita': data['observacion'],
          'lat_visita': data['lat'],
          'lng_visita': data['lng'],
        });
        await _localDb.marcarSincronizada(data['id']);
      } catch (_) {}
    }
  }

  Future<void> syncPending() async {
    if (!_networkMonitor.isOnline) return;
    final pendientes = await _localDb.obtenerVisitasPendientes();
    for (final data in pendientes) {
      try {
        final visitaId = data['cartera_id'] ?? data['id'];
        await _api.put('/cartera/$visitaId/visita', {
          'resultado_visita': data['resultado'],
          'observacion_visita': data['observacion'],
          'lat_visita': data['lat'],
          'lng_visita': data['lng'],
        });
        await _localDb.marcarSincronizada(data['id']);
      } catch (_) {}
    }
  }

  Future<List<CarteraVisita>> obtenerVisitados(String asesorId) async {
    final list = await _api.getList('/cartera/completa');
    return list
        .map((j) => CarteraVisita.fromJson(j as Map<String, dynamic>))
        .where((v) => v.resultadoVisita != null)
        .toList()
      ..sort((a, b) {
        final ta = a.timestampVisita ?? DateTime(2000);
        final tb = b.timestampVisita ?? DateTime(2000);
        return tb.compareTo(ta);
      });
  }
}
