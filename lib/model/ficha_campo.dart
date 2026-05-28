class FichaCampo {
  final String id;
  final String ejecutivoId;
  final String? clienteUserId;
  final String? prospectoNombre;
  final String distrito;
  final String tipoVisita;
  final String? negocioNombre;
  final String? negocioRubro;
  final double ingresoDeclarado;
  final double gastoDeclarado;
  final String estadoFicha;
  final double scoreObtenido;
  final double montoSolicitado;
  final String? observaciones;
  final bool creadaOffline;

  FichaCampo({
    required this.id,
    required this.ejecutivoId,
    this.clienteUserId,
    this.prospectoNombre,
    required this.distrito,
    required this.tipoVisita,
    this.negocioNombre,
    this.negocioRubro,
    required this.ingresoDeclarado,
    required this.gastoDeclarado,
    required this.estadoFicha,
    required this.scoreObtenido,
    required this.montoSolicitado,
    this.observaciones,
    required this.creadaOffline,
  });

  factory FichaCampo.fromMap(Map<String, dynamic> map) {
    return FichaCampo(
      id: map['id']?.toString() ?? '',
      ejecutivoId: map['ejecutivo_id']?.toString() ?? '',
      clienteUserId: map['cliente_user_id']?.toString(),
      prospectoNombre: map['prospecto_nombre']?.toString(),
      distrito: map['distrito']?.toString() ?? '',
      tipoVisita: map['tipo_visita']?.toString() ?? '',
      negocioNombre: map['negocio_nombre']?.toString(),
      negocioRubro: map['negocio_rubro']?.toString(),
      ingresoDeclarado: (map['ingreso_declarado'] ?? 0).toDouble(),
      gastoDeclarado: (map['gasto_declarado'] ?? 0).toDouble(),
      estadoFicha: map['estado_ficha']?.toString() ?? 'borrador',
      scoreObtenido: (map['score_obtenido'] ?? 0).toDouble(),
      montoSolicitado: (map['monto_solicitado'] ?? 0).toDouble(),
      observaciones: map['observaciones']?.toString(),
      creadaOffline: map['creada_offline'] ?? false,
    );
  }

  String get nombreCliente => prospectoNombre ?? 'Cliente registrado';
}
