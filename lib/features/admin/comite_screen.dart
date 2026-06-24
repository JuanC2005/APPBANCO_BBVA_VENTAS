import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import 'comite_repository.dart';

final comiteListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return ref.watch(comiteRepositoryProvider).listarPendientes();
});

class ComiteScreen extends ConsumerWidget {
  const ComiteScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'recibido_comite': return Colors.orange;
      case 'en_evaluacion': return Colors.amber;
      case 'aprobado': case 'desembolsado': return BBVAColors.successGreen;
      case 'rechazado': return BBVAColors.errorRed;
      case 'condicionado': return Colors.amber.shade700;
      default: return BBVAColors.primaryBlue;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'recibido_comite': return 'Recibido';
      case 'en_evaluacion': return 'Evaluación';
      case 'aprobado': return 'Aprobado';
      case 'condicionado': return 'Condicionado';
      case 'rechazado': return 'Rechazado';
      case 'desembolsado': return 'Desembolsado';
      default: return estado;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comiteAsync = ref.watch(comiteListProvider);
    final f = NumberFormat.currency(symbol: 'S/', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: const Text('Comité de Créditos')),
      body: comiteAsync.when(
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
                onPressed: () => ref.invalidate(comiteListProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (solicitudes) {
          if (solicitudes.isEmpty) {
            return const Center(child: Text('No hay solicitudes pendientes de revisión'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(comiteListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              itemBuilder: (_, i) {
                final s = solicitudes[i] as Map<String, dynamic>;
                return Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _estadoColor(s['estado'] ?? '').withValues(alpha: 0.2),
                      child: Icon(Icons.description, color: _estadoColor(s['estado'] ?? '')),
                    ),
                    title: Text('Cliente: ${s['cliente_nombre'] ?? s['cliente_id'] ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monto: ${f.format((s['monto_solicitado'] ?? 0).toDouble())}'),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(_estadoLabel(s['estado'] ?? ''),
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: _estadoColor(s['estado'] ?? ''),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _info('Exp.', s['numero_expediente'] ?? '-'),
                            _info('Plazo', '${s['plazo_meses'] ?? '-'} meses'),
                            _info('TEA', '${s['tea_referencial'] ?? '-'}%'),
                            _info('Destino', s['destino_credito'] ?? '-'),
                            _info('Garantía', s['garantia'] ?? '-'),
                            _info('Seguro', s['con_seguro'] == true ? 'Sí' : 'No'),
                            if (s['asesor_nombre'] != null)
                              _info('Asesor', s['asesor_nombre']),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _showEvaluarDialog(context, ref, s['id'] as String);
                                    },
                                    child: const Text('Evaluar'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showDecidirDialog(context, ref, s['id'] as String);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: BBVAColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Decidir'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: BBVAColors.darkGray, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  void _showEvaluarDialog(BuildContext context, WidgetRef ref, String id) {
    final montoCtrl = TextEditingController();
    final cuotaCtrl = TextEditingController();
    final dictamenCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Evaluar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto sugerido (S/)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cuotaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cuota sugerida (S/)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dictamenCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Dictamen', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(comiteRepositoryProvider).evaluar(id, {
                  'monto_sugerido': double.tryParse(montoCtrl.text),
                  'cuota_sugerida': double.tryParse(cuotaCtrl.text),
                  'dictamen': dictamenCtrl.text,
                });
                Navigator.pop(ctx);
                ref.invalidate(comiteListProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evaluación registrada')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: BBVAColors.errorRed),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDecidirDialog(BuildContext context, WidgetRef ref, String id) {
    String decision = 'aprobado';
    bool isSubmitting = false;
    final montoCtrl = TextEditingController();
    final condicionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Decisión Final'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: decision,
                decoration: const InputDecoration(labelText: 'Decisión', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'aprobado', child: Text('Aprobado')),
                  DropdownMenuItem(value: 'condicionado', child: Text('Condicionado')),
                  DropdownMenuItem(value: 'rechazado', child: Text('Rechazado')),
                ],
                onChanged: isSubmitting ? null : (v) => setDialogState(() => decision = v!),
              ),
              const SizedBox(height: 8),
              if (decision != 'rechazado')
                TextField(
                  controller: montoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto aprobado (S/)', border: OutlineInputBorder()),
                ),
              if (decision == 'condicionado') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: condicionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Condición adicional', border: OutlineInputBorder()),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref.read(comiteRepositoryProvider).decidir(id, {
                          'decision': decision,
                          'monto_aprobado': double.tryParse(montoCtrl.text),
                          'condicion_adicional': condicionCtrl.text.isNotEmpty ? condicionCtrl.text : null,
                        });
                        Navigator.pop(ctx);
                        ref.invalidate(comiteListProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Solicitud $decision')),
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        final msg = e.toString();
                        if (msg.contains('Failed to fetch') || msg.contains('ClientException')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Error de conexión. La solicitud pudo ser procesada. '
                                'Verifique la lista o reintente.',
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: BBVAColors.errorRed),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: decision == 'aprobado'
                    ? BBVAColors.successGreen
                    : decision == 'condicionado'
                        ? Colors.amber.shade700
                        : BBVAColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
