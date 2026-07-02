import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cartera/data/cartera_repository.dart';
import '../../cartera/domain/cartera_visita.dart';

final rutaRepositoryProvider = Provider<RutaRepository>((ref) {
  return RutaRepository(ref.watch(carteraRepositoryProvider));
});

class RutaRepository {
  final CarteraRepository _carteraRepository;

  RutaRepository(this._carteraRepository);

  Future<List<CarteraVisita>> obtenerVisitasRuta(String asesorId) async {
    final todas = await _carteraRepository.obtenerCarteraDiaria(asesorId, tipoGestion: 'NUEVA_SOLICITUD');
    return todas
        .where((v) => (v.lat != null && v.lng != null || v.latVisita != null && v.lngVisita != null) && !v.visitado)
        .toList();
  }
}
