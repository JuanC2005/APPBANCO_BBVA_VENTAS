class Ejecutivo {
  final String id;
  final String codigoEjecutivo;
  final String email;
  final String nombre;
  final String apellido;
  final String sucursalId;
  final String especialidad;
  final String zonaAsignada;
  final int metaVisitasMes;
  final int metaCreditosMes;
  final double metaMontoMes;
  final int visitasMesActual;
  final int creditosMesActual;
  final double montoMesActual;

  Ejecutivo({
    required this.id,
    required this.codigoEjecutivo,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.sucursalId,
    required this.especialidad,
    required this.zonaAsignada,
    required this.metaVisitasMes,
    required this.metaCreditosMes,
    required this.metaMontoMes,
    required this.visitasMesActual,
    required this.creditosMesActual,
    required this.montoMesActual,
  });

  factory Ejecutivo.fromMap(Map<String, dynamic> map) {
    return Ejecutivo(
      id: map['id']?.toString() ?? '',
      codigoEjecutivo: map['codigo_ejecutivo']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      apellido: map['apellido']?.toString() ?? '',
      sucursalId: map['sucursal_id']?.toString() ?? '',
      especialidad: map['especialidad']?.toString() ?? '',
      zonaAsignada: map['zona_asignada']?.toString() ?? '',
      metaVisitasMes: map['meta_visitas_mes'] ?? 0,
      metaCreditosMes: map['meta_creditos_mes'] ?? 0,
      metaMontoMes: (map['meta_monto_mes'] ?? 0).toDouble(),
      visitasMesActual: map['visitas_mes_actual'] ?? 0,
      creditosMesActual: map['creditos_mes_actual'] ?? 0,
      montoMesActual: (map['monto_mes_actual'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo_ejecutivo': codigoEjecutivo,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'sucursal_id': sucursalId,
      'especialidad': especialidad,
      'zona_asignada': zonaAsignada,
      'meta_visitas_mes': metaVisitasMes,
      'meta_creditos_mes': metaCreditosMes,
      'meta_monto_mes': metaMontoMes,
      'visitas_mes_actual': visitasMesActual,
      'creditos_mes_actual': creditosMesActual,
      'monto_mes_actual': montoMesActual,
    };
  }

  String get nombreCompleto => '$nombre $apellido';
}
