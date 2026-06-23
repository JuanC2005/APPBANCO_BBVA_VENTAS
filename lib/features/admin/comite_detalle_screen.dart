import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import 'comite_repository.dart';

final comiteDetalleProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) {
  return ref.watch(comiteRepositoryProvider).obtenerDetalle(id);
});

class ComiteDetalleScreen extends ConsumerWidget {
  final String solicitudId;
  const ComiteDetalleScreen({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalleAsync = ref.watch(comiteDetalleProvider(solicitudId));
    final f = NumberFormat.currency(symbol: 'S/', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: Text('Solicitud #${solicitudId.substring(0, 8)}')),
      body: detalleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final solicitud = data['solicitud'] as Map<String, dynamic>? ?? data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos de la Solicitud',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      _info('Cliente', solicitud['cliente_nombre'] ?? solicitud['cliente_id'] ?? '-'),
                      _info('Monto Solicitado', f.format((solicitud['monto_solicitado'] ?? 0).toDouble())),
                      _info('Plazo', '${solicitud['plazo_meses'] ?? '-'} meses'),
                      _info('TEA', '${solicitud['tea_referencial'] ?? '-'}%'),
                      _info('Destino', solicitud['destino_credito'] ?? '-'),
                      _info('Garantía', solicitud['garantia'] ?? '-'),
                      _info('Seguro', solicitud['con_seguro'] == true ? 'Sí' : 'No'),
                      _info('Estado', solicitud['estado'] ?? '-'),
                      if (solicitud['monto_aprobado'] != null)
                        _info('Monto Aprobado', f.format((solicitud['monto_aprobado']).toDouble())),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
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
}
