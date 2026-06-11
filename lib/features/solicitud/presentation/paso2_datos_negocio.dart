import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Paso2DatosNegocio extends StatelessWidget {
  final String solicitudId;
  const Paso2DatosNegocio({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos del Negocio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Negocio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: 'Bodega Don Juan'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: 'Jr. La Mar 456, Huancayo'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tipo de Negocio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: 'Comercio'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Antigüedad (meses)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: '24'),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/solicitud/paso3/$solicitudId'),
                    child: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
