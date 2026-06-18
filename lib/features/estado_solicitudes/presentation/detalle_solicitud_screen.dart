import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../solicitud/domain/solicitud.dart';
import '../data/estado_repository.dart';

final detalleSolicitudProvider =
    FutureProvider.family<SolicitudCredito?, String>((ref, id) {
  final repo = ref.watch(estadoRepositoryProvider);
  return repo.obtenerPorId(id);
});

class DetalleSolicitudScreen extends ConsumerWidget {
  final String solicitudId;
  const DetalleSolicitudScreen({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(detalleSolicitudProvider(solicitudId));

    return Scaffold(
      appBar: AppBar(title: Text('Solicitud #${solicitudId.substring(0, 8)}')),
      body: detalle.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) {
          if (s == null) {
            return const Center(child: Text('Solicitud no encontrada'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado Actual',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _estadoColor(s.estado).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.estadoLabel.toUpperCase(),
                      style: TextStyle(
                        color: _estadoColor(s.estado),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Detalles',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                _detalleRow('Cliente', s.clienteId.substring(0, 8)),
                _detalleRow('Monto Solicitado',
                    'S/ ${Formatters.moneda(s.montoSolicitado)}'),
                _detalleRow('Plazo', '${s.plazoMeses} meses'),
                if (s.teaReferencial != null)
                  _detalleRow('TEA',
                      '${s.teaReferencial!.toStringAsFixed(1)}%'),
                if (s.cuotaEstimada != null)
                  _detalleRow('Cuota',
                      'S/ ${Formatters.moneda(s.cuotaEstimada!)}'),
                _detalleRow('Garantía', s.garantia),
                _detalleRow('Estado', s.estadoLabel),
                _detalleRow('Creado', _fecha(s.createdAt)),
                if (s.numeroExpediente != null)
                  _detalleRow('Expediente', s.numeroExpediente!),
                if (s.montoAprobado != null)
                  _detalleRow('Monto Aprobado',
                      'S/ ${Formatters.moneda(s.montoAprobado!)}'),
                if (s.motivoRechazo != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: BBVAColors.errorRed.withAlpha(20),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: BBVAColors.errorRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s.motivoRechazo!,
                                style: const TextStyle(
                                    color: BBVAColors.errorRed)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                        '/transmision/${s.id}'),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Transmitir'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'aprobado': case 'desembolsado':
        return BBVAColors.successGreen;
      case 'rechazado':
        return BBVAColors.errorRed;
      case 'condicionado':
        return BBVAColors.warningAmber;
      default:
        return BBVAColors.primaryBlue;
    }
  }

  Widget _detalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: BBVAColors.darkGray)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _fecha(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
