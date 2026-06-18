import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../solicitud/domain/solicitud.dart';

final estadoRepositoryProvider = Provider<EstadoRepository>((ref) {
  return EstadoRepository();
});

class EstadoRepository {

  Future<List<SolicitudCredito>> listarPorEstado(
      String asesorId, List<String> estados) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('solicitudes_credito')
        .select()
        .eq('asesor_id', asesorId)
        .inFilter('estado', estados)
        .order('created_at', ascending: false);
    return (response as List).map((j) => SolicitudCredito.fromJson(j)).toList();
  }

  Future<SolicitudCredito?> obtenerPorId(String solicitudId) async {
    try {
      final supabase = SupabaseClientProvider.client;
      final response = await supabase
          .from('solicitudes_credito')
          .select()
          .eq('id', solicitudId)
          .single();
      return SolicitudCredito.fromJson(response);
    } catch (_) {
      return null;
    }
  }
}
