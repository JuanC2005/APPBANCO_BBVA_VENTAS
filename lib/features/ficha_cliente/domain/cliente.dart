class Cliente {
  final String id;
  final String tipoDocumento;
  final String numeroDocumento;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? distrito;
  final String? provincia;
  final String? departamento;
  final String? referencia;
  final double? lat;
  final double? lng;
  final String asesorId;
  final DateTime fechaRegistro;
  final String? estadoCivil;
  final String? tipoVivienda;
  final DateTime? fechaNacimiento;
  final String? ocupacion;
  final double? ingresosMensuales;

  Cliente({
    required this.id,
    this.tipoDocumento = 'DNI',
    required this.numeroDocumento,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    this.telefono,
    this.email,
    this.direccion,
    this.distrito,
    this.provincia,
    this.departamento,
    this.referencia,
    this.lat,
    this.lng,
    required this.asesorId,
    required this.fechaRegistro,
    this.estadoCivil,
    this.tipoVivienda,
    this.fechaNacimiento,
    this.ocupacion,
    this.ingresosMensuales,
  });

  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? '',
      tipoDocumento: json['tipo_documento'] ?? 'DNI',
      numeroDocumento: json['numero_documento'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      telefono: json['telefono'],
      email: json['email'],
      direccion: json['direccion'],
      distrito: json['distrito'],
      provincia: json['provincia'],
      departamento: json['departamento'],
      referencia: json['referencia'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      asesorId: json['asesor_id'] ?? '',
      fechaRegistro: DateTime.parse(json['fecha_registro'] ?? DateTime.now().toIso8601String()),
      estadoCivil: json['estado_civil'],
      tipoVivienda: json['tipo_vivienda'],
      fechaNacimiento: json['fecha_nacimiento'] != null ? DateTime.tryParse(json['fecha_nacimiento']) : null,
      ocupacion: json['ocupacion'],
      ingresosMensuales: (json['ingresos_mensuales'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo_documento': tipoDocumento,
    'numero_documento': numeroDocumento,
    'nombres': nombres,
    'apellido_paterno': apellidoPaterno,
    'apellido_materno': apellidoMaterno,
    'telefono': telefono,
    'email': email,
    'direccion': direccion,
    'distrito': distrito,
    'provincia': provincia,
    'departamento': departamento,
    'referencia': referencia,
    'lat': lat,
    'lng': lng,
    'asesor_id': asesorId,
    'fecha_registro': fechaRegistro.toIso8601String(),
    'estado_civil': estadoCivil,
    'tipo_vivienda': tipoVivienda,
    'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
    'ocupacion': ocupacion,
    'ingresos_mensuales': ingresosMensuales,
  };
}
