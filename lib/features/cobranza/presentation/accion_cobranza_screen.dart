import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'cobranza_viewmodel.dart';

class AccionCobranzaScreen extends ConsumerStatefulWidget {
  final String clienteId;
  const AccionCobranzaScreen({super.key, required this.clienteId});

  @override
  ConsumerState<AccionCobranzaScreen> createState() =>
      _AccionCobranzaScreenState();
}

class _AccionCobranzaScreenState
    extends ConsumerState<AccionCobranzaScreen> {
  String _tipoGestion = 'Visita';
  String _resultado = 'Compromiso de pago';
  final _comentarioController = TextEditingController();
  final _montoCompromisoController = TextEditingController();
  final _montoPagadoController = TextEditingController();
  DateTime? _fechaCompromiso;

  @override
  void dispose() {
    _comentarioController.dispose();
    _montoCompromisoController.dispose();
    _montoPagadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cobranzaViewModelProvider);
    final vm = ref.read(cobranzaViewModelProvider.notifier);

    if (state.accionExitosa) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acción registrada correctamente')),
        );
        Navigator.pop(context);
        vm.resetAccion();
      });
    }

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
                child: Text('Cliente ID: ${widget.clienteId}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de Gestión',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tipoGestion,
              items: const [
                DropdownMenuItem(value: 'Visita', child: Text('Visita domiciliaria')),
                DropdownMenuItem(value: 'Llamada', child: Text('Llamada telefónica')),
                DropdownMenuItem(value: 'Mensaje', child: Text('Mensaje / Notificación')),
              ],
              onChanged: (v) => setState(() => _tipoGestion = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Resultado',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _resultado,
              items: const [
                DropdownMenuItem(value: 'Compromiso de pago', child: Text('Compromiso de pago')),
                DropdownMenuItem(value: 'Pago parcial', child: Text('Pago parcial')),
                DropdownMenuItem(value: 'Sin contacto', child: Text('Sin contacto')),
                DropdownMenuItem(value: 'Se niega a pagar', child: Text('Se niega a pagar')),
                DropdownMenuItem(value: 'Cliente ausente', child: Text('Cliente ausente')),
              ],
              onChanged: (v) => setState(() => _resultado = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montoPagadoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto pagado (S/)',
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
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(state.error!,
                    style: const TextStyle(color: BBVAColors.errorRed)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () => vm.registrarAccion(
                          clienteId: widget.clienteId,
                          creditoId: null,
                          tipoGestion: _tipoGestion,
                          resultado: _resultado,
                          observaciones: _comentarioController.text,
                          montoPagado:
                              double.tryParse(_montoPagadoController.text),
                          montoComprometido:
                              double.tryParse(_montoCompromisoController.text),
                          fechaCompromiso: _fechaCompromiso,
                        ),
                icon: const Icon(Icons.save),
                label: Text(state.isLoading
                    ? 'Guardando...' : 'Registrar Acción'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
