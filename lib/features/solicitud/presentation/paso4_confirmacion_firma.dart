import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'solicitud_viewmodel.dart';

class Paso4ConfirmacionFirma extends ConsumerStatefulWidget {
  final String solicitudId;
  const Paso4ConfirmacionFirma({super.key, required this.solicitudId});

  @override
  ConsumerState<Paso4ConfirmacionFirma> createState() =>
      _Paso4ConfirmacionFirmaState();
}

class _Paso4ConfirmacionFirmaState
    extends ConsumerState<Paso4ConfirmacionFirma> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: BBVAColors.primaryBlue,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(solicitudViewModelProvider.notifier).cargar(widget.solicitudId);
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solicitudViewModelProvider);
    final s = state.solicitud;
    final vm = ref.read(solicitudViewModelProvider.notifier);

    if (state.enviadoExitoso != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada al comité')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        vm.limpiar();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Confirmación y Firma')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : s == null
              ? const Center(child: Text('Error al cargar borrador'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resumen de la Solicitud',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const Divider(),
                      _resumenItem('Monto:',
                          'S/ ${Formatters.moneda(s.montoSolicitado)}'),
                      _resumenItem('Plazo:', '${s.plazoMeses} meses'),
                      _resumenItem('TEA:',
                          '${(s.teaReferencial ?? 18.5).toStringAsFixed(1)}%'),
                      _resumenItem('Garantía:', s.garantia),
                      if (s.cuotaEstimada != null)
                        _resumenItem('Cuota Mensual:',
                            'S/ ${Formatters.moneda(s.cuotaEstimada!)}'),
                      const SizedBox(height: 16),
                      const Text('Firma Digital',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: BBVAColors.mediumGray),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController,
                          height: 150,
                          backgroundColor: BBVAColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _signatureController.clear(),
                        child: const Text('Limpiar firma'),
                      ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(state.error!,
                              style: const TextStyle(color: BBVAColors.errorRed)),
                        ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final firma =
                                      await _signatureController.toPngBytes();
                                  if (firma == null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Debe firmar antes de enviar')),
                                    );
                                    return;
                                  }
                                  final b64 =
                                      base64Encode(firma);
                                  await vm.enviar(b64);
                                },
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar al Comité'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _resumenItem(String label, String value) {
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
}
