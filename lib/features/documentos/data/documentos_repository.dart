import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_monitor.dart';
import '../domain/documento_solicitud.dart';

final documentosRepositoryProvider = Provider<DocumentosRepository>((ref) {
  return DocumentosRepository(
    ref.watch(networkMonitorProvider),
    ref.watch(apiClientProvider),
  );
});

class DocumentosRepository {
  final NetworkMonitor _networkMonitor;
  final ApiClient _api;

  DocumentosRepository(this._networkMonitor, this._api);

  Future<String?> subirDocumento({
    required String solicitudId,
    required String tipoDocumento,
    required File archivo,
  }) async {
    if (!_networkMonitor.isOnline) return null;
    try {
      final result = await _api.uploadFile(
        '/solicitudes/$solicitudId/documentos',
        archivo,
        extraFields: {'tipo_documento': tipoDocumento},
      );
      return result['url'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<List<DocumentoSolicitud>> listarDocumentos(String solicitudId) async {
    final list = await _api.getList('/solicitudes/$solicitudId/documentos');
    return list
        .map((j) => DocumentoSolicitud.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<bool> eliminarDocumento(String id) async {
    try {
      await _api.delete('/documentos/$id');
      return true;
    } catch (_) {
      return false;
    }
  }
}
