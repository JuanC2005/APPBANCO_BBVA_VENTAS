class Campana {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String segmentoObjetivo;
  final String? productoSugerido;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activa;
  final bool leida;
  final DateTime createdAt;

  Campana({
    required this.id,
    required this.titulo,
    required this.mensaje,
    this.tipo = 'marketing',
    this.segmentoObjetivo = 'TODOS',
    this.productoSugerido,
    required this.fechaInicio,
    this.fechaFin,
    this.activa = true,
    this.leida = false,
    required this.createdAt,
  });

  factory Campana.fromJson(Map<String, dynamic> json) {
    return Campana(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: json['tipo'] ?? 'marketing',
      segmentoObjetivo: json['segmento_objetivo'] ?? 'TODOS',
      productoSugerido: json['producto_sugerido'],
      fechaInicio: DateTime.tryParse(json['fecha_inicio'] ?? '') ??
          DateTime.now(),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.tryParse(json['fecha_fin'])
          : null,
      activa: json['activa'] ?? true,
      leida: json['leida'] ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'mensaje': mensaje,
    'tipo': tipo,
    'segmento_objetivo': segmentoObjetivo,
    'producto_sugerido': productoSugerido,
    'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
    'fecha_fin': fechaFin?.toIso8601String().split('T')[0],
    'activa': activa,
  };
}
