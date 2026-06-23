import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_viewmodel.dart';
import '../features/cartera/presentation/cartera_screen.dart';
import '../features/ruta/presentation/ruta_screen.dart';
import '../features/ficha_cliente/presentation/ficha_screen.dart';
import '../features/solicitud/presentation/solicitud_screen.dart';
import '../features/solicitud/presentation/paso1_datos_solicitante.dart';
import '../features/solicitud/presentation/paso2_datos_negocio.dart';
import '../features/solicitud/presentation/paso3_condiciones_credito.dart';
import '../features/solicitud/presentation/paso4_confirmacion_firma.dart';
import '../features/solicitud/presentation/simulador_screen.dart';
import '../features/solicitud/presentation/historial_solicitudes_screen.dart';
import '../features/documentos/presentation/captura_documentos_screen.dart';
import '../features/documentos/presentation/visor_documentos_screen.dart';
import '../features/buro/presentation/consulta_buro_screen.dart';
import '../features/transmision/presentation/transmision_screen.dart';
import '../features/estado_solicitudes/presentation/tablero_solicitudes_screen.dart';
import '../features/estado_solicitudes/presentation/detalle_solicitud_screen.dart';
import '../features/cobranza/presentation/mora_lista_screen.dart';
import '../features/cobranza/presentation/accion_cobranza_screen.dart';
import '../features/reportes/presentation/monitor_supervisor_screen.dart';
import '../features/reportes/presentation/reporte_productividad_screen.dart';
import '../features/preevaluacion/presentation/preevaluacion_screen.dart';
import '../features/campanas/presentation/campanas_screen.dart';
import '../features/campanas/presentation/crear_campana_screen.dart';
import '../features/estado_solicitudes/presentation/solicitudes_pendientes_screen.dart';
import '../features/admin/comite_screen.dart';
import '../features/admin/comite_detalle_screen.dart';

/// Perfiles que pueden acceder a rutas restringidas.
const _perfilesSupervision = {'supervisor', 'super_operador', 'administrador'};

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final rutaActual = state.matchedLocation;

      if (authState.status == AuthStatus.initial) {
        return rutaActual == '/splash' ? null : '/splash';
      }

      final estaAutenticado =
          authState.status == AuthStatus.authenticated;

      if (rutaActual == '/splash') {
        return estaAutenticado ? '/cartera' : '/login';
      }

      final rutasPublicas = ['/login', '/register'];

      if (!estaAutenticado && !rutasPublicas.contains(rutaActual)) {
        return '/login';
      }

      if (estaAutenticado && rutasPublicas.contains(rutaActual)) {
        return '/cartera';
      }

      // Verificar perfiles para rutas de supervisión (HU-02)
      if (estaAutenticado) {
        final perfil = authState.asesor?.perfil ?? '';
        final rutasSupervision = ['/monitor', '/reporte-productividad', '/crear-campana'];

        if (rutasSupervision.contains(rutaActual) &&
            !_perfilesSupervision.contains(perfil)) {
          return '/cartera';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/cartera', builder: (_, __) => const CarteraScreen()),
      GoRoute(path: '/ruta', builder: (_, __) => const RutaScreen()),
      GoRoute(path: '/ficha-cliente/:clienteId', builder: (context, state) =>
        FichaScreen(clienteId: state.pathParameters['clienteId']!)),
      GoRoute(path: '/solicitud/:clienteId', builder: (context, state) =>
        SolicitudScreen(clienteId: state.pathParameters['clienteId']!)),
      GoRoute(path: '/solicitud/paso1/:solicitudId', builder: (context, state) =>
        Paso1DatosSolicitante(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/solicitud/paso2/:solicitudId', builder: (context, state) =>
        Paso2DatosNegocio(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/solicitud/paso3/:solicitudId', builder: (context, state) =>
        Paso3CondicionesCredito(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/solicitud/paso4/:solicitudId', builder: (context, state) =>
        Paso4ConfirmacionFirma(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/simulador', builder: (_, __) => const SimuladorScreen()),
      GoRoute(path: '/historial-solicitudes', builder: (_, __) => const HistorialSolicitudesScreen()),
      GoRoute(path: '/documentos/:solicitudId', builder: (context, state) =>
        CapturaDocumentosScreen(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/visor-documentos/:solicitudId', builder: (context, state) =>
        VisorDocumentosScreen(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/buro/:clienteId', builder: (context, state) =>
        ConsultaBuroScreen(clienteId: state.pathParameters['clienteId']!)),
      GoRoute(path: '/transmision/:solicitudId', builder: (context, state) =>
        TransmisionScreen(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/tablero-solicitudes', builder: (_, __) => const TableroSolicitudesScreen()),
      GoRoute(path: '/detalle-solicitud/:solicitudId', builder: (context, state) =>
        DetalleSolicitudScreen(solicitudId: state.pathParameters['solicitudId']!)),
      GoRoute(path: '/mora', builder: (_, __) => const MoraListaScreen()),
      GoRoute(path: '/accion-cobranza/:clienteId', builder: (context, state) =>
        AccionCobranzaScreen(clienteId: state.pathParameters['clienteId']!)),
      GoRoute(path: '/monitor', builder: (_, __) => const MonitorSupervisorScreen()),
      GoRoute(path: '/reporte-productividad', builder: (_, __) => const ReporteProductividadScreen()),
      GoRoute(path: '/preevaluacion', builder: (_, __) => const PreevaluacionScreen()),
      GoRoute(path: '/campanas', builder: (_, __) => const CampanasScreen()),
      GoRoute(path: '/crear-campana', builder: (_, __) => const CrearCampanaScreen()),
      GoRoute(path: '/solicitudes-pendientes', builder: (_, __) => const SolicitudesPendientesScreen()),
      GoRoute(path: '/comite', builder: (_, __) => const ComiteScreen()),
      GoRoute(path: '/comite/:solicitudId', builder: (context, state) =>
        ComiteDetalleScreen(solicitudId: state.pathParameters['solicitudId']!)),
    ],
  );
});