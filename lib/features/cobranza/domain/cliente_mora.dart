class ClienteMora {
  final String clienteId;
  final String clienteNombre;
  final String? numeroDocumento;
  final String creditoId;
  final double deuda;
  final int diasMora;
  final String? direccion;
  final double? lat;
  final double? lng;

  ClienteMora({
    required this.clienteId,
    required this.clienteNombre,
    this.numeroDocumento,
    required this.creditoId,
    this.deuda = 0,
    this.diasMora = 0,
    this.direccion,
    this.lat,
    this.lng,
  });

  factory ClienteMora.fromJson(Map<String, dynamic> json) {
    return ClienteMora(
      clienteId: json['cliente_id'] ?? '',
      clienteNombre: json['cliente_nombre'] ?? '',
      numeroDocumento: json['numero_documento'],
      creditoId: json['credito_id'] ?? '',
      deuda: (json['saldo_actual'] as num?)?.toDouble() ?? 0,
      diasMora: (json['dias_mora'] as num?)?.toInt() ?? 0,
      direccion: json['direccion'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
