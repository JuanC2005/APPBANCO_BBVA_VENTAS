class DocumentoSolicitud {
  final String id;
  final String solicitudId;
  final String tipoDocumento;
  final String? urlDocumento;
  final String estado;

  DocumentoSolicitud({
    required this.id,
    required this.solicitudId,
    required this.tipoDocumento,
    this.urlDocumento,
    this.estado = 'PENDIENTE',
  });

  String get tipoLabel {
    switch (tipoDocumento) {
      case 'dni_frontal': return 'DNI Frontal';
      case 'dni_posterior': return 'DNI Posterior';
      case 'recibo_servicio': return 'Recibo de Servicio';
      case 'croquis_vivienda': return 'Croquis de Vivienda';
      case 'foto_negocio': return 'Foto de Negocio';
      case 'contrato_firmado': return 'Contrato Firmado';
      default: return tipoDocumento;
    }
  }

  factory DocumentoSolicitud.fromJson(Map<String, dynamic> json) {
    return DocumentoSolicitud(
      id: json['id'] ?? '',
      solicitudId: json['solicitud_id'] ?? '',
      tipoDocumento: json['tipo_documento'] ?? '',
      urlDocumento: json['url_documento'],
      estado: json['estado'] ?? 'PENDIENTE',
    );
  }
}
