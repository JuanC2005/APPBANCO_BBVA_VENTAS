import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../core/constants/app_colors.dart';

class Paso4ConfirmacionFirma extends StatefulWidget {
  final String solicitudId;
  const Paso4ConfirmacionFirma({super.key, required this.solicitudId});

  @override
  State<Paso4ConfirmacionFirma> createState() => _Paso4ConfirmacionFirmaState();
}

class _Paso4ConfirmacionFirmaState extends State<Paso4ConfirmacionFirma> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: BBVAColors.primaryBlue,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Confirmación y Firma')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen de la Solicitud',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            _resumenItem('Cliente:', 'Juan Carlos Pérez López'),
            _resumenItem('Monto:', 'S/ 5,000'),
            _resumenItem('Plazo:', '12 meses'),
            _resumenItem('TEA:', '18.5%'),
            _resumenItem('Cuota Mensual:', 'S/ 458.50'),
            const SizedBox(height: 16),
            const Text('Firma Digital',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: BBVAColors.mediumGray),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Signature(
                controller: _signatureController,
                height: 150,
                backgroundColor: BBVAColors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _signatureController.clear(),
              child: const Text('Limpiar firma'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Solicitud enviada al comité')),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.send),
                label: const Text('Enviar al Comité'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumenItem(String label, String value) {
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
