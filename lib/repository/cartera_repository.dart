import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/ficha_campo.dart';

class CarteraRepository {
  final SupabaseClient _client;

  CarteraRepository(this._client);

  Future<List<FichaCampo>> getFichasPorEjecutivo(String ejecutivoUserId) async {
    final response = await _client
        .from('fichas_campo')
        .select()
        .eq('ejecutivo_id', ejecutivoUserId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => FichaCampo.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FichaCampo>> getFichasPendientesSync() async {
    final response = await _client
        .from('fichas_campo')
        .select()
        .eq('creada_offline', true)
        .is_('sincronizada_at', null)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => FichaCampo.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearFicha(Map<String, dynamic> data) async {
    await _client.from('fichas_campo').insert(data);
  }

  Future<void> sincronizarFicha(String fichaId) async {
    await _client
        .from('fichas_campo')
        .update({'sincronizada_at': DateTime.now().toIso8601String()})
        .eq('id', fichaId);
  }
}
