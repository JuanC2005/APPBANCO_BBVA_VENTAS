import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../domain/campana.dart';
import 'campanas_viewmodel.dart';

class CampanasScreen extends ConsumerStatefulWidget {
  const CampanasScreen({super.key});

  @override
  ConsumerState<CampanasScreen> createState() => _CampanasScreenState();
}

class _CampanasScreenState extends ConsumerState<CampanasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargar();
    });
  }

  void _cargar() {
    final asesor = ref.read(authViewModelProvider).asesor;
    if (asesor != null) {
      ref.read(campanasViewModelProvider.notifier).cargarActivas(asesor.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campanasViewModelProvider);
    final vm = ref.read(campanasViewModelProvider.notifier);
    final asesor = ref.read(authViewModelProvider).asesor;
    final esSupervisor = asesor != null &&
        (asesor.perfil == 'supervisor' ||
            asesor.perfil == 'super_operador' ||
            asesor.perfil == 'administrador');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campañas'),
        actions: [
          if (state.noLeidas > 0)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: BBVAColors.errorRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${state.noLeidas} nuevas',
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(state, vm),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : state.filtradas.isEmpty
                        ? const Center(child: Text('Sin campañas activas'))
                        : ListView.builder(
                            itemCount: state.filtradas.length,
                            itemBuilder: (_, i) =>
                                _campanaCard(state.filtradas[i], esSupervisor),
                          ),
          ),
        ],
      ),
      floatingActionButton: esSupervisor
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/crear-campana'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFiltros(CampanasState state, CampanasViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['TODOS', 'marketing', 'cobranza', 'capacitacion', 'informativa']
              .map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t == 'TODOS' ? 'Todos' : t[0].toUpperCase() + t.substring(1)),
                      selected: state.filtroTipo == t,
                      onSelected: (_) => vm.setFiltroTipo(t),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _campanaCard(Campana c, bool esSupervisor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _tipoColor(c.tipo).withAlpha(25),
              child: Icon(_tipoIcon(c.tipo), color: _tipoColor(c.tipo)),
            ),
            title: Text(c.titulo,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.leida ? null : BBVAColors.primaryBlue)),
            subtitle: Text(c.mensaje, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: c.leida
                ? const Icon(Icons.check_circle, color: Colors.grey)
                : const Icon(Icons.mark_email_unread, color: BBVAColors.primaryBlue),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _tag(c.segmentoObjetivo == 'TODOS' ? 'Todos' : 'Seg. ${c.segmentoObjetivo}', BBVAColors.successGreen),
                const SizedBox(width: 8),
                _tag(c.tipo, _tipoColor(c.tipo)),
                const Spacer(),
                if (!c.leida)
                  TextButton(
                    onPressed: () {
                      final asesor =
                          ref.read(authViewModelProvider).asesor;
                      if (asesor != null) {
                        ref
                            .read(campanasViewModelProvider.notifier)
                            .marcarLeida(c.id, asesor.id);
                      }
                    },
                    child: const Text('Marcar leída'),
                  ),
                if (esSupervisor)
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'toggle') {
                        ref
                            .read(campanasViewModelProvider.notifier)
                            .toggleActiva(c.id, !c.activa);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(c.activa ? 'Desactivar' : 'Activar'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Color _tipoColor(String t) {
    switch (t) {
      case 'marketing': return BBVAColors.successGreen;
      case 'cobranza': return BBVAColors.errorRed;
      case 'capacitacion': return BBVAColors.warningAmber;
      case 'informativa': return BBVAColors.primaryBlue;
      default: return Colors.grey;
    }
  }

  IconData _tipoIcon(String t) {
    switch (t) {
      case 'marketing': return Icons.campaign;
      case 'cobranza': return Icons.payment;
      case 'capacitacion': return Icons.school;
      case 'informativa': return Icons.info;
      default: return Icons.notifications;
    }
  }
}
