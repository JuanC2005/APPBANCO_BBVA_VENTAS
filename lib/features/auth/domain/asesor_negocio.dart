class AsesorNegocio {
  final String id;
  final String codigoEmpleado;
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String perfil;
  final String agenciaId;
  final String? userId;
  final bool activo;
  final DateTime? ultimoAcceso;

  AsesorNegocio({
    this.id = '',
    required this.codigoEmpleado,
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.perfil,
    required this.agenciaId,
    this.userId,
    this.activo = true,
    this.ultimoAcceso,
  });

  String get nombreCompleto => '$nombres $apellidos';
  bool get esAdmin => perfil == 'admin';
  bool get esSupervisor => perfil == 'supervisor';
  bool get esOperador => perfil == 'operador';

  factory AsesorNegocio.fromJson(Map<String, dynamic> json) {
    return AsesorNegocio(
      id: json['id'] ?? '',
      codigoEmpleado: json['codigo_empleado'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      perfil: json['perfil'] ?? 'operador',
      agenciaId: json['agencia_id'] ?? '',
      userId: json['user_id'],
      activo: json['activo'] ?? true,
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.tryParse(json['ultimo_acceso'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'codigo_empleado': codigoEmpleado,
    'nombres': nombres,
    'apellidos': apellidos,
    'email': email,
    'telefono': telefono,
    'perfil': perfil,
    'agencia_id': agenciaId,
    'user_id': userId,
    'activo': activo,
    'ultimo_acceso': ultimoAcceso?.toIso8601String(),
  };
}
