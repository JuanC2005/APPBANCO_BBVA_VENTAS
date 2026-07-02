import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../../solicitud/domain/solicitud.dart';
import '../data/estado_repository.dart';

final pendientesProvider = FutureProvider.autoDispose<List<SolicitudCredito>>((ref) {
  final asesor = ref.watch(authViewModelProvider).asesor;
  final repo = ref.watch(estadoRepositoryProvider);
  return repo.listarPorEstado(asesor?.id ?? '',
      ['borrador', 'enviado', 'recibido_comite', 'en_evaluacion']);
});

final aprobadosProvider = FutureProvider.autoDispose<List<SolicitudCredito>>((ref) {
  final asesor = ref.watch(authViewModelProvider).asesor;
  final repo = ref.watch(estadoRepositoryProvider);
  return repo.listarPorEstado(asesor?.id ?? '',
      ['aprobado', 'condicionado', 'desembolsado']);
});

final rechazadosProvider = FutureProvider.autoDispose<List<SolicitudCredito>>((ref) {
  final asesor = ref.watch(authViewModelProvider).asesor;
  final repo = ref.watch(estadoRepositoryProvider);
  return repo.listarPorEstado(asesor?.id ?? '', ['rechazado']);
});

class TableroSolicitudesScreen extends ConsumerWidget {
  const TableroSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(pendientesProvider);
    final aprobados = ref.watch(aprobadosProvider);
    final rechazados = ref.watch(rechazadosProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estado de Solicitudes'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Pendientes (${_count(pendientes)})'),
              Tab(text: 'Aprobados (${_count(aprobados)})'),
              Tab(text: 'Rechazados (${_count(rechazados)})'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendientesProvider);
            ref.invalidate(aprobadosProvider);
            ref.invalidate(rechazadosProvider);
            await Future.wait([
              ref.refresh(pendientesProvider.future),
              ref.refresh(aprobadosProvider.future),
              ref.refresh(rechazadosProvider.future),
            ]);
          },
          child: TabBarView(
            children: [
              _tabContent(pendientes, context, ref),
              _tabContent(aprobados, context, ref),
              _tabContent(rechazados, context, ref),
            ],
          ),
        ),
      ),
    );
  }

  int _count(AsyncValue<List<SolicitudCredito>> value) {
    return value.valueOrNull?.length ?? 0;
  }

  Widget _tabContent(
      AsyncValue<List<SolicitudCredito>> list, BuildContext context, WidgetRef ref) {
    return list.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (solicitudes) {
        if (solicitudes.isEmpty) {
          return const Center(child: Text('Sin solicitudes'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: solicitudes.length,
          itemBuilder: (_, i) => _card(solicitudes[i], context, ref),
        );
      },
    );
  }

  Widget _card(SolicitudCredito s, BuildContext context, WidgetRef ref) {
    Color color;
    switch (s.estado) {
      case 'aprobado': case 'condicionado': case 'desembolsado':
        color = BBVAColors.successGreen;
      case 'rechazado':
        color = BBVAColors.errorRed;
      default:
        color = BBVAColors.warningAmber;
    }

    return Card(
      child: ListTile(
        title: Text(s.numeroExpediente ?? s.id.substring(0, 8),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('S/ ${s.montoSolicitado.toStringAsFixed(0)}'),
            Text(_fecha(s.createdAt),
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(s.estadoLabel,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        onTap: () async {
          await context.push('/detalle-solicitud/${s.id}');
          ref.invalidate(pendientesProvider);
          ref.invalidate(aprobadosProvider);
          ref.invalidate(rechazadosProvider);
        },
      ),
    );
  }

  String _fecha(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
