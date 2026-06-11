import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class Paso3CondicionesCredito extends StatefulWidget {
  final String solicitudId;
  const Paso3CondicionesCredito({super.key, required this.solicitudId});

  @override
  State<Paso3CondicionesCredito> createState() => _Paso3CondicionesCreditoState();
}

class _Paso3CondicionesCreditoState extends State<Paso3CondicionesCredito> {
  final _montoController = TextEditingController(text: '5000');
  double _plazo = 12;
  double _tea = 18.5;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  double get _cuotaMensual {
    final monto = double.tryParse(_montoController.text) ?? 0;
    final tasaMensual = (_tea / 100) / 12;
    if (tasaMensual == 0 || _plazo == 0) return 0;
    return monto * (tasaMensual * pow(1 + tasaMensual, _plazo.toInt())) /
        (pow(1 + tasaMensual, _plazo.toInt()) - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Condiciones')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monto Solicitado', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'S/ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text('Plazo (meses)', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _plazo,
              min: 3,
              max: 48,
              divisions: 15,
              label: '${_plazo.toInt()} meses',
              onChanged: (v) => setState(() => _plazo = v),
            ),
            Text('${_plazo.toInt()} meses',
                style: const TextStyle(color: BBVAColors.primaryBlue)),
            const SizedBox(height: 16),
            const Text('TEA', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _tea,
              min: 10,
              max: 50,
              divisions: 40,
              label: '${_tea.toStringAsFixed(1)}%',
              onChanged: (v) => setState(() => _tea = v),
            ),
            Text('${_tea.toStringAsFixed(1)}%',
                style: const TextStyle(color: BBVAColors.primaryBlue)),
            const SizedBox(height: 16),
            Card(
              color: BBVAColors.lightBlue,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Cuota Mensual Estimada: S/ ${_cuotaMensual.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('(Incluye seguros y comisiones)',
                        style: TextStyle(color: BBVAColors.darkGray)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/solicitud/paso4/${widget.solicitudId}'),
                    child: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
