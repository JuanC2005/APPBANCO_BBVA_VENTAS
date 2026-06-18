import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import 'documentos_viewmodel.dart';

class CapturaDocumentosScreen extends ConsumerStatefulWidget {
  final String solicitudId;
  const CapturaDocumentosScreen({super.key, required this.solicitudId});

  @override
  ConsumerState<CapturaDocumentosScreen> createState() =>
      _CapturaDocumentosScreenState();
}

class _CapturaDocumentosScreenState
    extends ConsumerState<CapturaDocumentosScreen> {
  final _picker = ImagePicker();

  final List<Map<String, String>> _requiredDocs = [
    {'name': 'DNI Frontal', 'key': 'dni_frontal'},
    {'name': 'DNI Posterior', 'key': 'dni_posterior'},
    {'name': 'Recibo de Servicio', 'key': 'recibo_servicio'},
    {'name': 'Croquis de Vivienda', 'key': 'croquis_vivienda'},
    {'name': 'Foto de Negocio', 'key': 'foto_negocio'},
    {'name': 'Contrato Firmado', 'key': 'contrato_firmado'},
  ];

  Future<void> _capturar(String key) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (xfile != null) {
      ref.read(documentosViewModelProvider.notifier).capturar(key, xfile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentosViewModelProvider);
    final vm = ref.read(documentosViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Documentos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Documentos Requeridos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Capture los documentos con luz adecuada.',
              style: TextStyle(color: BBVAColors.darkGray)),
          const SizedBox(height: 16),
          ..._requiredDocs.map((doc) => _docItem(
                doc['name']!,
                doc['key']!,
                state.capturas.containsKey(doc['key']),
                () => _capturar(doc['key']!),
                () => vm.eliminarCaptura(doc['key']!),
              )),
          const SizedBox(height: 16),
          Text('${vm.capturados}/${_requiredDocs.length} capturados',
              style: const TextStyle(color: BBVAColors.darkGray)),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.error!,
                  style: const TextStyle(color: BBVAColors.errorRed)),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.capturas.isEmpty || state.isUploading
                  ? null
                  : () => vm.subirTodos(widget.solicitudId),
              icon: state.isUploading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(state.isUploading
                  ? 'Subiendo...' : 'Subir todos los documentos'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docItem(
      String name, String key, bool captured, VoidCallback onCapture,
      VoidCallback onRemove) {
    return Card(
      child: ListTile(
        leading: Icon(
          captured ? Icons.check_circle : Icons.camera_alt_outlined,
          color: captured ? BBVAColors.successGreen : BBVAColors.mediumGray,
        ),
        title: Text(name),
        subtitle: captured ? const Text('Capturado') : null,
        trailing: TextButton(
          onPressed: captured ? onRemove : onCapture,
          child: Text(captured ? 'Quitar' : 'Capturar'),
        ),
      ),
    );
  }
}
