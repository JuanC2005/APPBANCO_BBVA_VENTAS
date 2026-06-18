import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/preevaluacion_cliente.dart';

final preevaluacionRepositoryProvider =
    Provider<PreevaluacionRepository>((ref) {
  return PreevaluacionRepository(ref.watch(apiClientProvider));
});

class PreevaluacionRepository {
  final ApiClient _api;

  PreevaluacionRepository(this._api);

  Future<List<PreevaluacionCliente>> obtenerPreevaluaciones(
      String asesorId) async {
    final list = await _api.getList('/cartera/completa');
    return list
        .map((j) {
          final m = j as Map<String, dynamic>;
          final score = (m['score_crediticio'] as num?)?.toDouble() ?? 0;
          return PreevaluacionCliente(
            clienteId: m['cliente_id'] ?? '',
            clienteNombre: m['cliente_nombre'] ?? '',
            numeroDocumento: m['numero_documento'],
            score: score,
            segmento: m['segmento'] ?? 'C',
            montoMaxSugerido: (m['monto_preaprobado'] as num?)?.toDouble(),
            recomendacion: score >= 85
                ? 'aprobado_preaprobado'
                : score >= 70
                    ? 'recomendado'
                    : 'evaluar_presencial',
            ingresoMensual: (m['ingreso_mensual_est'] as num?)?.toDouble(),
            calificacionSbs: m['calificacion_sbs'],
          );
        })
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  Future<void> recalcularScore(String clienteId) async {
    throw UnimplementedError('Usar el backend para recalcular score');
  }
}
