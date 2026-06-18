import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/asesor_negocio.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final AsesorNegocio? asesor;
  final String? error;
  final int intentosFallidos;
  final DateTime? bloqueoHasta;
  final int pendientesSync;

  const AuthState({
    this.status = AuthStatus.initial,
    this.asesor,
    this.error,
    this.intentosFallidos = 0,
    this.bloqueoHasta,
    this.pendientesSync = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    AsesorNegocio? asesor,
    String? error,
    int? intentosFallidos,
    DateTime? bloqueoHasta,
    int? pendientesSync,
  }) {
    return AuthState(
      status: status ?? this.status,
      asesor: asesor ?? this.asesor,
      error: error ?? this.error,
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      bloqueoHasta: bloqueoHasta ?? this.bloqueoHasta,
      pendientesSync: pendientesSync ?? this.pendientesSync,
    );
  }

  bool get estaBloqueado =>
      bloqueoHasta != null && DateTime.now().isBefore(bloqueoHasta!);
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  Timer? _inactivityTimer;
  static const _inactivityDuration = Duration(hours: 8);
  static const _lastActivityKey = 'last_activity_timestamp';

  AuthViewModel(this._repository) : super(const AuthState());

  Future<void> initAsync() async {
    try {
      await _checkInactivityOnStart();
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
    try {
      await checkSession().timeout(const Duration(seconds: 15));
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Resetea el timer de inactividad cada vez que el usuario interactúa.
  void registrarActividad() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, _inactivityLogout);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(
          _lastActivityKey, DateTime.now().millisecondsSinceEpoch);
    });
  }

  Future<void> _checkInactivityOnStart() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity =
        prefs.getInt(_lastActivityKey);
    if (lastActivity != null) {
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - lastActivity;
      if (elapsed > _inactivityDuration.inMilliseconds) {
        await logout();
        return;
      }
    }
    registrarActividad();
  }

  Future<void> _inactivityLogout() async {
    state = state.copyWith(
      error: 'Sesión expirada por inactividad (>8 horas)',
    );
    await logout();
  }

  Future<void> login(String email, String password) async {
    if (state.estaBloqueado) {
      state = state.copyWith(error: 'Demasiados intentos. Espere 30 min.');
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final asesor = await _repository.login(email, password);
      if (asesor != null) {
        await _repository.saveSession(asesor);
        final pendientes = await _repository.obtenerPendientesSync();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          asesor: asesor,
          intentosFallidos: 0,
          pendientesSync: pendientes.length,
        );
        registrarActividad();
      } else {
        final nuevos = state.intentosFallidos + 1;
        final bloqueado = nuevos >= 5;
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          intentosFallidos: nuevos,
          error: 'Credenciales incorrectas',
          bloqueoHasta: bloqueado
              ? DateTime.now().add(const Duration(minutes: 30))
              : null,
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: msg,
      );
    }
  }

  /// Logout con verificación de pendientes (RF-08).
  /// Retorna el número de pendientes (0 si se hizo logout completo).
  Future<int> logout({bool force = false}) async {
    if (!force) {
      final pendientes = await _repository.obtenerPendientesSync();
      if (pendientes.isNotEmpty) {
        state = state.copyWith(pendientesSync: pendientes.length);
        return pendientes.length;
      }
    }
    _inactivityTimer?.cancel();
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.logout();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
    return 0;
  }

  Future<void> register({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String agenciaId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final codigo = await _repository.register(
        email: email,
        password: password,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        agenciaId: agenciaId,
      );
      if (codigo != null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Error al crear la cuenta. Intente de nuevo.',
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: msg,
      );
    }
  }

  Future<void> checkSession() async {
    try {
      final asesor = await _repository.getSavedSession();
      if (asesor != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          asesor: asesor,
        );
        registrarActividad();
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});
