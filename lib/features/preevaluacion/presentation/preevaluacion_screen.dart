import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../domain/preevaluacion_cliente.dart';
import 'preevaluacion_viewmodel.dart';

class PreevaluacionScreen extends ConsumerStatefulWidget {
  const PreevaluacionScreen({super.key});

  @override
  ConsumerState<PreevaluacionScreen> createState() =>
      _PreevaluacionScreenState();
}

class _PreevaluacionScreenState extends ConsumerState<PreevaluacionScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final asesor = ref.read(authViewModelProvider).asesor;
      if (asesor != null) {
        ref.read(preevaluacionViewModelProvider.notifier).cargar(asesor.id);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preevaluacionViewModelProvider);
    final vm = ref.read(preevaluacionViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-evaluación')),
      body: Column(
        children: [
          _buildResumen(state),
          _buildFiltros(state, vm),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : state.filtrados.isEmpty
                        ? const Center(child: Text('Sin resultados'))
                        : ListView.builder(
                            itemCount: state.filtrados.length,
                            itemBuilder: (_, i) =>
                                _clienteCard(state.filtrados[i], context),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumen(PreevaluacionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: BBVAColors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _resumenItem('Total', '${state.totalEvaluados}', null),
          _resumenItem('Seg. A', '${state.segmentoA}',
              BBVAColors.successGreen),
          _resumenItem('Seg. B', '${state.segmentoB}',
              BBVAColors.warningAmber),
          _resumenItem('Seg. C', '${state.segmentoC}',
              BBVAColors.alertOrange),
        ],
      ),
    );
  }

  Widget _resumenItem(String label, String value, Color? color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFiltros(PreevaluacionState state, PreevaluacionViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: vm.setBusqueda,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: state.filtroSegmento,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
              DropdownMenuItem(value: 'A', child: Text('Seg. A')),
              DropdownMenuItem(value: 'B', child: Text('Seg. B')),
              DropdownMenuItem(value: 'C', child: Text('Seg. C')),
              DropdownMenuItem(value: 'D', child: Text('Seg. D')),
              DropdownMenuItem(value: 'E', child: Text('Seg. E')),
            ],
            onChanged: (v) {
              if (v != null) vm.setFiltroSegmento(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _clienteCard(PreevaluacionCliente c, BuildContext context) {
    final color = _segmentColor(c.segmento);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Text(c.segmento,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
        title: Text(c.clienteNombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Score: ${c.score.toStringAsFixed(0)} pts · '
          'S/ ${c.montoMaxSugerido?.toStringAsFixed(0) ?? '—'}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Chip(
          label: Text(c.score.toStringAsFixed(0),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
        onTap: () => _showDetalle(c),
      ),
    );
  }

  void _showDetalle(PreevaluacionCliente c) {
    final color = _segmentColor(c.segmento);
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text('Seg. ${c.segmento}',
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: color,
                ),
                const Spacer(),
                Text('${c.score.toStringAsFixed(0)} pts',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(c.clienteNombre,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if (c.numeroDocumento != null)
              Text('Doc: ${c.numeroDocumento}'),
            if (c.montoMaxSugerido != null)
              Text('Monto máximo sugerido: S/ ${c.montoMaxSugerido!.toStringAsFixed(0)}'),
            if (c.ingresoMensual != null)
              Text('Ingreso estimado: S/ ${c.ingresoMensual!.toStringAsFixed(0)}'),
            Text('Recomendación: ${_recomendacionLabel(c.recomendacion)}'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recalcular'),
                    onPressed: () async {
                      Navigator.pop(context);
                      final vm = ref.read(
                          preevaluacionViewModelProvider.notifier);
                      await vm.recalcular(c.clienteId);
                      final asesor =
                          ref.read(authViewModelProvider).asesor;
                      if (asesor != null) await vm.cargar(asesor.id);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('Ficha'),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/ficha-cliente/${c.clienteId}');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _segmentColor(String s) {
    switch (s) {
      case 'A': return BBVAColors.successGreen;
      case 'B': return BBVAColors.warningAmber;
      case 'C': return BBVAColors.alertOrange;
      case 'D': return BBVAColors.moraRojo;
      case 'E': return BBVAColors.errorRed;
      default: return Colors.grey;
    }
  }

  String _recomendacionLabel(String r) {
    switch (r) {
      case 'aprobado_preaprobado': return 'Aprobado - Pre-aprobado';
      case 'recomendado': return 'Recomendado';
      default: return 'Evaluar presencial';
    }
  }
}
