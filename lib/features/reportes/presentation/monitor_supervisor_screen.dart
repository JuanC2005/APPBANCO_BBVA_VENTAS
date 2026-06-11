import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class MonitorSupervisorScreen extends StatelessWidget {
  const MonitorSupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor de Supervisor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Agencia: Huancayo | Fecha: Hoy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _asesorCard(context, 'EJE-001', 'Carlos Mendoza', 8, 5, 3),
          _asesorCard(context, 'EJE-002', 'María Torres', 7, 4, 3),
          _asesorCard(context, 'EJE-003', 'José Huamán', 6, 6, 0),
          _asesorCard(context, 'EJE-004', 'Lucía Rivas', 9, 3, 6),
        ],
      ),
    );
  }

  Widget _asesorCard(BuildContext context, String codigo, String nombre,
      int total, int visitados, int pendientes) {
    final progreso = total > 0 ? visitados / total : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(codigo, style: const TextStyle(color: BBVAColors.darkGray)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progreso),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$visitados/$total visitados',
                    style: const TextStyle(color: BBVAColors.successGreen)),
                Text('$pendientes pendientes',
                    style: const TextStyle(color: BBVAColors.warningAmber)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () => context.push('/ruta'),
                ),
                IconButton(
                  icon: const Icon(Icons.assessment),
                  onPressed: () => context.push('/reporte-productividad'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
