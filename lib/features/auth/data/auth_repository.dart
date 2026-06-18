import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_db.dart';
import '../domain/asesor_negocio.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(localDbProvider), ref.watch(apiClientProvider));
});

class AuthRepository {
  final _storage = const FlutterSecureStorage();
  static const _userKey = 'user_data';
  final LocalDatabase _localDb;
  final ApiClient _api;

  AuthRepository(this._localDb, this._api);

  Future<AsesorNegocio?> login(String email, String password) async {
    final result = await _api.post('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    if (result['access_token'] == null) throw Exception('Login falló');

    await _api.saveToken(result['access_token']);
    final asesorData = result['asesor'] as Map<String, dynamic>;
    final asesor = AsesorNegocio.fromJson(asesorData);
    await _storage.write(key: _userKey, value: asesor.codigoEmpleado);
    return asesor;
  }

  Future<String?> register({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String agenciaId,
  }) async {
    final result = await _api.post('/auth/register', {
      'email': email.trim(),
      'password': password,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'agencia_id': agenciaId,
    });
    return result['codigo_empleado'] as String?;
  }

  Future<void> logout() async {
    try {
      await _localDb.limpiarTodo().timeout(const Duration(seconds: 5));
    } catch (_) {}
    await _api.deleteToken();
    await _storage.delete(key: _userKey);
  }

  Future<List<Map<String, dynamic>>> obtenerPendientesSync() async {
    return _localDb.obtenerVisitasPendientes();
  }

  Future<AsesorNegocio?> getSavedSession() async {
    final token = await _api.token;
    if (token == null) return null;
    try {
      final result = await _api.get('/auth/me');
      return AsesorNegocio.fromJson(result);
    } catch (_) {
      await _api.deleteToken();
      return null;
    }
  }

  Future<void> saveSession(AsesorNegocio asesor) async {
    await _storage.write(key: _userKey, value: asesor.codigoEmpleado);
  }
}
