import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/documento_solicitud.dart';
import 'documentos_viewmodel.dart';

class VisorDocumentosScreen extends ConsumerStatefulWidget {
  final String solicitudId;
  const VisorDocumentosScreen({super.key, required this.solicitudId});

  @override
  ConsumerState<VisorDocumentosScreen> createState() =>
      _VisorDocumentosScreenState();
}

class _VisorDocumentosScreenState extends ConsumerState<VisorDocumentosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(documentosViewModelProvider.notifier)
          .cargarDocumentos(widget.solicitudId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentosViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documentos Adjuntos')),
      body: state.documentos.isEmpty
          ? const Center(child: Text('Sin documentos adjuntos'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: state.documentos.map(_docCard).toList(),
            ),
    );
  }

  Widget _docCard(DocumentoSolicitud doc) {
    final uploaded = doc.estado == 'LISTO';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description,
            color: BBVAColors.primaryBlue),
        title: Text(doc.tipoLabel),
        subtitle: Text(uploaded ? 'Subido' : 'Pendiente'),
        trailing: Icon(
          uploaded ? Icons.cloud_done : Icons.cloud_off,
          color: uploaded
              ? BBVAColors.successGreen
              : BBVAColors.errorRed,
        ),
      ),
    );
  }
}
