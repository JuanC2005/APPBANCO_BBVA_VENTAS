import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class SolicitudScreen extends StatelessWidget {
  final String clienteId;
  const SolicitudScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Solicitud')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Solicitud de Crédito',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _stepItem('Paso 1', 'Datos del Solicitante', 'Completado', BBVAColors.successGreen,
                () => context.push('/solicitud/paso1/$clienteId')),
            _stepItem('Paso 2', 'Datos del Negocio', 'Pendiente', BBVAColors.mediumGray,
                () {}),
            _stepItem('Paso 3', 'Condiciones del Crédito', 'Pendiente', BBVAColors.mediumGray,
                () {}),
            _stepItem('Paso 4', 'Confirmación y Firma', 'Pendiente', BBVAColors.mediumGray,
                () {}),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Guardar Borrador'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.push('/simulador'),
              icon: const Icon(Icons.calculate),
              label: const Text('Abrir Simulador'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(String paso, String titulo, String estado, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(
            estado == 'Completado' ? Icons.check_circle : Icons.circle_outlined,
            color: color,
          ),
        ),
        title: Text('$paso: $titulo'),
        subtitle: Text(estado, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
