import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/score_crediticio.dart';

class ScoringRepository {
  final SupabaseClient _client;

  ScoringRepository(this._client);

  Future<Map<String, dynamic>> evaluarCredito(
      String fichaId, double monto, int plazoMeses) async {
    final response = await _client.rpc('evaluar_credito_campo', params: {
      'p_ficha_id': fichaId,
      'p_monto': monto,
      'p_plazo_meses': plazoMeses,
    });

    return response as Map<String, dynamic>;
  }

  Future<ScoreCrediticio?> getScoreCliente(String userId) async {
    final response = await _client
        .from('scores_crediticios')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ScoreCrediticio.fromMap(response as Map<String, dynamic>);
  }

  Future<List<ScoreCrediticio>> getScoresBySegmento(String segmento) async {
    final response = await _client
        .from('scores_crediticios')
        .select()
        .eq('segmento', segmento)
        .order('score', ascending: false);

    return (response as List)
        .map((item) => ScoreCrediticio.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
