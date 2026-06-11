import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TransmisionScreen extends StatefulWidget {
  final String solicitudId;
  const TransmisionScreen({super.key, required this.solicitudId});

  @override
  State<TransmisionScreen> createState() => _TransmisionScreenState();
}

class _TransmisionScreenState extends State<TransmisionScreen> {
  double _progreso = 0;
  bool _transmitiendo = false;

  Future<void> _iniciarTransmision() async {
    setState(() {
      _transmitiendo = true;
      _progreso = 0;
    });
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _progreso = i / 5);
    }
    setState(() => _transmitiendo = false);
  }

  @override
  Widget build(BuildContext context) {
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
                    _itemTransmision(
                        'Datos de Solicitud', true, null),
                    _itemTransmision(
                        'Documentos Adjuntos', _progreso >= 0.4, null),
                    _itemTransmision(
                        'Firma Digital', _progreso >= 0.6, null),
                    _itemTransmision(
                        'Confirmación', _progreso >= 0.8, null),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_transmitiendo) ...[
              LinearProgressIndicator(value: _progreso),
              const SizedBox(height: 8),
              Text('${(_progreso * 100).toInt()}% completado'),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _transmitiendo ? null : _iniciarTransmision,
                icon: Icon(_transmitiendo
                    ? Icons.hourglass_top
                    : Icons.cloud_upload),
                label: Text(
                    _transmitiendo ? 'Transmitiendo...' : 'Iniciar Transmisión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTransmision(String label, bool completado, bool? error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            completado
                ? Icons.check_circle
                : error == true
                    ? Icons.error
                    : Icons.schedule,
            color: completado
                ? BBVAColors.successGreen
                : error == true
                    ? BBVAColors.errorRed
                    : BBVAColors.mediumGray,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
