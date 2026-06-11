import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class TableroSolicitudesScreen extends StatelessWidget {
  const TableroSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estado de Solicitudes'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Pendientes (3)'),
              Tab(text: 'Aprobados (5)'),
              Tab(text: 'Rechazados (2)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, [
              _SolicitudData('SOL-2025-004', 'Pedro Sánchez', 'S/ 6,000', 'En Evaluación',
                  BBVAColors.warningAmber, '13/03/2025'),
              _SolicitudData('SOL-2025-003', 'Carlos López', 'S/ 3,000', 'En Evaluación',
                  BBVAColors.warningAmber, '08/03/2025'),
              _SolicitudData('SOL-2025-002', 'María García', 'S/ 8,000', 'En Evaluación',
                  BBVAColors.warningAmber, '10/03/2025'),
            ]),
            _buildList(context, [
              _SolicitudData('SOL-2025-001', 'Juan Pérez', 'S/ 5,000', 'Aprobado',
                  BBVAColors.successGreen, '12/03/2025'),
            ]),
            _buildList(context, [
              _SolicitudData('SOL-2025-005', 'Ana Torres', 'S/ 10,000', 'Rechazado',
                  BBVAColors.errorRed, '11/03/2025'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<_SolicitudData> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
        itemBuilder: (_, i) => _solicitudCard(context, items[i]),
    );
  }

  Widget _solicitudCard(BuildContext context, _SolicitudData data) {
    return Card(
      child: ListTile(
        title: Text(data.codigo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data.cliente} · ${data.monto}'),
            Text(data.fecha, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: data.color.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(data.estado,
              style: TextStyle(color: data.color, fontWeight: FontWeight.bold)),
        ),
        onTap: () => context.push('/detalle-solicitud/${data.codigo}'),
      ),
    );
  }
}

class _SolicitudData {
  final String codigo, cliente, monto, estado, fecha;
  final Color color;
  _SolicitudData(this.codigo, this.cliente, this.monto, this.estado,
      this.color, this.fecha);
}
