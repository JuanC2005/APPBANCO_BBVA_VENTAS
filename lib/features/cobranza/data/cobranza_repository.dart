import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../domain/cliente_mora.dart';

final cobranzaRepositoryProvider = Provider<CobranzaRepository>((ref) {
  return CobranzaRepository();
});

class CobranzaRepository {

  Future<List<ClienteMora>> listarMora(String asesorId) async {
    final supabase = SupabaseClientProvider.client;
    final creditos = await supabase
        .from('creditos')
        .select('*, clientes!inner(*)')
        .eq('asesor_id', asesorId)
        .inFilter('estado', ['vencido', 'castigado'])
        .order('fecha_vencimiento', ascending: true);
    return (creditos as List).map((cr) {
      final cl = cr['clientes'] as Map<String, dynamic>? ?? {};
      final hoy = DateTime.now();
      final venc = cr['fecha_vencimiento'] != null
          ? DateTime.tryParse(cr['fecha_vencimiento'])
          : null;
      final diasMora = venc != null
          ? hoy.difference(venc).inDays
          : 0;
      return ClienteMora(
        clienteId: cr['cliente_id'] ?? '',
        clienteNombre: '${cl['nombres'] ?? ''} ${cl['apellidos'] ?? ''}',
        numeroDocumento: cl['numero_documento'],
        creditoId: cr['id'] ?? '',
        deuda: (cr['saldo_actual'] as num?)?.toDouble() ?? 0,
        diasMora: diasMora > 0 ? diasMora : 0,
        direccion: cl['direccion'],
        lat: (cl['lat'] as num?)?.toDouble(),
        lng: (cl['lng'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<void> registrarAccion({
    required String asesorId,
    required String clienteId,
    required String? creditoId,
    required String tipoGestion,
    required String resultado,
    required String observaciones,
    double? montoPagado,
    double? montoComprometido,
    DateTime? fechaCompromiso,
    double? lat,
    double? lng,
  }) async {
    final supabase = SupabaseClientProvider.client;
    await supabase.from('acciones_cobranza').insert({
      'asesor_id': asesorId,
      'cliente_id': clienteId,
      'credito_id': creditoId,
      'tipo_gestion': tipoGestion,
      'resultado': resultado,
      'monto_pagado': montoPagado ?? 0,
      'monto_comprometido': montoComprometido ?? 0,
      'fecha_compromiso': fechaCompromiso?.toIso8601String(),
      'observaciones': observaciones,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<List<Map<String, dynamic>>> historialAcciones(String clienteId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('acciones_cobranza')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false)
        .limit(10);
    return (response as List).cast<Map<String, dynamic>>();
  }
}
