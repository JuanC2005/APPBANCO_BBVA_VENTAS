import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/storage/supabase/supabase_client.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, int> _counts = {};
  bool _loading = true;

  List<Map<String, dynamic>> _creditosPorProducto = [];
  List<Map<String, dynamic>> _solicitudesPorEstado = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final tables = ['clientes', 'asesores_negocio', 'agencias', 'creditos'];
      for (final t in tables) {
        final data = await SupabaseClientProvider.client
            .from(t)
            .select('id');
        _counts[t] = data.length;
      }

      final solicitudes = await SupabaseClientProvider.client
          .from('solicitudes_credito')
          .select('id');
      _counts['solicitudes_credito'] = solicitudes.length;

      final alertas = await SupabaseClientProvider.client
          .from('alertas_cartera')
          .select('id');
      _counts['alertas_cartera'] = alertas.length;

      final creditos = await SupabaseClientProvider.client
          .from('creditos')
          .select('producto, monto_desembolsado');
      _creditosPorProducto = List<Map<String, dynamic>>.from(creditos);

      final solicitudesEst = await SupabaseClientProvider.client
          .from('solicitudes_credito')
          .select('estado');
      _solicitudesPorEstado = List<Map<String, dynamic>>.from(solicitudesEst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BBVAColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Resumen general del sistema',
                  style: TextStyle(color: BBVAColors.darkGray, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 32),
                _buildChartsSection(),
              ],
            ),
          );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            StatsCard(
              title: 'Total Clientes',
              value: _formatNumber(_counts['clientes'] ?? 0),
              icon: Icons.people,
              color: BBVAColors.primaryBlue,
            ),
            StatsCard(
              title: 'Asesores',
              value: _formatNumber(_counts['asesores_negocio'] ?? 0),
              icon: Icons.person,
              color: BBVAColors.successGreen,
            ),
            StatsCard(
              title: 'Agencias',
              value: _formatNumber(_counts['agencias'] ?? 0),
              icon: Icons.business,
              color: BBVAColors.warningAmber,
            ),
            StatsCard(
              title: 'Créditos',
              value: _formatNumber(_counts['creditos'] ?? 0),
              icon: Icons.account_balance,
              color: BBVAColors.accentBlue,
            ),
            StatsCard(
              title: 'Solicitudes',
              value: _formatNumber(_counts['solicitudes_credito'] ?? 0),
              icon: Icons.description,
              color: BBVAColors.alertOrange,
            ),
            StatsCard(
              title: 'Alertas',
              value: _formatNumber(_counts['alertas_cartera'] ?? 0),
              icon: Icons.notifications_active,
              color: BBVAColors.errorRed,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPieChart(),
                ),
                if (isWide) const SizedBox(width: 24),
                if (isWide)
                  Expanded(
                    child: _buildBarChart(),
                  ),
              ],
            ),
            if (!isWide) ...[
              const SizedBox(height: 24),
              _buildBarChart(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPieChart() {
    final productMap = <String, int>{};
    for (final c in _creditosPorProducto) {
      final prod = c['producto']?.toString() ?? 'sin_producto';
      productMap[prod] = (productMap[prod] ?? 0) + 1;
    }

    final colors = [
      BBVAColors.primaryBlue,
      BBVAColors.successGreen,
      BBVAColors.warningAmber,
      BBVAColors.errorRed,
      BBVAColors.accentBlue,
      BBVAColors.alertOrange,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Créditos por Producto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: productMap.isEmpty
                  ? const Center(child: Text('Sin datos'))
                  : PieChart(
                      PieChartData(
                        sections: productMap.entries
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (e) => PieChartSectionData(
                                value: e.value.value.toDouble(),
                                title: '${e.value.key}\n${e.value.value}',
                                color: colors[e.key % colors.length],
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                radius: 60,
                              ),
                            )
                            .toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final estadoMap = <String, int>{};
    for (final s in _solicitudesPorEstado) {
      final est = s['estado']?.toString() ?? 'sin_estado';
      estadoMap[est] = (estadoMap[est] ?? 0) + 1;
    }

    final entries = estadoMap.entries.toList();
    if (entries.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('Sin datos de solicitudes')),
        ),
      );
    }

    final barColors = [
      BBVAColors.primaryBlue,
      BBVAColors.successGreen,
      BBVAColors.warningAmber,
      BBVAColors.errorRed,
      BBVAColors.accentBlue,
      BBVAColors.alertOrange,
      BBVAColors.darkGray,
      BBVAColors.tagDesertor,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitudes por Estado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: entries
                          .map((e) => e.value)
                          .reduce((a, b) => a > b ? a : b)
                          .toDouble() +
                      2,
                  barGroups: entries
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value.toDouble(),
                              color: barColors[e.key % barColors.length],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entries[idx].key.length > 10
                                  ? '${entries[idx].key.substring(0, 10)}...'
                                  : entries[idx].key,
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
