import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/campana.dart';

final campanaRepositoryProvider = Provider<CampanaRepository>((ref) {
  return CampanaRepository(ref.watch(apiClientProvider));
});

class CampanaRepository {
  final ApiClient _api;

  CampanaRepository(this._api);

  Future<List<Campana>> obtenerCampanasActivas(String asesorId) async {
    final list = await _api.getList('/campanas/');
    return list
        .map((j) => Campana.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Campana>> obtenerTodasCampanas() async {
    final list = await _api.getList('/campanas/todas');
    return list
        .map((j) => Campana.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearCampana(Campana campana, String creadoPorId) async {
    await _api.post('/campanas/', {
      'titulo': campana.titulo,
      'descripcion': campana.mensaje,
      'tipo': campana.tipo,
      'producto_objetivo': campana.productoSugerido,
    });
  }

  Future<void> marcarLeida(String campanaId, String asesorId) async {
    await _api.post('/campanas/$campanaId/leer', {});
  }

  Future<int> asignarCampana(String campanaId) async {
    throw UnimplementedError('Asignación masiva disponible en admin web');
  }

  Future<void> toggleActiva(String campanaId, bool activa) async {
    await _api.put('/campanas/$campanaId/toggle', {'activa': activa});
  }
}
