import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../domain/solicitud.dart';
import '../data/solicitud_repository.dart';

final historialProvider = FutureProvider<List<SolicitudCredito>>((ref) {
  final asesor = ref.watch(authViewModelProvider).asesor;
  final repo = ref.watch(solicitudRepositoryProvider);
  return repo.listarEnviadas(asesor?.id ?? '');
});

class HistorialSolicitudesScreen extends ConsumerWidget {
  const HistorialSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historial = ref.watch(historialProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Solicitudes')),
      body: historial.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (solicitudes) {
          if (solicitudes.isEmpty) {
            return const Center(child: Text('Sin solicitudes enviadas'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: solicitudes.map((s) => _solicitudItem(s, context)).toList(),
          );
        },
      ),
    );
  }

  Widget _solicitudItem(SolicitudCredito s, BuildContext context) {
    Color estadoColor;
    switch (s.estado) {
      case 'aprobado': case 'desembolsado':
        estadoColor = BBVAColors.successGreen;
      case 'rechazado':
        estadoColor = BBVAColors.errorRed;
      case 'en_evaluacion':
        estadoColor = BBVAColors.warningAmber;
      default:
        estadoColor = BBVAColors.primaryBlue;
    }

    return Card(
      child: ListTile(
        title: Text(s.numeroExpediente ?? s.id.substring(0, 8),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('S/ ${s.montoSolicitado.toStringAsFixed(0)} | ${_fecha(s.createdAt)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: estadoColor.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(s.estadoLabel,
              style: TextStyle(color: estadoColor, fontWeight: FontWeight.bold)),
        ),
        onTap: () => context.push('/detalle-solicitud/${s.id}'),
      ),
    );
  }

  String _fecha(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
