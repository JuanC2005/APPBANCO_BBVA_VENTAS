import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HistorialSolicitudesScreen extends StatelessWidget {
  const HistorialSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Solicitudes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _solicitudItem('SOL-2025-001', 'Juan Pérez', 'S/ 5,000',
              'Aprobado', BBVAColors.successGreen, '12/03/2025'),
          _solicitudItem('SOL-2025-002', 'María García', 'S/ 8,000',
              'Rechazado', BBVAColors.errorRed, '10/03/2025'),
          _solicitudItem('SOL-2025-003', 'Carlos López', 'S/ 3,000',
              'En Evaluación', BBVAColors.warningAmber, '08/03/2025'),
        ],
      ),
    );
  }

  Widget _solicitudItem(String codigo, String cliente, String monto,
      String estado, Color color, String fecha) {
    return Card(
      child: ListTile(
        title: Text(codigo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$cliente | $monto | $fecha'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(estado,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
