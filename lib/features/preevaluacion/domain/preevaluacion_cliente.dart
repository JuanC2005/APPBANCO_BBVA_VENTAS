class PreevaluacionCliente {
  final String clienteId;
  final String clienteNombre;
  final String? numeroDocumento;
  final double score;
  final String segmento;
  final double? montoMaxSugerido;
  final String recomendacion;
  final double? ingresoMensual;
  final String? calificacionSbs;
  final DateTime? calculadoAt;

  PreevaluacionCliente({
    required this.clienteId,
    required this.clienteNombre,
    this.numeroDocumento,
    required this.score,
    required this.segmento,
    this.montoMaxSugerido,
    required this.recomendacion,
    this.ingresoMensual,
    this.calificacionSbs,
    this.calculadoAt,
  });

  factory PreevaluacionCliente.fromJson(Map<String, dynamic> json) {
    return PreevaluacionCliente(
      clienteId: json['cliente_id'] ?? json['id'] ?? '',
      clienteNombre: json['cliente_nombre'] ?? '',
      numeroDocumento: json['numero_documento'],
      score: (json['score'] as num?)?.toDouble() ?? 0,
      segmento: json['segmento'] ?? 'C',
      montoMaxSugerido: (json['monto_max_sugerido'] as num?)?.toDouble(),
      recomendacion: json['recomendacion'] ?? 'evaluar_presencial',
      ingresoMensual: (json['ingreso_mensual_est'] as num?)?.toDouble(),
      calificacionSbs: json['calificacion_sbs'],
      calculadoAt: json['calculado_at'] != null
          ? DateTime.tryParse(json['calculado_at'])
          : null,
    );
  }
}
