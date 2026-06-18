import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/cliente.dart';
import '../domain/credito.dart';
import '../domain/preaprobado.dart';

final fichaRepositoryProvider = Provider<FichaRepository>((ref) {
  return FichaRepository(ref.watch(apiClientProvider));
});

class FichaRepository {
  final ApiClient _api;

  FichaRepository(this._api);

  Future<Cliente?> obtenerCliente(String clienteId) async {
    final result = await _api.get('/clientes/$clienteId');
    final clienteData = result['cliente'] as Map<String, dynamic>? ?? {};
    return Cliente.fromJson(clienteData);
  }

  Future<List<Credito>> obtenerCreditos(String clienteId) async {
    final result = await _api.get('/clientes/$clienteId');
    final list = result['creditos'] as List<dynamic>? ?? [];
    return list.map((j) => Credito.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> obtenerScore(String clienteId) async {
    try {
      final result = await _api.get('/clientes/$clienteId');
      return result['score'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerMovimientos(String clienteId) async {
    try {
      final result = await _api.get('/clientes/$clienteId');
      final list = result['movimientos'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<Preaprobado?> obtenerPreaprobado(String clienteId) async {
    try {
      final result = await _api.get('/clientes/$clienteId');
      final data = result['preaprobado'] as Map<String, dynamic>?;
      if (data == null) return null;
      return Preaprobado.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> obtenerPerfil(String clienteId) async {
    try {
      final result = await _api.get('/clientes/$clienteId');
      return result['perfil'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
