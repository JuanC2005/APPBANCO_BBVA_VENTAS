import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/cartera_viewmodel.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/typography.dart';

class CarteraDiariaScreen extends StatefulWidget {
  const CarteraDiariaScreen({super.key});

  @override
  State<CarteraDiariaScreen> createState() => _CarteraDiariaScreenState();
}

class _CarteraDiariaScreenState extends State<CarteraDiariaScreen> {
  @override
  void initState() {
    super.initState();
    final ejecutivo = context.read<AuthOficialViewModel>().ejecutivo;
    if (ejecutivo != null) {
      context.read<CarteraViewModel>().cargarFichas(ejecutivo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carteraViewModel = Provider.of<CarteraViewModel>(context);
    final authViewModel = Provider.of<AuthOficialViewModel>(context);

    return Scaffold(
      backgroundColor: BBVAColors.white,
      appBar: AppBar(
        title: Text(
          'Cartera Diaria',
          style: BBVATypography.titleMedium.copyWith(color: BBVAColors.white),
        ),
        backgroundColor: BBVAColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: BBVAColors.white),
            onPressed: () {
              if (context.mounted) {
                GoRouter.of(context).go('/');
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
                  'Ejecutivo: ${authViewModel.ejecutivo?.nombreCompleto ?? ''}',
                  style: BBVATypography.bodySmall,
                ),
                Text(
                  'Total: ${carteraViewModel.totalVisits} visitas',
                  style: BBVATypography.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: carteraViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: carteraViewModel.fichas.length,
                    itemBuilder: (context, index) {
                      final ficha = carteraViewModel.fichas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 4,
                        color: BBVAColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: BBVAColors.primaryBlue,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            ficha.negocioNombre ?? ficha.nombreCliente,
                            style: BBVATypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                'Tipo: ${ficha.tipoVisita}',
                                style: BBVATypography.bodySmall,
                              ),
                              Text(
                                'Distrito: ${ficha.distrito}',
                                style: BBVATypography.bodySmall,
                              ),
                              if (ficha.montoSolicitado > 0)
                                Text(
                                  'Monto: S/ ${ficha.montoSolicitado.toStringAsFixed(0)}',
                                  style: BBVATypography.bodySmall,
                                ),
                              Text(
                                'Estado: ${ficha.estadoFicha}',
                                style: BBVATypography.bodySmall.copyWith(
                                  color: ficha.estadoFicha == 'completada'
                                      ? Colors.green
                                      : BBVAColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            ficha.estadoFicha == 'completada'
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            color: ficha.estadoFicha == 'completada'
                                ? Colors.green
                                : BBVAColors.errorRed,
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
