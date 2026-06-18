import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class MonitorSupervisorScreen extends ConsumerStatefulWidget {
  const MonitorSupervisorScreen({super.key});

  @override
  ConsumerState<MonitorSupervisorScreen> createState() =>
      _MonitorSupervisorScreenState();
}

class _MonitorSupervisorScreenState
    extends ConsumerState<MonitorSupervisorScreen> {
  List<Map<String, dynamic>> _asesores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final list = await api.getList('/reportes/supervisor/monitor');
      setState(() => _asesores = list.cast<Map<String, dynamic>>());
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Supervisor'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _asesores.isEmpty
              ? const Center(child: Text('Sin asesores en tu agencia'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('${_asesores.length} asesores en tu agencia',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    ...(_asesores.map((a) => _asesorCard(context, a))),
                  ],
                ),
    );
  }

  Widget _asesorCard(BuildContext context, Map<String, dynamic> a) {
    final visitas = (a['visitas_mes_actual'] as num?)?.toInt() ?? 0;
    final creditos = (a['creditos_mes_actual'] as num?)?.toInt() ?? 0;
    final nombre = '${a['nombres'] ?? ''} ${a['apellidos'] ?? ''}';
    final codigo = a['codigo_empleado'] ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(codigo,
                    style: const TextStyle(color: BBVAColors.darkGray)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _chip('Visitas', '$visitas', BBVAColors.primaryBlue),
                _chip('Créditos', '$creditos', BBVAColors.successGreen),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.assessment),
                  tooltip: 'Ver productividad',
                  onPressed: () => context.push('/reporte-productividad'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(fontSize: 12, color: color)),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
