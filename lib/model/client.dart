class Client {
  final String name;
  final String gestionType; // renovacion, nuevo, cobranza
  final String status; // pendiente, visitado

  Client({required this.name, required this.gestionType, required this.status});
}
