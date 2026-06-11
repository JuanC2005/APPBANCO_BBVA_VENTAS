import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class MoraListaScreen extends StatelessWidget {
  const MoraListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cobranza - Mora')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _clienteMora(context, 'Pedro Sánchez', 'S/ 2,500', '15 días', BBVAColors.moraAmarillo),
          _clienteMora(context, 'Ana Torres', 'S/ 4,000', '35 días', BBVAColors.moraNaranja),
          _clienteMora(context, 'Luis García', 'S/ 6,000', '65 días', BBVAColors.moraRojo),
        ],
      ),
    );
  }

  Widget _clienteMora(BuildContext context, String nombre, String deuda, String dias, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(50),
          child: Text(nombre[0], style: TextStyle(color: color)),
        ),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Deuda: $deuda · Atraso: $dias'),
        trailing: Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        onTap: () => context.push('/accion-cobranza/pedro-sanchez'),
      ),
    );
  }
}
