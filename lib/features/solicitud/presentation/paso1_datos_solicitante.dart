import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Paso1DatosSolicitante extends StatelessWidget {
  final String clienteId;
  const Paso1DatosSolicitante({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Datos del Solicitante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: 'Juan Carlos'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: 'Pérez López'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'DNI',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: '20456789'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(text: '999888777'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/solicitud/paso2/temp-id'),
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
