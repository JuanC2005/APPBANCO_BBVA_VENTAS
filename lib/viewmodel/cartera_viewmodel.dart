import 'package:flutter/material.dart';
import '../model/ficha_campo.dart';
import '../repository/cartera_repository.dart';

class CarteraViewModel extends ChangeNotifier {
  final CarteraRepository _repository;
  List<FichaCampo> _fichas = [];
  bool _isLoading = false;

  CarteraViewModel(this._repository);

  List<FichaCampo> get fichas => _fichas;
  bool get isLoading => _isLoading;
  int get totalVisits => _fichas.length;

  Future<void> cargarFichas(String ejecutivoUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _fichas = await _repository.getFichasPorEjecutivo(ejecutivoUserId);
    } catch (e) {
      _fichas = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
