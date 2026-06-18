import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/supabase/supabase_client.dart';

class AdminRoleManagementScreen extends StatefulWidget {
  const AdminRoleManagementScreen({super.key});

  @override
  State<AdminRoleManagementScreen> createState() =>
      _AdminRoleManagementScreenState();
}

class _AdminRoleManagementScreenState
    extends State<AdminRoleManagementScreen> {
  List<Map<String, dynamic>> _asesores = [];
  bool _loading = true;
  String _busqueda = '';
  String _filtroPerfil = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseClientProvider.client;
      final response = await supabase
          .from('vw_asesores_con_agencia')
          .select()
          .order('codigo_empleado');
      setState(() => _asesores = (response as List).cast<Map<String, dynamic>>());
    } catch (_) {
      try {
        final supabase = SupabaseClientProvider.client;
        final response = await supabase
            .from('asesores_negocio')
            .select('*, agencias(nombre)')
            .order('codigo_empleado');
        setState(() => _asesores = (response as List).cast<Map<String, dynamic>>());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtrados {
    var r = _asesores;
    if (_filtroPerfil != 'TODOS') {
      r = r.where((a) => a['perfil'] == _filtroPerfil).toList();
    }
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      r = r.where((a) =>
          (a['nombres'] ?? '').toLowerCase().contains(q) ||
          (a['apellidos'] ?? '').toLowerCase().contains(q) ||
          (a['codigo_empleado'] ?? '').toLowerCase().contains(q)).toList();
    }
    return r;
  }

  Future<void> _actualizarPerfil(String id, String nuevoPerfil) async {
    final supabase = SupabaseClientProvider.client;
    await supabase
        .from('asesores_negocio')
        .update({'perfil': nuevoPerfil})
        .eq('id', id);
    await _cargar();
  }

  Future<void> _toggleActivo(String id, bool activo) async {
    final supabase = SupabaseClientProvider.client;
    await supabase
        .from('asesores_negocio')
        .update({'activo': activo})
        .eq('id', id);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
    return Scaffold(
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtrados.isEmpty
                    ? const Center(child: Text('Sin resultados'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                              BBVAColors.lightBlue),
                          columns: const [
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Perfil')),
                            DataColumn(label: Text('Activo')),
                            DataColumn(label: Text('Agencia')),
                            DataColumn(label: Text('Visitas/Mes')),
                            DataColumn(label: Text('Créd./Mes')),
                            DataColumn(label: Text('Monto/Mes')),
                          ],
                          rows: filtrados
                              .map((a) => DataRow(cells: [
                                    DataCell(Text(a['codigo_empleado'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataCell(Text(
                                        '${a['nombres'] ?? ''} ${a['apellidos'] ?? ''}')),
                                    DataCell(Text(a['email'] ?? '')),
                                    DataCell(_buildPerfilDropdown(a)),
                                    DataCell(_buildActivoToggle(a)),
                                    DataCell(Text(
                                        a['agencias'] is Map
                                            ? (a['agencias']['nombre'] ?? '')
                                            : a['agencia_nombre'] ?? '',
                                        style: const TextStyle(fontSize: 12))),
                                    DataCell(Text(
                                        '${a['meta_visitas_mes'] ?? 0} / ${a['visitas_mes_actual'] ?? 0}')),
                                    DataCell(Text(
                                        '${a['meta_creditos_mes'] ?? 0} / ${a['creditos_mes_actual'] ?? 0}')),
                                    DataCell(Text(
                                        'S/ ${(a['monto_mes_actual'] as num?)?.toStringAsFixed(0) ?? '0'}')),
                                  ]))
                              .toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o código...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _filtroPerfil,
            items: const [
              DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
              DropdownMenuItem(value: 'operador', child: Text('Operador')),
              DropdownMenuItem(
                  value: 'super_operador', child: Text('Super Operador')),
              DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
              DropdownMenuItem(
                  value: 'administrador', child: Text('Administrador')),
            ],
            onChanged: (v) => setState(() => _filtroPerfil = v!),
          ),
          const Spacer(),
          Text('${_filtrados.length} asesores'),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
    );
  }

  Widget _buildPerfilDropdown(Map<String, dynamic> a) {
    final perfiles = ['operador', 'super_operador', 'supervisor', 'administrador'];
    return DropdownButton<String>(
      value: a['perfil'] ?? 'operador',
      underline: const SizedBox(),
      style: TextStyle(
        color: a['perfil'] == 'administrador'
            ? BBVAColors.errorRed
            : a['perfil'] == 'supervisor'
                ? BBVAColors.warningAmber
                : BBVAColors.successGreen,
        fontWeight: FontWeight.bold,
      ),
      items: perfiles
          .map((p) => DropdownMenuItem(
              value: p,
              child: Text(p.replaceFirst('_', ' '),
                  style: const TextStyle(fontSize: 12))))
          .toList(),
      onChanged: (v) {
        if (v != null) _actualizarPerfil(a['id'], v);
      },
    );
  }

  Widget _buildActivoToggle(Map<String, dynamic> a) {
    final activo = a['activo'] ?? true;
    return Switch(
      value: activo,
      onChanged: (v) => _toggleActivo(a['id'], v),
      activeThumbColor: BBVAColors.successGreen,
    );
  }
}
