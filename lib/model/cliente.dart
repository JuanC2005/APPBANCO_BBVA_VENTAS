class Cliente {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String tipoNegocio;
  final String zonaNegocio;
  final double ingresoMensual;
  final double gastoMensual;
  final double deudaActual;
  final String estadoCliente;
  final double puntajeCrediticio;

  Cliente({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.tipoNegocio,
    required this.zonaNegocio,
    required this.ingresoMensual,
    required this.gastoMensual,
    required this.deudaActual,
    required this.estadoCliente,
    required this.puntajeCrediticio,
  });

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['user_id']?.toString() ?? map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      nombre: map['nombres']?.toString() ?? '',
      apellido: map['apellidos']?.toString() ?? '',
      tipoNegocio: map['tipo_negocio']?.toString() ?? '',
      zonaNegocio: map['zona_negocio']?.toString() ?? '',
      ingresoMensual: (map['ingreso_mensual_est'] ?? 0).toDouble(),
      gastoMensual: (map['gasto_mensual_est'] ?? 0).toDouble(),
      deudaActual: (map['deuda_actual'] ?? 0).toDouble(),
      estadoCliente: map['estado_cliente']?.toString() ?? 'prospecto',
      puntajeCrediticio: (map['puntaje_crediticio'] ?? 0).toDouble(),
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}
