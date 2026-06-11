import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../domain/asesor_negocio.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'session_token';
  static const _userKey = 'user_data';

  Future<AsesorNegocio?> login(String codigoEmpleado, String password) async {
    final supabase = SupabaseClientProvider.client;
    try {
      final response = await supabase
          .from('asesores_negocio')
          .select()
          .eq('codigo_empleado', codigoEmpleado)
          .eq('activo', true)
          .single();
      final asesor = AsesorNegocio.fromJson(response);
      await _storage.write(key: _userKey, value: asesor.codigoEmpleado);
      return asesor;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await SupabaseClientProvider.client.auth.signOut();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getSavedCodigo() async {
    return await _storage.read(key: _userKey);
  }

  Future<void> saveSession(AsesorNegocio asesor) async {
    await _storage.write(key: _userKey, value: asesor.codigoEmpleado);
  }
}
