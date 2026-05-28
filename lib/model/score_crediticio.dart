class ScoreCrediticio {
  final String userId;
  final double score;
  final String segmento;
  final String recomendacion;
  final double montoMaxSugerido;

  ScoreCrediticio({
    required this.userId,
    required this.score,
    required this.segmento,
    required this.recomendacion,
    required this.montoMaxSugerido,
  });

  factory ScoreCrediticio.fromMap(Map<String, dynamic> map) {
    return ScoreCrediticio(
      userId: map['user_id']?.toString() ?? '',
      score: (map['score'] ?? 0).toDouble(),
      segmento: map['segmento']?.toString() ?? 'C',
      recomendacion: map['recomendacion']?.toString() ?? '',
      montoMaxSugerido: (map['monto_max_sugerido'] ?? 0).toDouble(),
    );
  }

  String get segmentoLabel {
    switch (segmento) {
      case 'A': return 'BBVA Premium';
      case 'B': return 'BBVA Oro';
      case 'C': return 'BBVA Plata';
      case 'D': return 'BBVA Bronce';
      case 'E': return 'Alto Riesgo';
      default: return segmento;
    }
  }
}
