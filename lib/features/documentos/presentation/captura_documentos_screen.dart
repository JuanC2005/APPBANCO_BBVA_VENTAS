import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CapturaDocumentosScreen extends StatefulWidget {
  final String solicitudId;
  const CapturaDocumentosScreen({super.key, required this.solicitudId});

  @override
  State<CapturaDocumentosScreen> createState() => _CapturaDocumentosScreenState();
}

class _CapturaDocumentosScreenState extends State<CapturaDocumentosScreen> {
  final List<String> _documentosCapturados = [];

  final List<Map<String, String>> _requiredDocs = [
    {'name': 'DNI Frontal', 'key': 'dni_frontal'},
    {'name': 'DNI Posterior', 'key': 'dni_posterior'},
    {'name': 'Recibo de Servicio', 'key': 'recibo_servicio'},
    {'name': 'Croquis de Vivienda', 'key': 'croquis_vivienda'},
    {'name': 'Foto de Negocio', 'key': 'foto_negocio'},
    {'name': 'Contrato Firmado', 'key': 'contrato_firmado'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Documentos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Documentos Requeridos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Capture los documentos necesarios para la solicitud.',
              style: TextStyle(color: BBVAColors.darkGray)),
          const SizedBox(height: 16),
          ..._requiredDocs.map((doc) => _docItem(doc['name']!, doc['key']!)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _documentosCapturados.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Documentos guardados')),
                      );
                      Navigator.pop(context);
                    },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Subir todos los documentos'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docItem(String name, String key) {
    final captured = _documentosCapturados.contains(key);
    return Card(
      child: ListTile(
        leading: Icon(
          captured ? Icons.check_circle : Icons.camera_alt_outlined,
          color: captured ? BBVAColors.successGreen : BBVAColors.mediumGray,
        ),
        title: Text(name),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              if (captured) {
                _documentosCapturados.remove(key);
              } else {
                _documentosCapturados.add(key);
              }
            });
          },
          child: Text(captured ? 'Recapturar' : 'Capturar'),
        ),
      ),
    );
  }
}
