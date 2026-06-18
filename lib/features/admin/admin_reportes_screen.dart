import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/supabase/supabase_client.dart';

class AdminReportesScreen extends StatefulWidget {
  const AdminReportesScreen({super.key});

  @override
  State<AdminReportesScreen> createState() => _AdminReportesScreenState();
}

class _AdminReportesScreenState extends State<AdminReportesScreen> {
  bool _loading = true;

  int _totalAsesores = 0;
  int _activos = 0;
  int _totalClientes = 0;
  int _creditosVigentes = 0;
  double _montoTotal = 0;

  List<_AsesorProd> _topAsesores = [];
  Map<String, int> _distribucionPerfil = {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseClientProvider.client;

      final asesores = await supabase
          .from('asesores_negocio')
          .select('id, activo, perfil, visitas_mes_actual, creditos_mes_actual, monto_mes_actual');
      final clientesRes = await supabase
          .from('clientes')
          .select('id');
      final creditosRes = await supabase
          .from('creditos')
          .select('monto_desembolsado, estado');

      final list = (asesores as List).cast<Map<String, dynamic>>();
      final todosCreditos = (creditosRes as List).cast<Map<String, dynamic>>();
      final creditosVigentes = todosCreditos.where((c) =>
          (c['estado'] as String?) == 'vigente' ||
          (c['estado'] as String?) == 'al_dia' ||
          (c['estado'] as String?) == 'refinanciado'
      ).toList();

      _totalAsesores = list.length;
      _activos = list.where((a) => a['activo'] == true).length;
      _totalClientes = (clientesRes as List).length;
      _creditosVigentes = creditosVigentes.length;
      _montoTotal = creditosVigentes.fold<double>(
          0, (sum, c) => sum + ((c['monto_desembolsado'] as num?)?.toDouble() ?? 0));

      _distribucionPerfil = {};
      for (final a in list) {
        final p = a['perfil'] ?? 'operador';
        _distribucionPerfil[p] = (_distribucionPerfil[p] ?? 0) + 1;
      }

      list.sort((a, b) =>
          ((b['creditos_mes_actual'] as num?)?.toInt() ?? 0)
              .compareTo((a['creditos_mes_actual'] as num?)?.toInt() ?? 0));
      _topAsesores = list.take(10).map((a) => _AsesorProd(
          codigo: a['id']?.toString().substring(0, 8) ?? '',
          creditos: (a['creditos_mes_actual'] as num?)?.toInt() ?? 0,
          visitas: (a['visitas_mes_actual'] as num?)?.toInt() ?? 0,
          monto: (a['monto_mes_actual'] as num?)?.toDouble() ?? 0,
      )).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(),
            const SizedBox(height: 24),
            _buildChartsRow(),
            const SizedBox(height: 24),
            _buildTopTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _statCard('Asesores', '$_totalAsesores', Icons.people, BBVAColors.primaryBlue),
        _statCard('Activos', '$_activos', Icons.person_pin, BBVAColors.successGreen),
        _statCard('Clientes', '$_totalClientes', Icons.group, BBVAColors.accentBlue),
        _statCard('Créditos Vig.', '$_creditosVigentes', Icons.account_balance, BBVAColors.warningAmber),
        _statCard('Monto Total', 'S/ ${_montoTotal.toStringAsFixed(0)}', Icons.monetization_on, BBVAColors.tagRenovacion),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top 10 Asesores (Créditos/Mes)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= _topAsesores.length) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('${i + 1}',
                                      style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _topAsesores
                            .asMap()
                            .entries
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value.creditos.toDouble(),
                                      color: BBVAColors.primaryBlue,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distribución por Perfil',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _distribucionPerfil.entries.map((e) {
                          final colors = {
                            'operador': BBVAColors.primaryBlue,
                            'super_operador': BBVAColors.accentBlue,
                            'supervisor': BBVAColors.warningAmber,
                            'administrador': BBVAColors.errorRed,
                          };
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            title: '${e.key.split('_').first}\n${e.value}',
                            color: colors[e.key] ?? Colors.grey,
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top 10 Asesores del Mes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            DataTable(
              headingRowColor: WidgetStateProperty.all(BBVAColors.lightBlue),
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Visitas')),
                DataColumn(label: Text('Créditos')),
                DataColumn(label: Text('Monto')),
              ],
              rows: _topAsesores
                  .asMap()
                  .entries
                  .map((e) => DataRow(cells: [
                        DataCell(Text('${e.key + 1}')),
                        DataCell(Text(e.value.codigo)),
                        DataCell(Text('${e.value.visitas}')),
                        DataCell(Text('${e.value.creditos}')),
                        DataCell(Text('S/ ${e.value.monto.toStringAsFixed(0)}')),
                      ]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AsesorProd {
  final String codigo;
  final int creditos;
  final int visitas;
  final double monto;
  _AsesorProd({
    required this.codigo,
    required this.creditos,
    required this.visitas,
    required this.monto,
  });
}
