import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'ficha_viewmodel.dart';
import '../domain/cliente.dart';
import '../domain/credito.dart';
import '../domain/preaprobado.dart';

class FichaScreen extends ConsumerStatefulWidget {
  final String clienteId;
  const FichaScreen({super.key, required this.clienteId});

  @override
  ConsumerState<FichaScreen> createState() => _FichaScreenState();
}

class _FichaScreenState extends ConsumerState<FichaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fichaViewModelProvider.notifier).cargarFicha(widget.clienteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fichaViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.cliente?.nombreCompleto ?? 'Ficha del Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            tooltip: 'Solicitar crédito',
            onPressed: () => context.push('/solicitud/${widget.clienteId}'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Consultar Buró',
            onPressed: () => context.push('/buro/${widget.clienteId}'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.cliente == null
                  ? const Center(child: Text('Cliente no encontrado'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClienteHeader(state.cliente!),
                          const SizedBox(height: 16),
                          _buildInfoSection(state.cliente!, state.perfil),
                          const SizedBox(height: 16),
                          _buildSemaforoSBS(state.cliente!),
                          const SizedBox(height: 16),
                          _buildScoreSection(state),
                          const SizedBox(height: 16),
                          _buildCreditosSection(state.creditos),
                          if (state.preaprobado != null) ...[
                            const SizedBox(height: 16),
                            _buildOfertaPreaprobada(state.preaprobado!),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildClienteHeader(Cliente c) {
    final estadoColor = c.estadoCliente == 'activo'
        ? BBVAColors.successGreen
        : BBVAColors.warningAmber;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: BBVAColors.lightBlue,
              child: Text(
                c.nombreCompleto.isNotEmpty
                    ? c.nombreCompleto[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold,
                    color: BBVAColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.nombreCompleto,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (c.telefono != null)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14,
                            color: BBVAColors.darkGray),
                        const SizedBox(width: 4),
                        Text(c.telefono!,
                            style: const TextStyle(
                                color: BBVAColors.darkGray)),
                      ],
                    ),
                  if (c.direccion != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14,
                            color: BBVAColors.darkGray),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(c.direccion!,
                              style: const TextStyle(
                                  color: BBVAColors.darkGray),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: estadoColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (c.estadoCliente ?? 'activo').toUpperCase(),
                      style: TextStyle(
                          fontSize: 11, color: estadoColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Cliente c, Map<String, dynamic>? perfil) {
    final antiguedad = perfil?['antiguedad_negocio'] as int?;
    final ingresos = perfil?['ingreso_mensual_est'] as num? ?? c.ingresosMensuales ?? c.ingresosEstimados;
    final tipoVivienda = c.tipoVivienda;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información General',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            _infoRow('Documento',
                '${c.tipoDocumento} ${c.numeroDocumento}'),
            _infoRow('Estado Civil', c.estadoCivil ?? 'N/D'),
            _infoRow('Tipo Negocio', c.tipoNegocio ?? 'N/D'),
            _infoRow('Ingresos Mensuales',
                'S/ ${Formatters.moneda(ingresos?.toDouble() ?? 0)}'),
            if (tipoVivienda != null)
              _infoRow('Tipo Vivienda', tipoVivienda),
            if (antiguedad != null)
              _infoRow('Antigüedad', '$antiguedad meses'),
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

  Widget _buildSemaforoSBS(Cliente c) {
    final calif = (c.calificacionSbs ?? 'Normal').toLowerCase();
    Color califColor;
    switch (calif) {
      case 'normal':
        califColor = BBVAColors.successGreen;
        break;
      case 'cpp':
        califColor = BBVAColors.warningAmber;
        break;
      case 'deficiente':
        califColor = Colors.orange;
        break;
      case 'dudoso':
        califColor = BBVAColors.errorRed;
        break;
      case 'perdida':
        califColor = Colors.red.shade900;
        break;
      default:
        califColor = BBVAColors.mediumGray;
    }

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
                _semaforoItem('Normal',
                    calif == 'normal' ? 'Actual' : '', BBVAColors.successGreen),
                _semaforoItem('CPP',
                    calif == 'cpp' ? 'Actual' : '', BBVAColors.warningAmber),
                _semaforoItem('Deficiente',
                    calif == 'deficiente' ? 'Actual' : '', Colors.orange),
                _semaforoItem('Dudoso',
                    calif == 'dudoso' ? 'Actual' : '', BBVAColors.errorRed),
                _semaforoItem('Pérdida',
                    calif == 'perdida' ? 'Actual' : '', Colors.red.shade900),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Calificación: ${c.calificacionSbs ?? 'N/D'}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: califColor),
              ),
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
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(value, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _buildScoreSection(FichaState state) {
    final scoreVal = state.scoreActual;
    final seg = state.segmento ?? 'N/A';
    Color scoreColor;
    if (scoreVal == null) {
      scoreColor = BBVAColors.mediumGray;
    } else if (scoreVal >= 700) {
      scoreColor = BBVAColors.successGreen;
    } else if (scoreVal >= 500) {
      scoreColor = BBVAColors.warningAmber;
    } else {
      scoreColor = BBVAColors.errorRed;
    }

    final movs = state.movimientos;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Score Crediticio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            if (scoreVal != null)
              Center(
                child: Text(
                  '${scoreVal.toInt()} — Segmento $seg',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold,
                      color: scoreColor),
                ),
              )
            else
              const Center(child: Text('Sin score disponible')),
            if (state.score?['recomendacion'] != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  state.score!['recomendacion'],
                  style: const TextStyle(color: BBVAColors.darkGray),
                ),
              ),
            ],
            if (movs.length >= 2) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                            movs.length,
                            (i) => FlSpot(
                                i.toDouble(),
                                ((movs[i]['saldo_promedio'] as num?)
                                        ?.toDouble() ??
                                    0))),
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
                child: Text('Evolución saldo promedio mensual',
                    style: TextStyle(
                        fontSize: 12, color: BBVAColors.darkGray)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreditosSection(List<Credito> creditos) {
    if (creditos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Historial de Créditos',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              const Center(child: Text('Sin créditos registrados')),
            ],
          ),
        ),
      );
    }

    Color estadoColor(String e) {
      switch (e) {
        case 'pagado': return BBVAColors.successGreen;
        case 'vigente': return BBVAColors.primaryBlue;
        case 'vencido': return BBVAColors.warningAmber;
        case 'castigado': return BBVAColors.errorRed;
        default: return BBVAColors.mediumGray;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historial de Créditos',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ...creditos.map((cr) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cr.productLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(
                              'S/ ${Formatters.moneda(cr.montoDesembolsado)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: BBVAColors.darkGray),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: estadoColor(cr.estado).withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(cr.estadoLabel,
                            style: TextStyle(
                                fontSize: 11,
                                color: estadoColor(cr.estado))),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOfertaPreaprobada(Preaprobado p) {
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
            Text('Monto: S/ ${Formatters.moneda(p.montoMaximo)}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
                'TEA: ${p.teaReferencial.toStringAsFixed(1)}% | Plazo: hasta ${p.plazoSugeridoMeses} meses',
                style: const TextStyle(color: BBVAColors.darkGray)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                    '/solicitud/${widget.clienteId}'),
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
