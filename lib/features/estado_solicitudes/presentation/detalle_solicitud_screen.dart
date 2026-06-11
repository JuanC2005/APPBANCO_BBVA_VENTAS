import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DetalleSolicitudScreen extends StatelessWidget {
  final String solicitudId;
  const DetalleSolicitudScreen({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle: $solicitudId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline de la Solicitud',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _timelineItem('Creada', '12/03/2025 10:30', true),
            _timelineItem('Documentos recibidos', '12/03/2025 11:00', true),
            _timelineItem('En evaluación', '12/03/2025 14:00', true),
            _timelineItem('Aprobada por comité', '13/03/2025 09:00', false),
            const SizedBox(height: 24),
            const Divider(),
            const Text('Detalles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _detalleRow('Cliente', 'Juan Carlos Pérez López'),
            _detalleRow('Monto', 'S/ 5,000'),
            _detalleRow('Plazo', '12 meses'),
            _detalleRow('TEA', '18.5%'),
            _detalleRow('Cuota', 'S/ 458.50'),
            _detalleRow('Estado', 'En Evaluación'),
            _detalleRow('Asesor', 'EJE-001'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(String title, String date, bool completed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? BBVAColors.successGreen : BBVAColors.mediumGray,
              size: 20,
            ),
            Container(width: 2, height: 30,
                color: completed ? BBVAColors.successGreen : BBVAColors.mediumGray),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(date, style: const TextStyle(color: BBVAColors.darkGray, fontSize: 12)),
          ],
        ),
      ],
    );
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
}
