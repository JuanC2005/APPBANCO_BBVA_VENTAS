class Credito {
  final String id;
  final String clienteId;
  final String producto;
  final double montoDesembolsado;
  final int plazoMeses;
  final double tea;
  final int cuotasTotales;
  final int cuotasPagadas;
  final int cuotasMora;
  final double saldoActual;
  final String estado;
  final DateTime? fechaDesembolso;

  Credito({
    required this.id,
    required this.clienteId,
    this.producto = 'credito_negocios',
    this.montoDesembolsado = 0,
    this.plazoMeses = 12,
    this.tea = 18.0,
    this.cuotasTotales = 12,
    this.cuotasPagadas = 0,
    this.cuotasMora = 0,
    this.saldoActual = 0,
    this.estado = 'vigente',
    this.fechaDesembolso,
  });

  String get estadoLabel {
    switch (estado) {
      case 'vigente': return 'Vigente';
      case 'vencido': return 'Vencido';
      case 'castigado': return 'Castigado';
      case 'pagado': return 'Pagado';
      default: return estado;
    }
  }

  String get productLabel {
    switch (producto) {
      case 'credito_negocios': return 'Crédito Negocios';
      case 'credito_efectivo': return 'Crédito Efectivo';
      case 'credito_agropecuario': return 'Crédito Agropecuario';
      case 'leasing': return 'Leasing';
      case 'tarjeta_credito': return 'Tarjeta Crédito';
      case 'hipotecario': return 'Hipotecario';
      default: return producto;
    }
  }

  factory Credito.fromJson(Map<String, dynamic> json) {
    return Credito(
      id: json['id'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      producto: json['producto'] ?? 'credito_negocios',
      montoDesembolsado: (json['monto_desembolsado'] as num?)?.toDouble() ?? 0,
      plazoMeses: (json['plazo_meses'] as num?)?.toInt() ?? 12,
      tea: (json['tea'] as num?)?.toDouble() ?? 18.0,
      cuotasTotales: (json['cuotas_totales'] as num?)?.toInt() ?? 12,
      cuotasPagadas: (json['cuotas_pagadas'] as num?)?.toInt() ?? 0,
      cuotasMora: (json['cuotas_mora'] as num?)?.toInt() ?? 0,
      saldoActual: (json['saldo_actual'] as num?)?.toDouble() ?? 0,
      estado: json['estado'] ?? 'vigente',
      fechaDesembolso: json['fecha_desembolso'] != null
          ? DateTime.tryParse(json['fecha_desembolso'])
          : null,
    );
  }
}
