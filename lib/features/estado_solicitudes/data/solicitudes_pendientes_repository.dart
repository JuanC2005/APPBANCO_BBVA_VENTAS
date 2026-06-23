import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../solicitud/domain/solicitud.dart';

final solicitudesPendientesRepositoryProvider = Provider<SolicitudesPendientesRepository>((ref) {
  return SolicitudesPendientesRepository(ref.watch(apiClientProvider));
});

class SolicitudesPendientesRepository {
  final ApiClient _api;
  SolicitudesPendientesRepository(this._api);

  Future<List<SolicitudCredito>> listarPendientes() async {
    final list = await _api.getList('/solicitudes/pendientes');
    return list.map((j) => SolicitudCredito.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> tomarSolicitud(String solicitudId) async {
    return await _api.put('/solicitudes/$solicitudId/tomar', {});
  }
}
