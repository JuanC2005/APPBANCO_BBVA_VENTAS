import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/asesor_negocio.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final AsesorNegocio? asesor;
  final String? error;
  final int intentosFallidos;
  final DateTime? bloqueoHasta;

  const AuthState({
    this.status = AuthStatus.initial,
    this.asesor,
    this.error,
    this.intentosFallidos = 0,
    this.bloqueoHasta,
  });

  AuthState copyWith({
    AuthStatus? status,
    AsesorNegocio? asesor,
    String? error,
    int? intentosFallidos,
    DateTime? bloqueoHasta,
  }) {
    return AuthState(
      status: status ?? this.status,
      asesor: asesor ?? this.asesor,
      error: error ?? this.error,
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      bloqueoHasta: bloqueoHasta ?? this.bloqueoHasta,
    );
  }

  bool get estaBloqueado =>
      bloqueoHasta != null && DateTime.now().isBefore(bloqueoHasta!);
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(const AuthState());

  Future<void> login(String codigoEmpleado, String contrasena) async {
    if (state.estaBloqueado) {
      state = state.copyWith(error: 'Demasiados intentos. Espere 30 min.');
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final asesor = await _repository.login(codigoEmpleado, contrasena);
      if (asesor != null) {
        await _repository.saveSession(asesor);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          asesor: asesor,
          intentosFallidos: 0,
        );
      } else {
        final nuevos = state.intentosFallidos + 1;
        final bloqueado = nuevos >= 5;
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          intentosFallidos: nuevos,
          error: 'Credenciales incorrectas',
          bloqueoHasta: bloqueado ? DateTime.now().add(const Duration(minutes: 30)) : null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  Future<void> checkSession() async {
    final codigo = await _repository.getSavedCodigo();
    if (codigo != null) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});
