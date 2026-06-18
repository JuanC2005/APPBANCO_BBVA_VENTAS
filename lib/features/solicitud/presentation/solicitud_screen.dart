import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'solicitud_viewmodel.dart';

class SolicitudScreen extends ConsumerStatefulWidget {
  final String clienteId;
  const SolicitudScreen({super.key, required this.clienteId});

  @override
  ConsumerState<SolicitudScreen> createState() => _SolicitudScreenState();
}

class _SolicitudScreenState extends ConsumerState<SolicitudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(solicitudViewModelProvider.notifier).iniciar(widget.clienteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solicitudViewModelProvider);
    final s = state.solicitud;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Solicitud')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : s == null
                  ? const Center(child: Text('Error al crear borrador'))
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Solicitud de Crédito',
                              style: TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          _stepItem('Paso 1', 'Datos del Solicitante',
                              state.pasoActual >= 1,
                              state.pasoActual > 1,
                              () => context.push(
                                  '/solicitud/paso1/${s.id}')),
                          _stepItem('Paso 2', 'Datos del Negocio',
                              state.pasoActual >= 2,
                              state.pasoActual > 2,
                              state.pasoActual >= 2
                                  ? () => context.push(
                                      '/solicitud/paso2/${s.id}')
                                  : null),
                          _stepItem('Paso 3', 'Condiciones del Crédito',
                              state.pasoActual >= 3,
                              state.pasoActual > 3,
                              state.pasoActual >= 3
                                  ? () => context.push(
                                      '/solicitud/paso3/${s.id}')
                                  : null),
                          _stepItem('Paso 4', 'Confirmación y Firma',
                              state.pasoActual >= 4,
                              state.pasoActual > 4,
                              state.pasoActual >= 4
                                  ? () => context.push(
                                      '/solicitud/paso4/${s.id}')
                                  : null),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Borrador guardado')),
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Borrador'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => context.push('/simulador'),
                            icon: const Icon(Icons.calculate),
                            label: const Text('Abrir Simulador'),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _stepItem(String paso, String titulo, bool activo, bool completado,
      VoidCallback? onTap) {
    final color = completado
        ? BBVAColors.successGreen
        : activo
            ? BBVAColors.primaryBlue
            : BBVAColors.mediumGray;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(
            completado ? Icons.check_circle : Icons.circle_outlined,
            color: color,
          ),
        ),
        title: Text('$paso: $titulo'),
        subtitle: Text(
            completado ? 'Completado' : activo ? 'Pendiente' : 'Bloqueado',
            style: TextStyle(color: color)),
        trailing: activo ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
