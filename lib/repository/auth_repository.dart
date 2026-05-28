import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/ejecutivo.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<Ejecutivo?> login(String codigoEjecutivo, String password) async {
    final response = await _client
        .from('ejecutivos_negocio')
        .select('''
          *,
          usuarios_app!inner(email, nombre, apellido)
        ''')
        .eq('codigo_ejecutivo', codigoEjecutivo)
        .maybeSingle();

    if (response == null) return null;

    final usuario = response['usuarios_app'] as Map<String, dynamic>;

    return Ejecutivo(
      id: response['id']?.toString() ?? '',
      codigoEjecutivo: response['codigo_ejecutivo']?.toString() ?? '',
      email: usuario['email']?.toString() ?? '',
      nombre: usuario['nombre']?.toString() ?? '',
      apellido: usuario['apellido']?.toString() ?? '',
      sucursalId: response['sucursal_id']?.toString() ?? '',
      especialidad: response['especialidad']?.toString() ?? '',
      zonaAsignada: response['zona_asignada']?.toString() ?? '',
      metaVisitasMes: response['meta_visitas_mes'] ?? 0,
      metaCreditosMes: response['meta_creditos_mes'] ?? 0,
      metaMontoMes: (response['meta_monto_mes'] ?? 0).toDouble(),
      visitasMesActual: response['visitas_mes_actual'] ?? 0,
      creditosMesActual: response['creditos_mes_actual'] ?? 0,
      montoMesActual: (response['monto_mes_actual'] ?? 0).toDouble(),
    );
  }
}
