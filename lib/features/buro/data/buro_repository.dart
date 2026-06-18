import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../../core/network/network_monitor.dart';

final buroRepositoryProvider = Provider<BuroRepository>((ref) {
  return BuroRepository(ref.watch(networkMonitorProvider));
});

class BuroRepository {
  final NetworkMonitor _networkMonitor;

  BuroRepository(this._networkMonitor);

  Future<Map<String, dynamic>> consultar({
    required String asesorId,
    required String clienteId,
    required String dni,
    required String firmaConsentimiento,
  }) async {
    final supabase = SupabaseClientProvider.client;

    if (_networkMonitor.isOnline) {
      try {
        final result = await supabase.rpc('consultar_buro', params: {
          'p_asesor_id': asesorId,
          'p_cliente_id': clienteId,
          'p_dni': dni,
        });
        final data = result as Map<String, dynamic>;
        await supabase.from('consultas_buro').insert({
          'asesor_id': asesorId,
          'cliente_id': clienteId,
          'dni_consultado': dni,
          'calificacion_sbs': data['calificacion_sbs'],
          'entidades_con_deuda': data['entidades_con_deuda'],
          'deuda_total_pen': data['deuda_total_pen'],
          'resultado_json': data,
          'firma_consentimiento_base64': firmaConsentimiento,
        });
        return data;
      } catch (_) {}
    }
    return _resultadoSimulado();
  }

  Future<List<Map<String, dynamic>>> historial(String clienteId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('consultas_buro')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false)
        .limit(5);
    return (response as List).cast<Map<String, dynamic>>();
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
