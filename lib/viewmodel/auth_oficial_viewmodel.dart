import 'package:flutter/material.dart';
import '../model/official.dart';

class AuthOficialViewModel extends ChangeNotifier {
  final Official _hardcodedOfficial = Official(
    employeeCode: "OFICIAL001", // Credencial hardcodeada
    password: "bbva2026", // Credencial hardcodeada
    name: "Carlos Mendoza",
  );

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<bool> login(String employeeCode, String password) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simular loading

    _isLoading = false;
    if (employeeCode == _hardcodedOfficial.employeeCode &&
        password == _hardcodedOfficial.password) {
      notifyListeners();
      return true;
    } else {
      _hasError = true;
      _errorMessage = "Credenciales incorrectas";
      notifyListeners();
      return false;
    }
  }
}
