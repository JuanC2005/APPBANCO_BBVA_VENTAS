import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/network_monitor.dart';
import '../../auth/presentation/login_viewmodel.dart';
import 'cartera_viewmodel.dart';
import '../domain/cartera_visita.dart';

class CarteraScreen extends ConsumerStatefulWidget {
  const CarteraScreen({super.key});

  @override
  ConsumerState<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends ConsumerState<CarteraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final asesor = ref.read(authViewModelProvider).asesor;
      if (asesor != null) {
        ref.read(carteraViewModelProvider.notifier).cargarCartera(asesor.id);
      }
    });
  }

  void _showResultadoDialog(String visitaId) {
    showDialog(
      context: context,
      builder: (ctx) => _ResultadoVisitaDialog(visitaId: visitaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carteraViewModelProvider);
    final isOnline = ref.watch(networkMonitorProvider).isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.carteraDiaria),
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            tooltip: 'Ver ruta',
            onPressed: () => context.push('/ruta'),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Tablero Solicitudes',
            onPressed: () => context.push('/tablero-solicitudes'),
          ),
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Historial Solicitudes',
            onPressed: () => context.push('/historial-solicitudes'),
          ),
          IconButton(
            icon: const Icon(Icons.pending_actions),
            tooltip: 'Solicitudes Pendientes',
            onPressed: () => context.push('/solicitudes-pendientes'),
          ),
          IconButton(
            icon: const Icon(Icons.monetization_on),
            tooltip: 'Simulador',
            onPressed: () => context.push('/simulador'),
          ),
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Mora / Cobranza',
            onPressed: () => context.push('/mora'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final vm = ref.read(authViewModelProvider.notifier);
              final pendientes = await vm.logout(force: false);
              if (pendientes > 0 && context.mounted) {
                final force = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: Text(
                      'Tienes $pendientes solicitudes sin sincronizar. '
                      '¿Cerrar de todas formas?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
                if (force == true && context.mounted) {
                  await vm.logout(force: true);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline)
            Container(
              width: double.infinity,
              color: BBVAColors.warningAmber,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(AppStrings.sinConexion,
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          _buildResumen(state),
          _buildFiltros(state),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : state.visitasFiltradas.isEmpty
                        ? const Center(child: Text('No hay visitas pendientes'))
                        : ListView.builder(
                            itemCount: state.visitasFiltradas.length,
                            itemBuilder: (_, i) {
                              final v = state.visitasFiltradas[i];
                              return _VisitaCard(
                                visita: v,
                                onTap: () => context.push(
                                    '/ficha-cliente/${v.clienteId}'),
                                onResultado: v.esVisita
                                    ? () => _showResultadoDialog(v.id)
                                    : null,
                                onTomar: v.esSolicitudPendiente
                                    ? () async {
                                        final asesor = ref.read(authViewModelProvider).asesor;
                                        if (asesor != null) {
                                          await ref.read(carteraViewModelProvider.notifier)
                                              .tomarSolicitud(asesor.id, v.solicitudId ?? v.id);
                                        }
                                      }
                                    : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumen(CarteraState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: BBVAColors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ResumenItem(
              label: 'Total',
              value: state.totalVisitas.toString(),
              color: BBVAColors.primaryBlue),
          _ResumenItem(
              label: 'Visitados',
              value: state.visitados.toString(),
              color: BBVAColors.successGreen),
          _ResumenItem(
              label: 'Pendientes',
              value: state.pendientes.toString(),
              color: BBVAColors.warningAmber),
        ],
      ),
    );
  }

  Widget _buildFiltros(CarteraState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar cliente...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (v) =>
            ref.read(carteraViewModelProvider.notifier).setFiltroBusqueda(v),
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResumenItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: BBVAColors.darkGray)),
      ],
    );
  }
}

class _VisitaCard extends StatelessWidget {
  final CarteraVisita visita;
  final VoidCallback onTap;
  final VoidCallback? onResultado;
  final VoidCallback? onTomar;

