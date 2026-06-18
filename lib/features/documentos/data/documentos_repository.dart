import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../../core/network/network_monitor.dart';
import '../domain/documento_solicitud.dart';

final documentosRepositoryProvider = Provider<DocumentosRepository>((ref) {
  return DocumentosRepository(ref.watch(networkMonitorProvider));
});

class DocumentosRepository {
  final NetworkMonitor _networkMonitor;

  DocumentosRepository(this._networkMonitor);

  Future<String?> subirDocumento({
    required String solicitudId,
    required String tipoDocumento,
    required File archivo,
  }) async {
    if (!_networkMonitor.isOnline) return null;

    final supabase = SupabaseClientProvider.client;
    final path = 'solicitudes/$solicitudId/$tipoDocumento.jpg';

    try {
      await supabase.storage.from('documentos').upload(path, archivo);
      final url = supabase.storage.from('documentos').getPublicUrl(path);

      await supabase.from('solicitudes_documentos').upsert({
        'solicitud_id': solicitudId,
        'tipo_documento': tipoDocumento,
        'url_documento': url,
        'estado': 'LISTO',
      });

      return url;
    } catch (e) {
      try {
        await supabase.storage.from('documentos').update(path, archivo);
        final url = supabase.storage.from('documentos').getPublicUrl(path);
        return url;
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<DocumentoSolicitud>> listarDocumentos(String solicitudId) async {
    final supabase = SupabaseClientProvider.client;
    final response = await supabase
        .from('solicitudes_documentos')
        .select()
        .eq('solicitud_id', solicitudId);
    return (response as List)
        .map((j) => DocumentoSolicitud.fromJson(j))
        .toList();
  }

  Future<bool> eliminarDocumento(String id) async {
    try {
      final supabase = SupabaseClientProvider.client;
      await supabase.from('solicitudes_documentos').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
