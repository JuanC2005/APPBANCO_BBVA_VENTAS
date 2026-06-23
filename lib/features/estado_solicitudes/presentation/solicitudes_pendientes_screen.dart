import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../../solicitud/domain/solicitud.dart';
import '../data/solicitudes_pendientes_repository.dart';

final solicitudesPendientesProvider = FutureProvider.autoDispose<List<SolicitudCredito>>((ref) {
  return ref.watch(solicitudesPendientesRepositoryProvider).listarPendientes();
});

class SolicitudesPendientesScreen extends ConsumerWidget {
  const SolicitudesPendientesScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'enviado': return BBVAColors.primaryBlue;
      case 'recibido_comite': return Colors.orange;
      case 'en_evaluacion': return Colors.amber;
      case 'aprobado': case 'desembolsado': return BBVAColors.successGreen;
      case 'rechazado': return BBVAColors.errorRed;
      default: return BBVAColors.darkGray;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(solicitudesPendientesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes Pendientes')),
      body: pendientesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: BBVAColors.darkGray),
              const SizedBox(height: 16),
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(solicitudesPendientesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (solicitudes) {
          if (solicitudes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: BBVAColors.successGreen),
                  SizedBox(height: 16),
                  Text('No hay solicitudes pendientes', style: TextStyle(fontSize: 18, color: BBVAColors.darkGray)),
                  SizedBox(height: 8),
                  Text('Todas las solicitudes tienen asesor asignado'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(solicitudesPendientesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              itemBuilder: (_, i) {
                final s = solicitudes[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _estadoColor(s.estado).withValues(alpha: 0.2),
                      child: Icon(Icons.description, color: _estadoColor(s.estado)),
                    ),
                    title: Text('S/ ${Formatters.moneda(s.montoSolicitado)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente: ${s.clienteId.substring(0, 8)}...'),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(s.estadoLabel, style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: _estadoColor(s.estado),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref.read(solicitudesPendientesRepositoryProvider).tomarSolicitud(s.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Solicitud asignada correctamente')),
                          );
                          ref.invalidate(solicitudesPendientesProvider);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: BBVAColors.errorRed),
                          );
                        }
                      },
                      icon: const Icon(Icons.handshake, size: 16),
                      label: const Text('Tomar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BBVAColors.successGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    onTap: () => context.push('/detalle-solicitud/${s.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
