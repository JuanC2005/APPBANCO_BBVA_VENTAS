import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SimuladorScreen extends StatefulWidget {
  const SimuladorScreen({super.key});

  @override
  State<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends State<SimuladorScreen> {
  final _montoController = TextEditingController();
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
      appBar: AppBar(title: const Text('Simulador de Crédito')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto a simular',
                prefixText: 'S/ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text('Plazo (meses)', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _plazo, min: 3, max: 48, divisions: 15,
              label: '${_plazo.toInt()} meses',
              onChanged: (v) => setState(() => _plazo = v),
            ),
            Text('${_plazo.toInt()} meses',
                style: const TextStyle(color: BBVAColors.primaryBlue)),
            const SizedBox(height: 16),
            const Text('TEA', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _tea, min: 10, max: 50, divisions: 40,
              label: '${_tea.toStringAsFixed(1)}%',
              onChanged: (v) => setState(() => _tea = v),
            ),
            Text('${_tea.toStringAsFixed(1)}%',
                style: const TextStyle(color: BBVAColors.primaryBlue)),
            const SizedBox(height: 24),
            Card(
              color: BBVAColors.lightBlue,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Cuota Mensual: S/ ${_cuotaMensual.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Total a pagar: S/ ${(_cuotaMensual * _plazo).toStringAsFixed(2)}',
                        style: const TextStyle(color: BBVAColors.darkGray)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
