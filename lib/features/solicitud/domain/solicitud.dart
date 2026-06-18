class SolicitudCredito {
  final String id;
  final String? numeroExpediente;
  final String asesorId;
  final String clienteId;
  final String? agenciaId;
  final String? carteraId;
  final String? tipoNegocio;
  final String? nombreNegocio;
  final String? actividadEconomica;
  final int? antiguedadNegocioMeses;
  final bool tieneConyuge;
  final Map<String, dynamic>? conyugeJson;
  final bool tieneGarante;
  final Map<String, dynamic>? garanteJson;
  final double? ingresosEstimados;
  final double? gastosMensuales;
  final double? patrimonioEstimado;
  final String? destinoCredito;
  final double montoSolicitado;
  final int plazoMeses;
  final String moneda;
  final String tipoCuota;
  final String garantia;
  final double? cuotaEstimada;
  final double? teaReferencial;
  final String? firmaClienteBase64;
  final String estado;
  final double? montoAprobado;
  final String? motivoRechazo;
  final String? condicionAdicional;
  final String? analistaAsignado;
  final double? latCaptura;
  final double? lngCaptura;
  final bool pendienteSync;
  final DateTime createdAt;
  final DateTime updatedAt;

  SolicitudCredito({
    required this.id,
    this.numeroExpediente,
    required this.asesorId,
    required this.clienteId,
    this.agenciaId,
    this.carteraId,
    this.tipoNegocio,
    this.nombreNegocio,
    this.actividadEconomica,
    this.antiguedadNegocioMeses,
    this.tieneConyuge = false,
    this.conyugeJson,
    this.tieneGarante = false,
    this.garanteJson,
    this.ingresosEstimados,
    this.gastosMensuales,
    this.patrimonioEstimado,
    this.destinoCredito,
    this.montoSolicitado = 0,
    this.plazoMeses = 12,
    this.moneda = 'PEN',
    this.tipoCuota = 'mensual',
    this.garantia = 'sin_garantia',
    this.cuotaEstimada,
    this.teaReferencial,
    this.firmaClienteBase64,
    this.estado = 'borrador',
    this.montoAprobado,
    this.motivoRechazo,
    this.condicionAdicional,
    this.analistaAsignado,
    this.latCaptura,
    this.lngCaptura,
    this.pendienteSync = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get estadoLabel {
    switch (estado) {
      case 'borrador': return 'Borrador';
      case 'enviado': return 'Enviado';
      case 'recibido_comite': return 'Recibido Comité';
      case 'en_evaluacion': return 'En Evaluación';
      case 'aprobado': return 'Aprobado';
      case 'condicionado': return 'Condicionado';
      case 'rechazado': return 'Rechazado';
      case 'desembolsado': return 'Desembolsado';
      default: return estado;
    }
  }

  factory SolicitudCredito.fromJson(Map<String, dynamic> json) {
    return SolicitudCredito(
      id: json['id'] ?? '',
      numeroExpediente: json['numero_expediente'],
      asesorId: json['asesor_id'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      agenciaId: json['agencia_id'],
      carteraId: json['cartera_id'],
      tipoNegocio: json['tipo_negocio'],
      nombreNegocio: json['nombre_negocio'],
      actividadEconomica: json['actividad_economica'],
      antiguedadNegocioMeses: (json['antiguedad_negocio_meses'] as num?)?.toInt(),
      tieneConyuge: json['tiene_conyuge'] ?? false,
      conyugeJson: json['conyuge_json'],
      tieneGarante: json['tiene_garante'] ?? false,
      garanteJson: json['garante_json'],
      ingresosEstimados: (json['ingresos_estimados'] as num?)?.toDouble(),
      gastosMensuales: (json['gastos_mensuales'] as num?)?.toDouble(),
      patrimonioEstimado: (json['patrimonio_estimado'] as num?)?.toDouble(),
      destinoCredito: json['destino_credito'],
      montoSolicitado: (json['monto_solicitado'] as num?)?.toDouble() ?? 0,
      plazoMeses: (json['plazo_meses'] as num?)?.toInt() ?? 12,
      moneda: json['moneda'] ?? 'PEN',
      tipoCuota: json['tipo_cuota'] ?? 'mensual',
      garantia: json['garantia'] ?? 'sin_garantia',
      cuotaEstimada: (json['cuota_estimada'] as num?)?.toDouble(),
      teaReferencial: (json['tea_referencial'] as num?)?.toDouble(),
      firmaClienteBase64: json['firma_cliente_base64'],
      estado: json['estado'] ?? 'borrador',
      montoAprobado: (json['monto_aprobado'] as num?)?.toDouble(),
      motivoRechazo: json['motivo_rechazo'],
      condicionAdicional: json['condicion_adicional'],
      analistaAsignado: json['analista_asignado'],
      latCaptura: (json['lat_captura'] as num?)?.toDouble(),
      lngCaptura: (json['lng_captura'] as num?)?.toDouble(),
      pendienteSync: json['pendiente_sync'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'numero_expediente': numeroExpediente,
    'asesor_id': asesorId,
    'cliente_id': clienteId,
    'agencia_id': agenciaId,
    'cartera_id': carteraId,
    'tipo_negocio': tipoNegocio,
    'nombre_negocio': nombreNegocio,
    'actividad_economica': actividadEconomica,
    'antiguedad_negocio_meses': antiguedadNegocioMeses,
    'tiene_conyuge': tieneConyuge,
    'conyuge_json': conyugeJson,
    'tiene_garante': tieneGarante,
    'garante_json': garanteJson,
    'ingresos_estimados': ingresosEstimados,
    'gastos_mensuales': gastosMensuales,
    'patrimonio_estimado': patrimonioEstimado,
    'destino_credito': destinoCredito,
    'monto_solicitado': montoSolicitado,
    'plazo_meses': plazoMeses,
    'moneda': moneda,
    'tipo_cuota': tipoCuota,
    'garantia': garantia,
    'cuota_estimada': cuotaEstimada,
    'tea_referencial': teaReferencial,
    'firma_cliente_base64': firmaClienteBase64,
    'estado': estado,
    'monto_aprobado': montoAprobado,
    'motivo_rechazo': motivoRechazo,
    'condicion_adicional': condicionAdicional,
    'analista_asignado': analistaAsignado,
    'lat_captura': latCaptura,
    'lng_captura': lngCaptura,
    'pendiente_sync': pendienteSync,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
