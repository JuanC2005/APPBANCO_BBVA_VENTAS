import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_monitor.dart';

final transmisionRepositoryProvider = Provider<TransmisionRepository>((ref) {
  return TransmisionRepository(
    ref.watch(networkMonitorProvider),
    ref.watch(apiClientProvider),
  );
});

class TransmisionRepository {
  final NetworkMonitor _networkMonitor;
  final ApiClient _api;

  TransmisionRepository(this._networkMonitor, this._api);

  Future<bool> transmitir(String solicitudId) async {
    if (!_networkMonitor.isOnline) return false;
    try {
      await _api.post('/solicitudes/$solicitudId/enviar', {});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizarEstado(String solicitudId, String estado) async {
    try {
      await _api.put(
        '/solicitudes/$solicitudId/estado',
        {'estado': estado},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
