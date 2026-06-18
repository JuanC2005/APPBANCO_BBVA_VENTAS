import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'solicitud_viewmodel.dart';

class Paso1DatosSolicitante extends ConsumerStatefulWidget {
  final String solicitudId;
  const Paso1DatosSolicitante({super.key, required this.solicitudId});

  @override
  ConsumerState<Paso1DatosSolicitante> createState() =>
      _Paso1DatosSolicitanteState();
}

class _Paso1DatosSolicitanteState
    extends ConsumerState<Paso1DatosSolicitante> {
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(solicitudViewModelProvider).solicitud;
      if (s != null) {
        _nombresController.text = s.tipoNegocio ?? '';
        _dniController.text = s.clienteId;
      }
    });
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solicitudViewModelProvider);
    final s = state.solicitud;
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Datos del Solicitante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _nombresController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _apellidosController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'DNI',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _dniController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              controller: _telefonoController,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: s == null
                    ? null
                    : () {
                        ref
                            .read(solicitudViewModelProvider.notifier)
                            .guardarPaso1({
                          'tipo_negocio': _nombresController.text,
                          'nombre_negocio': _apellidosController.text,
                        });
                        context.push(
                            '/solicitud/paso2/${widget.solicitudId}');
                      },
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
