import 'package:flutter/material.dart';
import '../../core/storage/supabase/supabase_client.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/table_config.dart';
import 'form_dialog.dart';

class TableListScreen extends StatefulWidget {
  final String tableName;

  const TableListScreen({super.key, required this.tableName});

  @override
  State<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  Map<String, Map<String, String>> _foreignLookups = {};

  TableConfig? get _config => DatabaseTables.getByTableName(widget.tableName);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TableListScreen oldWidget) {
    if (oldWidget.tableName != widget.tableName) {
      _loadData();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadData() async {
    if (_config == null) return;
    setState(() => _loading = true);
    try {
      final response = await SupabaseClientProvider.client
          .from(widget.tableName)
          .select()
          .order(_config!.tableColumns.first.fieldName,
              ascending: false)
          .limit(500);
      _data = List<Map<String, dynamic>>.from(response);

      await _resolveForeignKeys();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: BBVAColors.errorRed,
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _resolveForeignKeys() async {
    _foreignLookups = {};
    for (final col in _config!.tableColumns) {
      if (col.foreignTable == null || col.foreignLabel == null) continue;
      if (_foreignLookups.containsKey(col.foreignTable)) continue;

      final ids = _data
          .map((r) => r[col.fieldName]?.toString())
          .where((v) => v != null)
          .toSet()
          .toList();
      if (ids.isEmpty) continue;

      try {
        final foreignData = await SupabaseClientProvider.client
            .from(col.foreignTable!)
            .select('id, ${col.foreignLabel}')
            .inFilter('id', ids);
        _foreignLookups[col.foreignTable!] = {
          for (final row in List<Map<String, dynamic>>.from(foreignData))
            row['id'].toString(): row[col.foreignLabel]?.toString() ?? '-',
        };
      } catch (_) {
        _foreignLookups[col.foreignTable!] = {};
      }
    }
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
            '¿Estás seguro de eliminar este registro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await SupabaseClientProvider.client
          .from(widget.tableName)
          .delete()
          .eq('id', id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro eliminado'),
            backgroundColor: BBVAColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: BBVAColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _openForm(Map<String, dynamic>? record) async {
    if (_config == null) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => FormDialog(
        tableConfig: _config!,
        existingData: record,
      ),
    );
    if (result == true) _loadData();
  }

  List<Map<String, dynamic>> get _filteredData {
    if (_searchQuery.isEmpty) return _data;
    final q = _searchQuery.toLowerCase();
    return _data.where((row) {
      for (final col in _config!.tableColumns) {
        final val = row[col.fieldName]?.toString().toLowerCase() ?? '';
        if (val.contains(q)) return true;
        if (col.foreignTable != null) {
          final lookup = _foreignLookups[col.foreignTable];
          final id = row[col.fieldName]?.toString();
          if (lookup != null && id != null) {
            final fv = lookup[id]?.toLowerCase();
            if (fv != null && fv.contains(q)) return true;
          }
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null) {
      return const Center(child: Text('Configuración de tabla no encontrada'));
    }
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Icon(_config!.icon, color: BBVAColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          Text(
            _config!.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 280,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _openForm(null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BBVAColors.primaryBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final data = _filteredData;
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Sin resultados para "$_searchQuery"'
                  : 'No hay registros',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor:
              WidgetStateProperty.all(BBVAColors.lightBlue),
          columnSpacing: 20,
          columns: _buildColumns(),
          rows: _buildRows(data),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final cols = <DataColumn>[];
    cols.add(const DataColumn(label: Text('#')));
    for (final colConfig in _config!.tableColumns) {
      cols.add(
        DataColumn(
          label: Text(
            colConfig.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: (idx, asc) {
            setState(() {
              _sortColumnIndex = idx;
              _sortAscending = asc;
            });
          },
        ),
      );
    }
    cols.add(const DataColumn(label: Text('Acciones')));
    return cols;
  }

  List<DataRow> _buildRows(List<Map<String, dynamic>> data) {
    final cols = _config!.tableColumns;
    return data.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final row = entry.value;
      final id = row[_config!.primaryKey]?.toString() ?? '';
      return DataRow(
        color: WidgetStateProperty.resolveWith<Color?>((states) {
          if (idx.isEven) return Colors.grey[50];
          return null;
        }),
        cells: [
          DataCell(Text('$idx', style: const TextStyle(fontSize: 12))),
          for (final colConfig in cols)
            DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  colConfig.foreignTable != null
                      ? _formatForeignValue(row, colConfig)
                      : _formatCellValue(row[colConfig.fieldName], colConfig),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: colConfig.type == ColumnType.decimal
                        ? FontWeight.w500
                        : null,
                    color: _getCellColor(row[colConfig.fieldName], colConfig),
                  ),
                ),
              ),
            ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: BBVAColors.primaryBlue,
                  tooltip: 'Editar',
                  onPressed: () => _openForm(row),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  color: BBVAColors.errorRed,
                  tooltip: 'Eliminar',
                  onPressed: () => _deleteRecord(id),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  String _formatForeignValue(Map<String, dynamic> row, ColumnConfig col) {
    final lookup = _foreignLookups[col.foreignTable];
    final id = row[col.fieldName]?.toString();
    if (lookup != null && id != null && lookup.containsKey(id)) {
      return lookup[id]!;
    }
    return _formatCellValue(row[col.fieldName], col);
  }

  String _formatCellValue(dynamic value, ColumnConfig col) {
    if (value == null) return '-';
    switch (col.type) {
      case ColumnType.decimal:
        return 'S/ ${(value as num).toStringAsFixed(2)}';
      case ColumnType.date:
        if (value is String) {
          final dt = DateTime.tryParse(value);
          if (dt != null) {
            return '${dt.day.toString().padLeft(2, '0')}/'
                '${dt.month.toString().padLeft(2, '0')}/'
                '${dt.year}';
          }
        }
        return value.toString();
      case ColumnType.datetime:
        if (value is String) {
          final dt = DateTime.tryParse(value);
          if (dt != null) {
            return '${dt.day.toString().padLeft(2, '0')}/'
                '${dt.month.toString().padLeft(2, '0')}/'
                '${dt.year} '
                '${dt.hour.toString().padLeft(2, '0')}:'
                '${dt.minute.toString().padLeft(2, '0')}';
          }
        }
        return value.toString();
      case ColumnType.boolean:
        return value == true ? 'Sí' : 'No';
      case ColumnType.uuid:
        final s = value.toString();
        return s.length > 8 ? '${s.substring(0, 8)}...' : s;
      case ColumnType.integer:
        return value.toString();
      default:
        return value.toString();
    }
  }

  Color? _getCellColor(dynamic value, ColumnConfig col) {
    if (col.fieldName == 'estado' || col.fieldName == 'estado_cliente' ||
        col.fieldName == 'estado_visita') {
      final v = value?.toString();
      if (v == null) return null;
      if (v.contains('rechaz') || v == 'vencido' || v == 'moroso' || v == 'castigado' ||
          v == 'no_encontrado' || v == 'negocio_cerrado') {
        return BBVAColors.errorRed;
      }
      if (v == 'aprobado' || v == 'desembolsado' || v == 'pagado' ||
          v == 'activo' || v == 'visitado' || v == 'LISTO') {
        return BBVAColors.successGreen;
      }
      if (v == 'pendiente' || v == 'borrador' || v == 'PENDIENTE' ||
          v == 'reagendado' || v == 'en_evaluacion') {
        return BBVAColors.warningAmber;
      }
    }
    if (col.fieldName == 'prioridad') {
      final v = value?.toString();
      if (v == 'alta') return BBVAColors.errorRed;
      if (v == 'media') return BBVAColors.warningAmber;
    }
    if (col.type == ColumnType.boolean) {
      return value == true ? BBVAColors.successGreen : BBVAColors.mediumGray;
    }
    return null;
  }
}
