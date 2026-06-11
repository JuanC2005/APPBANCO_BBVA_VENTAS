import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VisorDocumentosScreen extends StatelessWidget {
  final String solicitudId;
  const VisorDocumentosScreen({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos Adjuntos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _docCard('DNI Frontal', 'dni_frontal.jpg', '120 KB', true),
          _docCard('DNI Posterior', 'dni_posterior.jpg', '115 KB', true),
          _docCard('Recibo de Servicio', 'recibo.jpg', '245 KB', true),
          _docCard('Croquis', 'croquis.jpg', '180 KB', false),
        ],
      ),
    );
  }

  Widget _docCard(String name, String file, String size, bool uploaded) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description, color: BBVAColors.primaryBlue),
        title: Text(name),
        subtitle: Text('$file · $size'),
        trailing: Icon(
          uploaded ? Icons.cloud_done : Icons.cloud_off,
          color: uploaded ? BBVAColors.successGreen : BBVAColors.errorRed,
        ),
      ),
    );
  }
}
