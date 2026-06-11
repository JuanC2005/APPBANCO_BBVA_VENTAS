import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AccionCobranzaScreen extends StatefulWidget {
  final String clienteId;
  const AccionCobranzaScreen({super.key, required this.clienteId});

  @override
  State<AccionCobranzaScreen> createState() => _AccionCobranzaScreenState();
}

class _AccionCobranzaScreenState extends State<AccionCobranzaScreen> {
  String _tipoAccion = 'llamada';
  final _comentarioController = TextEditingController();
  final _montoCompromisoController = TextEditingController();
  DateTime? _fechaCompromiso;

  @override
  void dispose() {
    _comentarioController.dispose();
    _montoCompromisoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acción de Cobranza')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pedro Sánchez',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    const Text('DNI: 20123456 | Crédito: CRD-2025-002',
                        style: TextStyle(color: BBVAColors.darkGray)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: BBVAColors.moraAmarillo.withAlpha(30),
                      child: const Text('Mora: 15 días | Deuda: S/ 2,500',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de Acción',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tipoAccion,
              items: const [
                DropdownMenuItem(value: 'llamada', child: Text('Llamada telefónica')),
                DropdownMenuItem(value: 'visita', child: Text('Visita domiciliaria')),
                DropdownMenuItem(value: 'notificacion', child: Text('Notificación escrita')),
                DropdownMenuItem(value: 'compromiso', child: Text('Compromiso de pago')),
              ],
              onChanged: (v) => setState(() => _tipoAccion = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montoCompromisoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto comprometido (S/)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_fechaCompromiso != null
                  ? 'Compromiso: ${_fechaCompromiso!.toLocal().toString().split(' ')[0]}'
                  : 'Fecha de compromiso'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) setState(() => _fechaCompromiso = date);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Acción registrada')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Registrar Acción'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
