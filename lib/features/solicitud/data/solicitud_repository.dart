import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_db.dart';
import '../../../core/network/network_monitor.dart';
import '../domain/solicitud.dart';

final solicitudRepositoryProvider = Provider<SolicitudRepository>((ref) {
  return SolicitudRepository(
    ref.watch(localDbProvider),
    ref.watch(networkMonitorProvider),
    ref.watch(apiClientProvider),
  );
});

class SolicitudRepository {
  final LocalDatabase _localDb;
  final NetworkMonitor _networkMonitor;
  final ApiClient _api;

  SolicitudRepository(this._localDb, this._networkMonitor, this._api);

  Future<SolicitudCredito> crearBorrador({
    required String asesorId,
    required String clienteId,
    required String? agenciaId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final borrador = SolicitudCredito(
      id: id,
      asesorId: asesorId,
      clienteId: clienteId,
      agenciaId: agenciaId,
      estado: 'borrador',
    );
    await _localDb.guardarBorrador(borrador.toJson());
    return borrador;
  }

  Future<void> guardarPaso(String solicitudId, Map<String, dynamic> datos) async {
    final existing = await _localDb.obtenerBorrador(solicitudId);
    if (existing != null) {
      existing.addAll(datos);
      existing['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      await _localDb.guardarBorrador(existing);
    }
  }

  Future<SolicitudCredito?> cargarBorrador(String solicitudId) async {
    final data = await _localDb.obtenerBorrador(solicitudId);
    if (data == null) return null;
    return SolicitudCredito.fromJson(data);
  }

  Future<void> eliminarBorrador(String solicitudId) async {
    await _localDb.eliminarBorrador(solicitudId);
  }

  Future<List<SolicitudCredito>> listarBorradores(String asesorId) async {
    final rows = await _localDb.obtenerBorradores(asesorId);
    return rows.map((r) => SolicitudCredito.fromJson(r)).toList();
  }

  Future<void> enviarSolicitud(SolicitudCredito solicitud) async {
    final data = solicitud.toJson();
    data.remove('id');
    data['estado'] = 'enviado';
    data['pendiente_sync'] = false;

    await _api.post('/solicitudes/', data);
    await _localDb.eliminarBorrador(solicitud.id);
  }

  Future<List<SolicitudCredito>> listarEnviadas(String asesorId) async {
    final list = await _api.getList('/solicitudes/');
    return list
        .map((j) => SolicitudCredito.fromJson(j as Map<String, dynamic>))
        .where((s) => s.estado != 'borrador')
        .toList();
  }

  Future<void> syncPendientes() async {
    if (!_networkMonitor.isOnline) return;
    final borradores = await _localDb.obtenerBorradores('', pendientesSync: true);
    for (final b in borradores) {
      try {
        final solicitud = SolicitudCredito.fromJson(b);
        await enviarSolicitud(solicitud);
      } catch (_) {}
    }
  }
}
