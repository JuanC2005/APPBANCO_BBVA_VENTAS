import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'buro_viewmodel.dart';

class ConsultaBuroScreen extends ConsumerStatefulWidget {
  final String clienteId;
  const ConsultaBuroScreen({super.key, required this.clienteId});

  @override
  ConsumerState<ConsultaBuroScreen> createState() => _ConsultaBuroScreenState();
}

class _ConsultaBuroScreenState extends ConsumerState<ConsultaBuroScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(buroViewModelProvider.notifier).limpiar();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buroViewModelProvider);
    final vm = ref.read(buroViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta Buró')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Consentimiento del Cliente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Autorizo a BBVA a realizar la consulta de mi historial crediticio '
                  'en las centrales de riesgo (SBS, Infocorp, Sentinel) para la '
                  'evaluación de mi solicitud de crédito.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('He leído y acepto el consentimiento'),
              value: state.consentimiento,
              onChanged: (v) => vm.setConsentimiento(v ?? false),
            ),
            if (state.resultado != null) ...[
              const Divider(),
              const Text('Resultado de la Consulta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _resultadoRow('Score',
                          '${state.resultado!['score'] ?? 'N/D'}'),
                      _resultadoRow('Calificación SBS',
                          state.resultado!['calificacion_sbs'] ?? 'N/D'),
                      _resultadoRow('Deuda Total',
                          'S/ ${(state.resultado!['deuda_total_pen'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                      _resultadoRow('Entidades',
                          '${state.resultado!['entidades_con_deuda'] ?? 0}'),
                      _resultadoRow('Días Mayor Mora',
                          '${state.resultado!['dias_mayor_mora'] ?? 0}'),
                      _resultadoRow('Protestos',
                          state.resultado!['protestos'] ?? 'Ninguno'),
                    ],
                  ),
                ),
              ),
            ],
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(state.error!,
                    style: const TextStyle(color: BBVAColors.errorRed)),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.consentimiento && !state.consultando
                    ? () => vm.consultar(
                          clienteId: widget.clienteId,
                          dni: '',
                          firmaConsentimiento: '',
                        )
                    : null,
                icon: state.consultando
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search),
                label: Text(state.consultando
                    ? 'Consultando...'
                    : 'Consultar Buró'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultadoRow(String label, String value) {
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
