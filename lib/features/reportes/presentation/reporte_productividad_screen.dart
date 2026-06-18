import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/supabase/supabase_client.dart';
import '../../auth/presentation/login_viewmodel.dart';

class ReporteProductividadScreen extends ConsumerStatefulWidget {
  const ReporteProductividadScreen({super.key});

  @override
  ConsumerState<ReporteProductividadScreen> createState() =>
      _ReporteProductividadScreenState();
}

class _ReporteProductividadScreenState
    extends ConsumerState<ReporteProductividadScreen> {
  bool _loading = true;
  String _periodo = 'Este mes';

  int _totalVisitas = 0;
  int _solicitudes = 0;
  int _creditos = 0;
  double _montoTotal = 0;
  List<double> _semanas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final asesor = ref.read(authViewModelProvider).asesor;
      if (asesor == null) return;
      final supabase = SupabaseClientProvider.client;

      final asesorData = await supabase
          .from('asesores_negocio')
          .select('visitas_mes_actual, creditos_mes_actual, monto_mes_actual')
          .eq('id', asesor.id)
          .single();

      _totalVisitas = (asesorData['visitas_mes_actual'] as num?)?.toInt() ?? 0;
      _creditos = (asesorData['creditos_mes_actual'] as num?)?.toInt() ?? 0;
      _montoTotal =
          (asesorData['monto_mes_actual'] as num?)?.toDouble() ?? 0;

      final solicitudes = await supabase
          .from('solicitudes_credito')
          .select('id')
          .eq('asesor_id', asesor.id);
      _solicitudes = (solicitudes as List).length;

      _semanas = [];
      for (var i = 0; i < 4; i++) {
        _semanas.add((_totalVisitas / 4) * (i + 1));
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final efectividad = _totalVisitas > 0
        ? ((_creditos / _totalVisitas) * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Productividad'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: _periodo,
                    items: const [
                      DropdownMenuItem(
                          value: 'Este mes', child: Text('Este mes')),
                      DropdownMenuItem(
                          value: 'Último mes', child: Text('Último mes')),
                    ],
                    onChanged: (v) => setState(() => _periodo = v!),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Visitas del Mes',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _semanas.isEmpty
                                ? const Center(child: Text('Sin datos'))
                                : BarChart(
                                    BarChartData(
                                      gridData: const FlGridData(
                                          show: false),
                                      titlesData: const FlTitlesData(
                                          show: false),
                                      borderData:
                                          FlBorderData(show: false),
                                      barGroups: _semanas
                                          .asMap()
                                          .entries
                                          .map((e) =>
                                              BarChartGroupData(
                                                x: e.key,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: e.value,
                                                    color: BBVAColors
                                                        .primaryBlue,
                                                    width: 20,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(4),
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
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _metricRow(
                              'Total Visitas', '$_totalVisitas'),
                          _metricRow('Solicitudes Generadas',
                              '$_solicitudes'),
                          _metricRow(
                              'Créditos Colocados', '$_creditos'),
                          _metricRow('Monto Total Colocado',
                              'S/ ${_montoTotal.toStringAsFixed(0)}'),
                          _metricRow('Efectividad', '$efectividad%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: BBVAColors.darkGray)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
