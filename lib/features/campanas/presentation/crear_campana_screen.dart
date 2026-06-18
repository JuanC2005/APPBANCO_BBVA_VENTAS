import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../domain/campana.dart';
import 'campanas_viewmodel.dart';

class CrearCampanaScreen extends ConsumerStatefulWidget {
  const CrearCampanaScreen({super.key});

  @override
  ConsumerState<CrearCampanaScreen> createState() =>
      _CrearCampanaScreenState();
}

class _CrearCampanaScreenState extends ConsumerState<CrearCampanaScreen> {
  final _tituloCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  final _productoCtrl = TextEditingController();
  String _tipo = 'marketing';
  String _segmento = 'TODOS';
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _mensajeCtrl.dispose();
    _productoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty ||
        _mensajeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y mensaje son obligatorios')),
      );
      return;
    }
    final asesor = ref.read(authViewModelProvider).asesor;
    if (asesor == null) return;

    final campana = Campana(
      id: '',
      titulo: _tituloCtrl.text.trim(),
      mensaje: _mensajeCtrl.text.trim(),
      tipo: _tipo,
      segmentoObjetivo: _segmento,
      productoSugerido: _productoCtrl.text.trim().isEmpty
          ? null
          : _productoCtrl.text.trim(),
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      activa: true,
      leida: false,
      createdAt: DateTime.now(),
    );

    await ref
        .read(campanasViewModelProvider.notifier)
        .crearCampana(campana, asesor.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaña creada')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Campaña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mensajeCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                DropdownMenuItem(value: 'cobranza', child: Text('Cobranza')),
                DropdownMenuItem(
                    value: 'capacitacion', child: Text('Capacitación')),
                DropdownMenuItem(
                    value: 'informativa', child: Text('Informativa')),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _segmento,
              items: const [
                DropdownMenuItem(value: 'TODOS', child: Text('Todos los segmentos')),
                DropdownMenuItem(value: 'A', child: Text('Segmento A')),
                DropdownMenuItem(value: 'B', child: Text('Segmento B')),
                DropdownMenuItem(value: 'C', child: Text('Segmento C')),
                DropdownMenuItem(value: 'D', child: Text('Segmento D')),
                DropdownMenuItem(value: 'E', child: Text('Segmento E')),
              ],
              onChanged: (v) => setState(() => _segmento = v!),
              decoration: const InputDecoration(
                labelText: 'Segmento objetivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _productoCtrl,
              decoration: const InputDecoration(
                labelText: 'Producto sugerido (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                  'Inicio: ${_fechaInicio.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _fechaInicio,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _fechaInicio = d);
              },
            ),
            ListTile(
              title: Text(
                  'Fin: ${_fechaFin?.toLocal().toString().split(' ')[0] ?? 'Sin fecha de fin'}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate:
                      _fechaFin ?? _fechaInicio.add(const Duration(days: 30)),
                  firstDate: _fechaInicio,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _fechaFin = d);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Crear Campaña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
