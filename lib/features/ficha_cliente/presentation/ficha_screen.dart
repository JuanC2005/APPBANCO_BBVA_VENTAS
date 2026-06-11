import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class FichaScreen extends ConsumerWidget {
  final String clienteId;
  const FichaScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            tooltip: 'Solicitar crédito',
            onPressed: () => context.push('/solicitud/$clienteId'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Consultar Buró',
            onPressed: () => context.push('/buro/$clienteId'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClienteHeader(context),
            const SizedBox(height: 16),
            _buildInfoSection(context),
            const SizedBox(height: 16),
            _buildSemaforoSBS(context),
            const SizedBox(height: 16),
            _buildScoreChart(context),
            const SizedBox(height: 16),
            _buildCreditosSection(context),
            const SizedBox(height: 16),
            _buildOfertaPreaprobada(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: BBVAColors.lightBlue,
              child: Icon(Icons.person, size: 36, color: BBVAColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('JUAN PÉREZ LÓPEZ',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: BBVAColors.darkGray),
                      SizedBox(width: 4),
                      Text('999 888 777',
                          style: TextStyle(color: BBVAColors.darkGray)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: BBVAColors.darkGray),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text('Jr. La Mar 456, Huancayo',
                            style: TextStyle(color: BBVAColors.darkGray),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: BBVAColors.successGreen.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('CLIENTE ACTIVO',
                        style: TextStyle(
                            fontSize: 11,
                            color: BBVAColors.successGreen,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información General',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            _infoRow('Documento', 'DNI 20456789'),
            _infoRow('Estado Civil', 'Casado'),
            _infoRow('Ocupación', 'Comerciante'),
            _infoRow('Ingresos Mensuales', 'S/ 3,500'),
            _infoRow('Tipo Vivienda', 'Propia'),
            _infoRow('Antigüedad', '24 meses'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: BBVAColors.darkGray)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSemaforoSBS(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Semáforo SBS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _semaforoItem('Normal', '0 días', BBVAColors.successGreen),
                _semaforoItem('CPP', '0 días', BBVAColors.successGreen),
                _semaforoItem('Deficiente', '0 días', BBVAColors.successGreen),
                _semaforoItem('Dudoso', '0 días', BBVAColors.successGreen),
                _semaforoItem('Pérdida', '0 días', BBVAColors.successGreen),
              ],
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Calificación: Normal (Riesgo Bajo)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: BBVAColors.successGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _semaforoItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(value, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _buildScoreChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evolución del Score',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 620),
                        const FlSpot(1, 650),
                        const FlSpot(2, 680),
                        const FlSpot(3, 710),
                        const FlSpot(4, 750),
                        const FlSpot(5, 780),
                      ],
                      isCurved: true,
                      color: BBVAColors.primaryBlue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text('Score Actual: 780 (Muy Bueno)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: BBVAColors.successGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditosSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historial de Créditos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            _creditoItem('CRD-2025-001', 'S/ 5,000', 'Pagado', BBVAColors.successGreen),
            _creditoItem('CRD-2024-089', 'S/ 3,000', 'Pagado', BBVAColors.successGreen),
            _creditoItem('CRD-2024-045', 'S/ 8,000', 'En proceso', BBVAColors.warningAmber),
          ],
        ),
      ),
    );
  }

  Widget _creditoItem(String codigo, String monto, String estado, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(codigo, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(monto),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(estado,
                style: TextStyle(fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildOfertaPreaprobada(BuildContext context) {
    return Card(
      color: BBVAColors.lightBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: BBVAColors.warningAmber),
                SizedBox(width: 8),
                Text('Oferta Preaprobada',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            const Text('Monto: S/ 12,000',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('TEA: 18.5% | Plazo: hasta 24 meses',
                style: TextStyle(color: BBVAColors.darkGray)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/solicitud/$clienteId'),
                icon: const Icon(Icons.send),
                label: const Text('Solicitar ahora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
