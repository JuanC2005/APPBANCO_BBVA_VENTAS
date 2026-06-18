import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../../core/network/network_monitor.dart';

final transmisionRepositoryProvider = Provider<TransmisionRepository>((ref) {
  return TransmisionRepository(ref.watch(networkMonitorProvider));
});

class TransmisionRepository {
  final NetworkMonitor _networkMonitor;

  TransmisionRepository(this._networkMonitor);

  Future<bool> transmitir(String solicitudId) async {
    if (!_networkMonitor.isOnline) return false;

    final supabase = SupabaseClientProvider.client;
    try {
      await supabase.rpc('transmitir_solicitud', params: {
        'p_solicitud_id': solicitudId,
      });
      return true;
    } catch (_) {
      try {
        await supabase.from('solicitudes_credito').update({
          'estado': 'transmitido',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', solicitudId);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> actualizarEstado(String solicitudId, String estado) async {
    final supabase = SupabaseClientProvider.client;
    try {
      await supabase.from('solicitudes_credito').update({
        'estado': estado,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', solicitudId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
