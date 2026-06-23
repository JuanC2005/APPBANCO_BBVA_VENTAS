import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final comiteRepositoryProvider = Provider<ComiteRepository>((ref) {
  return ComiteRepository(ref.watch(apiClientProvider));
});

class ComiteRepository {
  final ApiClient _api;
  ComiteRepository(this._api);

  Future<List<dynamic>> listarPendientes() async {
    return await _api.getList('/comite/pendientes');
  }

  Future<Map<String, dynamic>> obtenerDetalle(String solicitudId) async {
    return await _api.get('/comite/solicitud/$solicitudId');
  }

  Future<Map<String, dynamic>> evaluar(String solicitudId, Map<String, dynamic> data) async {
    return await _api.put('/comite/$solicitudId/evaluar', data);
  }

  Future<Map<String, dynamic>> decidir(String solicitudId, Map<String, dynamic> data) async {
    return await _api.put('/comite/$solicitudId/decidir', data);
  }
}
