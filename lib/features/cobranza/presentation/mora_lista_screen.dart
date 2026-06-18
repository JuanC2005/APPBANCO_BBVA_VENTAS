import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'cobranza_viewmodel.dart';
import '../domain/cliente_mora.dart';

class MoraListaScreen extends ConsumerStatefulWidget {
  const MoraListaScreen({super.key});

  @override
  ConsumerState<MoraListaScreen> createState() => _MoraListaScreenState();
}

class _MoraListaScreenState extends ConsumerState<MoraListaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cobranzaViewModelProvider.notifier).cargarMora();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cobranzaViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cobranza - Mora')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.clientesMora.isEmpty
                  ? const Center(child: Text('Sin clientes en mora'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: state.clientesMora
                          .map((c) => _clienteCard(c))
                          .toList(),
                    ),
    );
  }

  Widget _clienteCard(ClienteMora c) {
    Color color;
    if (c.diasMora <= 15) {
      color = BBVAColors.moraAmarillo;
    } else if (c.diasMora <= 45) {
      color = BBVAColors.moraNaranja;
    } else {
      color = BBVAColors.moraRojo;
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(50),
          child: Text(c.clienteNombre.isNotEmpty
              ? c.clienteNombre[0]
              : '?',
              style: TextStyle(color: color)),
        ),
        title: Text(c.clienteNombre,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Deuda: S/ ${c.deuda.toStringAsFixed(0)} · Atraso: ${c.diasMora} días'),
        trailing: Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        onTap: () => context.push('/accion-cobranza/${c.clienteId}'),
      ),
    );
  }
}
