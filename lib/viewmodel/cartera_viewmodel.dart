import 'package:flutter/material.dart';
import '../model/client.dart';

class CarteraViewModel extends ChangeNotifier {
  final List<Client> clients = [
    Client(name: "Ana López", gestionType: "Renovación", status: "Pendiente"),
    Client(name: "Carlos Ruiz", gestionType: "Nuevo", status: "Visitado"),
    Client(
      name: "María González",
      gestionType: "Cobranza",
      status: "Pendiente",
    ),
    Client(
      name: "Pedro Sánchez",
      gestionType: "Renovación",
      status: "Visitado",
    ),
    Client(name: "Laura Martínez", gestionType: "Nuevo", status: "Pendiente"),
  ];

  int get totalVisits => clients.length;
}
