import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'transmision_viewmodel.dart';

class TransmisionScreen extends ConsumerStatefulWidget {
  final String solicitudId;
  const TransmisionScreen({super.key, required this.solicitudId});

  @override
  ConsumerState<TransmisionScreen> createState() => _TransmisionScreenState();
}

class _TransmisionScreenState extends ConsumerState<TransmisionScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(transmisionViewModelProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transmisionViewModelProvider);
    final vm = ref.read(transmisionViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Transmisión')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Estado de Transmisión',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _item('Validar datos solicitud', state.progreso >= 0.2),
                    _item('Adjuntar documentos', state.progreso >= 0.4),
                    _item('Procesar firma digital', state.progreso >= 0.6),
                    _item('Transmitir a core', state.progreso >= 0.8),
                    _item('Confirmar recepción', state.completado),
                  ],
                ),
              ),
            ),
            if (state.transmitiendo) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: state.progreso),
              const SizedBox(height: 8),
              Text(state.mensaje ?? ''),
            ],
            if (state.completado)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: BBVAColors.successGreen, size: 32),
                    const SizedBox(width: 8),
                    const Text('¡Transmisión exitosa!',
                        style: TextStyle(
                            color: BBVAColors.successGreen,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            if (state.error)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(state.mensaje ?? 'Error desconocido',
                    style: const TextStyle(color: BBVAColors.errorRed)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.transmitiendo
                    ? null
                    : () => vm.iniciar(widget.solicitudId),
                icon: Icon(state.transmitiendo
                    ? Icons.hourglass_top
                    : Icons.cloud_upload),
                label: Text(state.transmitiendo
                    ? 'Transmitiendo...'
                    : state.completado
                        ? 'Transmitir de nuevo'
                        : 'Iniciar Transmisión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, bool completado) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            completado ? Icons.check_circle : Icons.schedule,
            color: completado
                ? BBVAColors.successGreen
                : BBVAColors.mediumGray,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
