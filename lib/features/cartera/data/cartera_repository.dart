import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../../core/storage/local_db.dart';
import '../../../core/network/network_monitor.dart';
import '../domain/cartera_visita.dart';

final carteraRepositoryProvider = Provider<CarteraRepository>((ref) {
  return CarteraRepository(
    ref.watch(localDbProvider),
    ref.watch(networkMonitorProvider),
  );
});

class CarteraRepository {
  final LocalDatabase _localDb;
  final NetworkMonitor _networkMonitor;

  CarteraRepository(this._localDb, this._networkMonitor);

  Future<List<CarteraVisita>> obtenerCarteraDiaria(String asesorId) async {
    if (_networkMonitor.isOnline) {
      try {
        final supabase = SupabaseClientProvider.client;
        final response = await supabase
            .from('vw_cartera_completa')
            .select()
            .eq('asesor_id', asesorId)
            .order('score_prioridad', ascending: true)
            .timeout(const Duration(seconds: 10));
        final visitas = (response as List).map((j) => CarteraVisita.fromJson(j)).toList();
        await _localDb.cacheCartera(
          visitas.map((v) => v.toJson()).toList(),
        );
        return visitas;
      } catch (_) {}
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
        final supabase = SupabaseClientProvider.client;
        await supabase.from('cartera_diaria').upsert(data);
        await _localDb.marcarSincronizada(data['id']);
      } catch (_) {}
    }
  }

  Future<void> syncPending() async {
    if (!_networkMonitor.isOnline) return;
    final pendientes = await _localDb.obtenerVisitasPendientes();
    for (final data in pendientes) {
      try {
        final supabase = SupabaseClientProvider.client;
        await supabase.from('cartera_diaria').upsert(data);
        await _localDb.marcarSincronizada(data['id']);
      } catch (_) {}
    }
  }

  Future<List<CarteraVisita>> obtenerVisitados(String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('cartera_diaria')
        .select()
        .eq('asesor_id', asesorId)
        .not('resultado_visita', 'is', null)
        .order('timestamp_visita', ascending: false);
    return (response as List).map((j) => CarteraVisita.fromJson(j)).toList();
  }
}
