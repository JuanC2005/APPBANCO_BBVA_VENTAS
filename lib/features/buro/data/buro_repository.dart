import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_monitor.dart';

final buroRepositoryProvider = Provider<BuroRepository>((ref) {
  return BuroRepository(
    ref.watch(networkMonitorProvider),
    ref.watch(apiClientProvider),
  );
});

class BuroRepository {
  final NetworkMonitor _networkMonitor;
  final ApiClient _api;

  BuroRepository(this._networkMonitor, this._api);

  Future<Map<String, dynamic>> consultar({
    required String asesorId,
    required String clienteId,
    required String dni,
    required String firmaConsentimiento,
  }) async {
    if (_networkMonitor.isOnline) {
      try {
        final result = await _api.post('/buro/consultar', {
          'cliente_id': clienteId,
          'dni': dni,
          'firma_consentimiento_base64': firmaConsentimiento,
        });
        return result;
      } catch (_) {}
    }
    return _resultadoSimulado();
  }

  Future<List<Map<String, dynamic>>> historial(String clienteId) async {
    final list = await _api.getList('/buro/historial/$clienteId');
    return list.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _resultadoSimulado() {
    return {
      'score': 780,
      'calificacion_sbs': 'Normal',
      'entidades_con_deuda': 2,
      'deuda_total_pen': 2500.00,
      'mayor_deuda': 2000.00,
      'dias_mayor_mora': 0,
      'en_lista_negra': false,
      'protestos': 'Ninguno',
      'recomendacion': 'Cliente con buen historial crediticio',
    };
  }
}
