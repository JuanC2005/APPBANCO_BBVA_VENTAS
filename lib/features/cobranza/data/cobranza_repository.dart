import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/cliente_mora.dart';

final cobranzaRepositoryProvider = Provider<CobranzaRepository>((ref) {
  return CobranzaRepository(ref.watch(apiClientProvider));
});

class CobranzaRepository {
  final ApiClient _api;

  CobranzaRepository(this._api);

  Future<List<ClienteMora>> listarMora(String asesorId) async {
    final list = await _api.getList('/cobranza/mora');
    return list
        .map((j) => ClienteMora.fromJson(j as Map<String, dynamic>))
        .toList();
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
    await _api.post('/cobranza/acciones', {
      'cliente_id': clienteId,
      'credito_id': creditoId,
      'tipo_gestion': tipoGestion,
      'resultado': resultado,
      'monto_pagado': montoPagado ?? 0,
      'monto_comprometido': montoComprometido ?? 0,
      'fecha_compromiso': fechaCompromiso?.toIso8601String().split('T')[0],
      'observaciones': observaciones,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<List<Map<String, dynamic>>> historialAcciones(String clienteId) async {
    final list = await _api.getList('/cobranza/acciones/$clienteId');
    return list.cast<Map<String, dynamic>>();
  }
}
