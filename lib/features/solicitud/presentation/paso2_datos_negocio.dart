import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'solicitud_viewmodel.dart';

class Paso2DatosNegocio extends ConsumerStatefulWidget {
  final String solicitudId;
  const Paso2DatosNegocio({super.key, required this.solicitudId});

  @override
  ConsumerState<Paso2DatosNegocio> createState() => _Paso2DatosNegocioState();
}

class _Paso2DatosNegocioState extends ConsumerState<Paso2DatosNegocio> {
  final _negocioController = TextEditingController();
  final _direccionController = TextEditingController();
  final _tipoNegocioController = TextEditingController();
  final _antiguedadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(solicitudViewModelProvider.notifier).cargar(widget.solicitudId);
    });
  }

  @override
  void dispose() {
    _negocioController.dispose();
    _direccionController.dispose();
    _tipoNegocioController.dispose();
    _antiguedadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solicitudViewModelProvider);
    final s = state.solicitud;
    if (s != null) {
      _negocioController.text = s.nombreNegocio ?? '';
      _tipoNegocioController.text = s.tipoNegocio ?? '';
      _antiguedadController.text =
          s.antiguedadNegocioMeses?.toString() ?? '';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos del Negocio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Negocio',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _negocioController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _direccionController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tipo de Negocio',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _tipoNegocioController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Antigüedad (meses)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _antiguedadController,
              keyboardType: TextInputType.number,
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
                    onPressed: s == null
                        ? null
                        : () {
                            ref
                                .read(solicitudViewModelProvider.notifier)
                                .guardarPaso2({
                              'nombre_negocio': _negocioController.text,
                              'tipo_negocio': _tipoNegocioController.text,
                              'antiguedad_negocio_meses': int.tryParse(
                                  _antiguedadController.text),
                            });
                            context.push(
                                '/solicitud/paso3/${widget.solicitudId}');
                          },
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
