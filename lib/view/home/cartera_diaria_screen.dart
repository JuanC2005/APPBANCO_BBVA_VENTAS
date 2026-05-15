import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/cartera_viewmodel.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/typography.dart';

class CarteraDiariaScreen extends StatelessWidget {
  const CarteraDiariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carteraViewModel = Provider.of<CarteraViewModel>(context);

    return Scaffold(
      backgroundColor: BBVAColors.white, // ✅ FONDO BLANCO
      appBar: AppBar(
        title: Text(
          'Cartera Diaria',
          style: BBVATypography.titleMedium.copyWith(color: BBVAColors.white),
        ),
        backgroundColor: BBVAColors.primaryBlue, // ✅ Barra azul BBVA
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: BBVAColors.white),
            onPressed: () {
              if (context.mounted) {
                GoRouter.of(context).push('/');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total de visitas hoy: ${carteraViewModel.totalVisits}',
                  style: BBVATypography.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: carteraViewModel.clients.length,
              itemBuilder: (context, index) {
                final client = carteraViewModel.clients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  color: BBVAColors.white, // ✅ Fondo blanco para tarjetas
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: BBVAColors.primaryBlue, // ✅ Borde azul
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      client.name,
                      style: BBVATypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Tipo de gestión: ${client.gestionType}',
                          style: BBVATypography.bodySmall,
                        ),
                        Text(
                          'Estado: ${client.status}',
                          style: BBVATypography.bodySmall.copyWith(
                            color: client.status == "Pendiente"
                                ? BBVAColors.errorRed
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      client.status == "Pendiente"
                          ? Icons.pending_actions
                          : Icons.check_circle,
                      color: client.status == "Pendiente"
                          ? BBVAColors.errorRed
                          : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
