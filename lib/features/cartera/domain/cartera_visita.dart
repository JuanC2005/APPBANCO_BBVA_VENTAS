class CarteraVisita {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String? clienteTelefono;
  final String? clienteDireccion;
  final double? montoAnterior;
  final String? producto;
  final String tipoVisita;
  final String prioridad;
  final String? resultado;
  final String? observacion;
  final DateTime fechaAsignacion;
  final DateTime? fechaVisita;
  final bool sincronizado;
  final double? lat;
  final double? lng;

  CarteraVisita({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    this.clienteTelefono,
    this.clienteDireccion,
    this.montoAnterior,
    this.producto,
    required this.tipoVisita,
    required this.prioridad,
    this.resultado,
    this.observacion,
    required this.fechaAsignacion,
    this.fechaVisita,
    this.sincronizado = false,
    this.lat,
    this.lng,
  });

  String get prioridadLabel {
    switch (prioridad) {
      case 'alta': return 'Alta';
      case 'media': return 'Media';
      case 'baja': return 'Baja';
      default: return prioridad;
    }
  }

  factory CarteraVisita.fromJson(Map<String, dynamic> json) {
    return CarteraVisita(
      id: json['id'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      clienteNombre: json['cliente_nombre'] ?? '',
      clienteTelefono: json['cliente_telefono'],
      clienteDireccion: json['cliente_direccion'],
      montoAnterior: (json['monto_anterior'] as num?)?.toDouble(),
      producto: json['producto'],
      tipoVisita: json['tipo_visita'] ?? 'seguimiento',
      prioridad: json['prioridad'] ?? 'media',
      resultado: json['resultado'],
      observacion: json['observacion'],
      fechaAsignacion: DateTime.parse(json['fecha_asignacion']),
      fechaVisita: json['fecha_visita'] != null
          ? DateTime.tryParse(json['fecha_visita'])
          : null,
      sincronizado: json['sincronizado'] ?? false,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cliente_id': clienteId,
    'cliente_nombre': clienteNombre,
    'cliente_telefono': clienteTelefono,
    'cliente_direccion': clienteDireccion,
    'monto_anterior': montoAnterior,
    'producto': producto,
    'tipo_visita': tipoVisita,
    'prioridad': prioridad,
    'resultado': resultado,
    'observacion': observacion,
    'fecha_asignacion': fechaAsignacion.toIso8601String(),
    'fecha_visita': fechaVisita?.toIso8601String(),
    'sincronizado': sincronizado,
    'lat': lat,
    'lng': lng,
  };
}
