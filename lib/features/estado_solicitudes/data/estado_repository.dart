import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../solicitud/domain/solicitud.dart';

final estadoRepositoryProvider = Provider<EstadoRepository>((ref) {
  return EstadoRepository(ref.watch(apiClientProvider));
});

class EstadoRepository {
  final ApiClient _api;

  EstadoRepository(this._api);

  Future<List<SolicitudCredito>> listarPorEstado(
      String asesorId, List<String> estados) async {
    final list = await _api.getList('/solicitudes/');
    return list
        .map((j) => SolicitudCredito.fromJson(j as Map<String, dynamic>))
        .where((s) => estados.contains(s.estado))
        .toList();
  }

  Future<SolicitudCredito?> obtenerPorId(String solicitudId) async {
    final result = await _api.get('/solicitudes/$solicitudId');
    return SolicitudCredito.fromJson(result);
  }
}
