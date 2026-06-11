import 'package:flutter/material.dart';

class ConsultaBuroScreen extends StatefulWidget {
  final String clienteId;
  const ConsultaBuroScreen({super.key, required this.clienteId});

  @override
  State<ConsultaBuroScreen> createState() => _ConsultaBuroScreenState();
}

class _ConsultaBuroScreenState extends State<ConsultaBuroScreen> {
  bool _consentimiento = false;
  bool _consultando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta Buró')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Consentimiento del Cliente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Autorizo a BBVA a realizar la consulta de mi historial crediticio '
                  'en las centrales de riesgo (SBS, Infocorp, Sentinel) para la '
                  'evaluación de mi solicitud de crédito.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('He leído y acepto el consentimiento'),
              value: _consentimiento,
              onChanged: (v) => setState(() => _consentimiento = v ?? false),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _consentimiento && !_consultando
                    ? () async {
                        setState(() => _consultando = true);
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() => _consultando = false);
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Resultado Buró'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Score: 780 (Muy Bueno)'),
                                  SizedBox(height: 8),
                                  Text('Deuda Total: S/ 2,500'),
                                  Text('Entidades: 2'),
                                  Text('Días Atraso: 0'),
                                  Text('Protestos: Ninguno'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    : null,
                icon: _consultando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search),
                label: Text(_consultando ? 'Consultando...' : 'Consultar Buró'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