  const _VisitaCard(
      {required this.visita, required this.onTap, this.onResultado, this.onTomar});

  Color _tipoColor() {
    switch (visita.tipoGestion) {
      case 'RENOVACION':
      case 'renovacion':
        return BBVAColors.tagRenovacion;
      case 'AMPLIACION':
      case 'ampliacion':
        return BBVAColors.tagAmpliacion;
      case 'NUEVA':
      case 'nueva':
        return BBVAColors.tagNueva;
      default:
        return BBVAColors.tagSeguimiento;
    }
  }

  String _tipoLabel() {
    switch (visita.tipoGestion.toUpperCase()) {
      case 'RENOVACION': return 'Renovación';
      case 'AMPLIACION': return 'Ampliación';
      case 'NUEVA': return 'Nueva';
      default: return 'Seguimiento';
    }
  }

  Color _prioridadColor() {
    switch (visita.prioridad) {
      case 'alta':
        return BBVAColors.errorRed;
      case 'media':
        return BBVAColors.warningAmber;
      default:
        return BBVAColors.mediumGray;
    }
  }

  Color _origenColor() {
    switch (visita.tipoOrigen) {
      case 'solicitud_asignada': return BBVAColors.successGreen;
      case 'solicitud_pendiente': return BBVAColors.warningAmber;
      default: return BBVAColors.primaryBlue;
    }
  }

  String _origenLabel() {
    switch (visita.tipoOrigen) {
      case 'solicitud_asignada': return 'Solicitud';
      case 'solicitud_pendiente': return 'Pendiente';
      default: return 'Visita';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: BBVAColors.lightBlue,
                child: Text(visita.clienteNombre.isNotEmpty
                    ? visita.clienteNombre[0].toUpperCase()
                    : '?'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visita.clienteNombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _origenColor().withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_origenLabel(),
                              style: TextStyle(
                                  fontSize: 11, color: _origenColor())),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _tipoColor().withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_tipoLabel(),
                              style: TextStyle(
                                  fontSize: 11, color: _tipoColor())),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _prioridadColor().withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(visita.prioridadLabel.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11, color: _prioridadColor())),
                        ),
                      ],
                    ),
                    if (visita.montoReferencial != null) ...[
                      const SizedBox(height: 4),
                      Text('Monto ref: S/ ${visita.montoReferencial!.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12, color: BBVAColors.darkGray)),
                    ],
                  ],
                ),
              ),
              if (onTomar != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Tomar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BBVAColors.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onTomar,
                )
              else
                IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      color: BBVAColors.successGreen),
                  onPressed: visita.resultadoVisita == null ? onResultado : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultadoVisitaDialog extends ConsumerStatefulWidget {
  final String visitaId;
  const _ResultadoVisitaDialog({required this.visitaId});

  @override
  ConsumerState<_ResultadoVisitaDialog> createState() =>
      _ResultadoVisitaDialogState();
}

class _ResultadoVisitaDialogState
    extends ConsumerState<_ResultadoVisitaDialog> {
  String _resultado = 'exitoso';
  final _observacionController = TextEditingController();

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar resultado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _resultado,
            items: const [
              DropdownMenuItem(value: 'exitoso', child: Text('Exitoso')),
              DropdownMenuItem(value: 'no_interesado', child: Text('No interesado')),
              DropdownMenuItem(value: 'ausente', child: Text('Ausente')),
              DropdownMenuItem(value: 'reprogramar', child: Text('Reprogramar')),
              DropdownMenuItem(value: 'no_localizado', child: Text('No localizado')),
            ],
            onChanged: (v) => setState(() => _resultado = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observacionController,
            decoration: const InputDecoration(
              labelText: 'Observación',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            ref
                .read(carteraViewModelProvider.notifier)
                .registrarResultado(
                    widget.visitaId, _resultado, _observacionController.text);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
