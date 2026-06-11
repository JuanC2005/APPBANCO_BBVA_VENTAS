import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../../core/storage/local_db.dart';
import '../domain/cartera_visita.dart';

final carteraRepositoryProvider = Provider<CarteraRepository>((ref) {
  return CarteraRepository(ref.watch(localDbProvider));
});

class CarteraRepository {
  final LocalDatabase _localDb;

  CarteraRepository(this._localDb);

  Future<List<CarteraVisita>> obtenerCarteraDiaria(String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('vw_cartera_completa')
        .select()
        .eq('asesor_id', asesorId)
        .order('prioridad', ascending: true);
    return (response as List).map((j) => CarteraVisita.fromJson(j)).toList();
  }

  Future<void> registrarResultadoVisita(Map<String, dynamic> data) async {
    await _localDb.guardarVisitaPendiente(data);
    final supabase = SupabaseClientProvider.client;
    try {
      await supabase.from('cartera_diaria').upsert(data);
      await _localDb.marcarSincronizada(data['id']);
    } catch (_) {}
  }

  Future<List<CarteraVisita>> obtenerVisitados(String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('cartera_diaria')
        .select()
        .eq('asesor_id', asesorId)
        .not('resultado', 'neq', 'null')
        .order('fecha_visita', ascending: false);
    return (response as List).map((j) => CarteraVisita.fromJson(j)).toList();
  }
}
