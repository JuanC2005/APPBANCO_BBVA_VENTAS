class Preaprobado {
  final String id;
  final double montoMaximo;
  final int plazoSugeridoMeses;
  final double teaReferencial;
  final bool vigente;
  final DateTime fechaCalculo;

  Preaprobado({
    required this.id,
    this.montoMaximo = 0,
    this.plazoSugeridoMeses = 12,
    this.teaReferencial = 15.0,
    this.vigente = true,
    DateTime? fechaCalculo,
  }) : fechaCalculo = fechaCalculo ?? DateTime.now();

  factory Preaprobado.fromJson(Map<String, dynamic> json) {
    return Preaprobado(
      id: json['id'] ?? '',
      montoMaximo: (json['monto_maximo'] as num?)?.toDouble() ?? 0,
      plazoSugeridoMeses: (json['plazo_sugerido_meses'] as num?)?.toInt() ?? 12,
      teaReferencial: (json['tea_referencial'] as num?)?.toDouble() ?? 15.0,
      vigente: json['vigente'] ?? true,
      fechaCalculo: json['fecha_calculo'] != null
          ? DateTime.tryParse(json['fecha_calculo'])
          : null,
    );
  }
}
