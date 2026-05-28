import 'package:flutter/material.dart';
import '../model/ejecutivo.dart';
import '../repository/auth_repository.dart';

class AuthOficialViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  Ejecutivo? _ejecutivo;

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  AuthOficialViewModel(this._repository);

  Ejecutivo? get ejecutivo => _ejecutivo;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<bool> login(String codigoEjecutivo, String password) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _ejecutivo = await _repository.login(codigoEjecutivo, password);

      _isLoading = false;
      if (_ejecutivo != null) {
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = "Credenciales incorrectas";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = "Error de conexión: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
}
