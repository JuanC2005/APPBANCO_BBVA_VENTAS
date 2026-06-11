import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
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

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/cartera', builder: (_, __) => const CarteraScreen()),
    GoRoute(path: '/ruta', builder: (_, __) => const RutaScreen()),
    GoRoute(path: '/ficha-cliente/:clienteId', builder: (context, state) =>
      FichaScreen(clienteId: state.pathParameters['clienteId']!)),
    GoRoute(path: '/solicitud/:clienteId', builder: (context, state) =>
      SolicitudScreen(clienteId: state.pathParameters['clienteId']!)),
    GoRoute(path: '/solicitud/paso1/:clienteId', builder: (context, state) =>
      Paso1DatosSolicitante(clienteId: state.pathParameters['clienteId']!)),
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
  ],
);
