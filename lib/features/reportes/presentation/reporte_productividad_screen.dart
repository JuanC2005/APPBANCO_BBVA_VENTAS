import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class ReporteProductividadScreen extends StatelessWidget {
  const ReporteProductividadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Productividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Marzo 2025',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Visitas Realizadas',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _barGroup(0, 5, BBVAColors.primaryBlue),
                            _barGroup(1, 7, BBVAColors.primaryBlue),
                            _barGroup(2, 4, BBVAColors.primaryBlue),
                            _barGroup(3, 8, BBVAColors.primaryBlue),
                            _barGroup(4, 6, BBVAColors.primaryBlue),
                            _barGroup(5, 9, BBVAColors.primaryBlue),
                            _barGroup(6, 5, BBVAColors.primaryBlue),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Semana 1    2    3    4    5',
                        style: TextStyle(color: BBVAColors.darkGray)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _metricRow('Total Visitas', '44'),
                    _metricRow('Solicitudes Generadas', '12'),
                    _metricRow('Créditos Colocados', '8'),
                    _metricRow('Monto Total Colocado', 'S/ 52,000'),
                    _metricRow('Efectividad', '27.3%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: color, width: 15, borderRadius: BorderRadius.circular(4)),
    ]);
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: BBVAColors.darkGray)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
