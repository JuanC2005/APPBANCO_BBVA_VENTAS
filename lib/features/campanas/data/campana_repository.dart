import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../domain/campana.dart';

final campanaRepositoryProvider = Provider<CampanaRepository>((ref) {
  return CampanaRepository();
});

class CampanaRepository {
  Future<List<Campana>> obtenerCampanasActivas(String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('vw_campanas_activas_asesor')
        .select()
        .eq('asesor_id', asesorId)
        .order('created_at', ascending: false);
    return (response as List).map((j) => Campana.fromJson(j)).toList();
  }

  Future<List<Campana>> obtenerTodasCampanas() async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('campanas')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((j) => Campana.fromJson(j)).toList();
  }

  Future<void> crearCampana(Campana campana, String creadoPorId) async {
    final supabase = SupabaseClientProvider.client;
    final data = campana.toJson();
    data['creado_por'] = creadoPorId;
    await supabase.from('campanas').insert(data);
  }

  Future<void> marcarLeida(String campanaId, String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    await supabase.from('campanas_asesores').upsert({
      'campana_id': campanaId,
      'asesor_id': asesorId,
      'leida': true,
      'leida_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> asignarCampana(String campanaId) async {
    final supabase = SupabaseClientProvider.client;
    final result =
        await supabase.rpc('asignar_campana_asesores', params: {
      'p_campana_id': campanaId,
    });
    return (result as num?)?.toInt() ?? 0;
  }

  Future<void> toggleActiva(String campanaId, bool activa) async {
    final supabase = SupabaseClientProvider.client;
    await supabase
        .from('campanas')
        .update({'activa': activa, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', campanaId);
  }
}
