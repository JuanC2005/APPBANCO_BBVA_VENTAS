import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/documentos_repository.dart';
import '../domain/documento_solicitud.dart';

class DocumentosState {
  final List<DocumentoSolicitud> documentos;
  final Map<String, String> capturas; // tipo -> path local
  final bool isUploading;
  final String? error;

  const DocumentosState({
    this.documentos = const [],
    this.capturas = const {},
    this.isUploading = false,
    this.error,
  });

  DocumentosState copyWith({
    List<DocumentoSolicitud>? documentos,
    Map<String, String>? capturas,
    bool? isUploading,
    String? error,
    bool clearError = false,
  }) {
    return DocumentosState(
      documentos: documentos ?? this.documentos,
      capturas: capturas ?? this.capturas,
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class DocumentosViewModel extends StateNotifier<DocumentosState> {
  final DocumentosRepository _repository;

  DocumentosViewModel(this._repository) : super(const DocumentosState());

  void capturar(String tipoDocumento, String path) {
    final capturas = Map<String, String>.from(state.capturas);
    capturas[tipoDocumento] = path;
    state = state.copyWith(capturas: capturas);
  }

  void eliminarCaptura(String tipoDocumento) {
    final capturas = Map<String, String>.from(state.capturas);
    capturas.remove(tipoDocumento);
    state = state.copyWith(capturas: capturas);
  }

  Future<void> subirTodos(String solicitudId) async {
    state = state.copyWith(isUploading: true, clearError: true);
    for (final entry in state.capturas.entries) {
      final file = File(entry.value);
      if (!file.existsSync()) continue;
      final url = await _repository.subirDocumento(
        solicitudId: solicitudId,
        tipoDocumento: entry.key,
        archivo: file,
      );
      if (url == null) {
        state = state.copyWith(
          error: 'Error al subir ${entry.key}',
        );
      }
    }
    final docs = await _repository.listarDocumentos(solicitudId);
    state = state.copyWith(
      isUploading: false,
      documentos: docs,
      capturas: {},
    );
  }

  Future<void> cargarDocumentos(String solicitudId) async {
    try {
      final docs = await _repository.listarDocumentos(solicitudId);
      state = state.copyWith(documentos: docs, clearError: true);
    } catch (e) {
      state = state.copyWith(error: 'Error al cargar documentos: $e');
    }
  }

  int get capturados => state.capturas.length;
}

final documentosViewModelProvider =
    StateNotifierProvider<DocumentosViewModel, DocumentosState>((ref) {
  return DocumentosViewModel(ref.watch(documentosRepositoryProvider));
});
