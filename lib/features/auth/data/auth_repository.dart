import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../domain/asesor_negocio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final _storage = const FlutterSecureStorage();
  static const _userKey = 'user_data';

  Future<AsesorNegocio?> login(String email, String password) async {
    final supabase = SupabaseClientProvider.client;
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw Exception('Usuario no encontrado');

      final asesorResponse = await supabase
          .from('asesores_negocio')
          .select()
          .eq('user_id', response.user!.id)
          .maybeSingle();

      if (asesorResponse == null) {
        await supabase.auth.signOut();
        throw Exception(
            'Tu cuenta de email no está vinculada a un perfil de asesor. '
            'Ejecuta 07_link_auth_users.sql en Supabase.');
      }

      final asesor = AsesorNegocio.fromJson(asesorResponse);
      await _storage.write(key: _userKey, value: asesor.codigoEmpleado);
      return asesor;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String agenciaId,
  }) async {
    final supabase = SupabaseClientProvider.client;
    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (authResponse.user == null) {
        throw Exception('No se pudo crear el usuario en Supabase Auth');
      }

      final codigo = await supabase.rpc('registrar_asesor', params: {
        'p_user_id': authResponse.user!.id,
        'p_email': email,
        'p_nombres': nombres,
        'p_apellidos': apellidos,
        'p_telefono': telefono,
        'p_agencia_id': agenciaId,
      });

      return codigo as String?;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> logout() async {
    await SupabaseClientProvider.client.auth.signOut();
    await _storage.delete(key: _userKey);
  }

  Future<AsesorNegocio?> getSavedSession() async {
    final session = SupabaseClientProvider.client.auth.currentSession;
    if (session == null ||
        session.expiresAt == null ||
        DateTime.now().isAfter(
            DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000))) {
      return null;
    }
    try {
      final response = await SupabaseClientProvider.client
          .from('asesores_negocio')
          .select()
          .eq('user_id', session.user.id)
          .single();
      return AsesorNegocio.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(AsesorNegocio asesor) async {
    await _storage.write(key: _userKey, value: asesor.codigoEmpleado);
  }
}
