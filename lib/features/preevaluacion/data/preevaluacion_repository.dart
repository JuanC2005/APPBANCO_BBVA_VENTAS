import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../domain/preevaluacion_cliente.dart';

final preevaluacionRepositoryProvider =
    Provider<PreevaluacionRepository>((ref) {
  return PreevaluacionRepository();
});

class PreevaluacionRepository {
  Future<List<PreevaluacionCliente>> obtenerPreevaluaciones(
      String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase.from('vw_cartera_completa').select(
        'cliente_id, cliente_nombre, numero_documento, score_crediticio, '
        'segmento, monto_preaprobado, ingreso_mensual_est, calificacion_sbs')
        .eq('asesor_id', asesorId)
        .order('score_crediticio', ascending: false);
    return (response as List).map((j) => PreevaluacionCliente.fromJson({
      ...j,
      'score': j['score_crediticio'],
      'monto_max_sugerido': j['monto_preaprobado'],
      'recomendacion': ((j['score_crediticio'] as num?)?.toDouble() ?? 0) >= 85
          ? 'aprobado_preaprobado'
          : ((j['score_crediticio'] as num?)?.toDouble() ?? 0) >= 70
              ? 'recomendado'
              : 'evaluar_presencial',
      'ingreso_mensual_est': j['ingreso_mensual_est'],
    })).toList();
  }

  Future<void> recalcularScore(String clienteId) async {
    final supabase = SupabaseClientProvider.client;
    await supabase.rpc('calcular_score_crediticio', params: {
      'p_cliente_id': clienteId,
    });
  }
}
