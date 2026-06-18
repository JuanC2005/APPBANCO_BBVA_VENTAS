class CarteraVisita {
  final String id;
  final String asesorId;
  final String clienteId;
  final DateTime fechaAsignacion;
  final String tipoGestion;
  final String prioridad;
  final int scorePrioridad;
  final double? montoReferencial;
  final String? estadoVisita;
  final String? resultadoVisita;
  final String? observacionVisita;
  final DateTime? timestampVisita;
  final double? latVisita;
  final double? lngVisita;
  final int? ordenManual;

  final String clienteNombre;
  final String? numeroDocumento;
  final String? tipoNegocio;
  final String? nombreNegocio;
  final String? telefono;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? calificacionSbs;
  final String? estadoCliente;
  final int scoreCrediticio;
  final String segmento;
  final double? montoPreaprobado;
  final int? plazoSugerido;

  CarteraVisita({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    required this.fechaAsignacion,
    required this.tipoGestion,
    required this.prioridad,
    this.scorePrioridad = 0,
    this.montoReferencial,
    this.estadoVisita,
    this.resultadoVisita,
    this.observacionVisita,
    this.timestampVisita,
    this.latVisita,
    this.lngVisita,
    this.ordenManual,
    required this.clienteNombre,
    this.numeroDocumento,
    this.tipoNegocio,
    this.nombreNegocio,
    this.telefono,
    this.direccion,
    this.lat,
    this.lng,
    this.calificacionSbs,
    this.estadoCliente,
    this.scoreCrediticio = 0,
    this.segmento = 'N/A',
    this.montoPreaprobado,
    this.plazoSugerido,
  });

  String get prioridadLabel {
    switch (prioridad.toLowerCase()) {
      case 'alta': return 'ALTA';
      case 'media': return 'MEDIA';
      case 'normal': return 'NORMAL';
      default: return prioridad;
    }
  }

  bool get visitado => resultadoVisita != null;

  factory CarteraVisita.fromJson(Map<String, dynamic> json) {
    return CarteraVisita(
      id: json['cartera_id'] ?? json['id'] ?? '',
      asesorId: json['asesor_id'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      fechaAsignacion: DateTime.parse(
          (json['fecha_asignacion'] ?? DateTime.now().toIso8601String())
              .toString()),
      tipoGestion: json['tipo_gestion'] ?? 'SEGUIMIENTO',
      prioridad: json['prioridad'] ?? 'normal',
      scorePrioridad: (json['score_prioridad'] as num?)?.toInt() ?? 0,
      montoReferencial: (json['monto_referencial'] as num?)?.toDouble(),
      estadoVisita: json['estado_visita'],
      resultadoVisita: json['resultado_visita'],
      observacionVisita: json['observacion_visita'],
      timestampVisita: json['timestamp_visita'] != null
          ? DateTime.tryParse(json['timestamp_visita'])
          : null,
      latVisita: (json['lat_visita'] as num?)?.toDouble(),
      lngVisita: (json['lng_visita'] as num?)?.toDouble(),
      ordenManual: (json['orden_manual'] as num?)?.toInt(),
      clienteNombre: json['cliente_nombre'] ?? '',
      numeroDocumento: json['numero_documento'],
      tipoNegocio: json['tipo_negocio'],
      nombreNegocio: json['nombre_negocio'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      calificacionSbs: json['calificacion_sbs'],
      estadoCliente: json['estado_cliente'],
      scoreCrediticio: (json['score_crediticio'] as num?)?.toInt() ?? 0,
      segmento: json['segmento'] ?? 'N/A',
      montoPreaprobado: (json['monto_preaprobado'] as num?)?.toDouble(),
      plazoSugerido: (json['plazo_sugerido_meses'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'asesor_id': asesorId,
    'cliente_id': clienteId,
    'fecha_asignacion': fechaAsignacion.toIso8601String(),
    'tipo_gestion': tipoGestion,
    'prioridad': prioridad,
    'score_prioridad': scorePrioridad,
    'monto_referencial': montoReferencial,
    'estado_visita': estadoVisita,
    'resultado_visita': resultadoVisita,
    'observacion_visita': observacionVisita,
    'timestamp_visita': timestampVisita?.toIso8601String(),
    'lat_visita': latVisita,
    'lng_visita': lngVisita,
    'orden_manual': ordenManual,
    'cliente_nombre': clienteNombre,
    'numero_documento': numeroDocumento,
    'tipo_negocio': tipoNegocio,
    'nombre_negocio': nombreNegocio,
    'telefono': telefono,
    'direccion': direccion,
    'lat': lat,
    'lng': lng,
    'calificacion_sbs': calificacionSbs,
    'estado_cliente': estadoCliente,
    'score_crediticio': scoreCrediticio,
    'segmento': segmento,
    'monto_preaprobado': montoPreaprobado,
    'plazo_sugerido_meses': plazoSugerido,
  };
}
