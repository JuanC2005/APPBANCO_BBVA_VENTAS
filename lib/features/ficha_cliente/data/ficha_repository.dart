import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../domain/cliente.dart';
import '../domain/credito.dart';
import '../domain/preaprobado.dart';

final fichaRepositoryProvider = Provider<FichaRepository>((ref) {
  return FichaRepository();
});

class FichaRepository {
  Future<Cliente?> obtenerCliente(String clienteId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('clientes')
        .select()
        .eq('id', clienteId)
        .single();
    return Cliente.fromJson(response);
  }

  Future<List<Credito>> obtenerCreditos(String clienteId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('creditos')
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha_desembolso', ascending: false);
    return (response as List).map((j) => Credito.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>?> obtenerScore(String clienteId) async {
    try {
      final supabase = SupabaseClientProvider.client;
      final response = await supabase
          .from('scores_crediticios')
          .select()
          .eq('cliente_id', clienteId)
          .single();
      return response;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerMovimientos(String clienteId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('movimientos_mensuales')
        .select()
        .eq('cliente_id', clienteId)
        .order('periodo', ascending: true);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Preaprobado?> obtenerPreaprobado(String clienteId) async {
    try {
      final supabase = SupabaseClientProvider.client;
      final response = await supabase
          .from('creditos_preaprobados')
          .select()
          .eq('cliente_id', clienteId)
          .eq('vigente', true)
          .order('monto_maximo', ascending: false)
          .limit(1)
          .single();
      return Preaprobado.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> obtenerPerfil(String clienteId) async {
    try {
      final supabase = SupabaseClientProvider.client;
      final response = await supabase
          .from('perfiles_clientes')
          .select()
          .eq('cliente_id', clienteId)
          .single();
      return response;
    } catch (_) {
      return null;
    }
  }
}
