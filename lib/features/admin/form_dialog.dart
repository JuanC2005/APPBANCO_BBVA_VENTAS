import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/storage/supabase/supabase_client.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/table_config.dart';

class FormDialog extends StatefulWidget {
  final TableConfig tableConfig;
  final Map<String, dynamic>? existingData;

  const FormDialog({
    super.key,
    required this.tableConfig,
    this.existingData,
  });

  bool get isEditing => existingData != null;

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final Map<String, List<Map<String, dynamic>>> _foreignOptions = {};
  bool _loadingForeign = false;

  @override
  void initState() {
    super.initState();
    _initValues();
    _loadForeignOptions();
  }

  void _initValues() {
    for (final col in widget.tableConfig.columns) {
      if (!col.showInForm) continue;
      if (widget.existingData != null &&
          widget.existingData!.containsKey(col.fieldName)) {
        _values[col.fieldName] = widget.existingData![col.fieldName];
      } else {
        _values[col.fieldName] =
            col.type == ColumnType.boolean ? false : null;
      }
    }
  }

  Future<void> _loadForeignOptions() async {
    final foreignCols = widget.tableConfig.columns
        .where((c) => c.foreignTable != null && c.showInForm);
    if (foreignCols.isEmpty) return;
    setState(() => _loadingForeign = true);
    for (final col in foreignCols) {
      try {
        final data = await SupabaseClientProvider.client
            .from(col.foreignTable!)
            .select('id, ${col.foreignLabel ?? "id"}');
        _foreignOptions[col.fieldName] =
            List<Map<String, dynamic>>.from(data);
      } catch (_) {}
    }
    if (mounted) setState(() => _loadingForeign = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final data = <String, dynamic>{};
      for (final col in widget.tableConfig.formColumns) {
        final val = _values[col.fieldName];
        if (val == null) continue;
        if (col.type == ColumnType.date && val is DateTime) {
          data[col.fieldName] = DateFormat('yyyy-MM-dd').format(val);
        } else if (col.type == ColumnType.datetime && val is DateTime) {
          data[col.fieldName] = val.toUtc().toIso8601String();
        } else if (col.type == ColumnType.boolean) {
          data[col.fieldName] = val;
        } else if (val is String && val.trim().isEmpty) {
          if (col.required) {
            data[col.fieldName] = val.trim();
          }
        } else {
          data[col.fieldName] = val is String ? val.trim() : val;
        }
      }

      if (widget.isEditing) {
        final id = widget.existingData![widget.tableConfig.primaryKey];
        await SupabaseClientProvider.client
            .from(widget.tableConfig.tableName)
            .update(data)
            .eq(widget.tableConfig.primaryKey, id);
      } else {
        await SupabaseClientProvider.client
            .from(widget.tableConfig.tableName)
            .insert(data);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Registro actualizado correctamente'
                : 'Registro creado correctamente'),
            backgroundColor: BBVAColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: BBVAColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: BBVAColors.primaryBlue,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(widget.tableConfig.icon,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isEditing
                        ? 'Editar ${widget.tableConfig.displayName}'
                        : 'Nuevo ${widget.tableConfig.displayName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: _loadingForeign
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final col
                              in widget.tableConfig.formColumns)
                            _buildField(col),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BBVAColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              widget.isEditing ? 'Actualizar' : 'Crear',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(ColumnConfig col) {
    if (col.type == ColumnType.boolean) {
      return _buildBooleanField(col);
    }
    if (col.type == ColumnType.date || col.type == ColumnType.datetime) {
      return _buildDateField(col);
    }
    if (col.type == ColumnType.stringEnum && col.enumValues != null) {
      return _buildDropdownField(col);
    }
    if (col.foreignTable != null &&
        _foreignOptions.containsKey(col.fieldName)) {
      return _buildForeignDropdown(col);
    }
    return _buildTextField(col);
  }

  Widget _buildTextField(ColumnConfig col) {
    TextInputType? keyboardType;
    List<TextInputFormatter>? inputFormatters;
    int maxLines = 1;

    switch (col.type) {
      case ColumnType.integer:
        keyboardType = TextInputType.number;
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case ColumnType.decimal:
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ];
        break;
      case ColumnType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case ColumnType.phone:
        keyboardType = TextInputType.phone;
        break;
      case ColumnType.textarea:
        maxLines = 4;
        break;
      case ColumnType.uuid:
        keyboardType = TextInputType.text;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _values[col.fieldName]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: col.label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        readOnly: col.type == ColumnType.uuid,
        validator: (v) {
          if (col.required && (v == null || v.trim().isEmpty)) {
            return '${col.label} es requerido';
          }
          return null;
        },
        onSaved: (v) {
          if (v == null || v.trim().isEmpty) {
            _values[col.fieldName] = null;
            return;
          }
          switch (col.type) {
            case ColumnType.integer:
              _values[col.fieldName] = int.tryParse(v.trim());
              break;
            case ColumnType.decimal:
              _values[col.fieldName] = double.tryParse(v.trim());
              break;
            default:
              _values[col.fieldName] = v.trim();
          }
        },
      ),
    );
  }

  Widget _buildBooleanField(ColumnConfig col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        title: Text(col.label),
        value: _values[col.fieldName] == true,
        onChanged: (v) => setState(() => _values[col.fieldName] = v),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDateField(ColumnConfig col) {
    final currentValue = _values[col.fieldName];
    DateTime? dateValue;
    if (currentValue is String) {
      dateValue = DateTime.tryParse(currentValue);
    } else if (currentValue is DateTime) {
      dateValue = currentValue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: dateValue ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2035),
          );
          if (picked != null) {
            setState(() => _values[col.fieldName] = picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: col.label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            isDense: true,
          ),
          child: Text(
            dateValue != null
                ? DateFormat('dd/MM/yyyy').format(dateValue)
                : 'Seleccionar fecha...',
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(ColumnConfig col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _values[col.fieldName]?.toString(),
        decoration: InputDecoration(
          labelText: col.label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem(
              value: null, child: Text('Seleccionar...')),
          ...col.enumValues!.map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              )),
        ],
        onChanged: (v) => setState(() => _values[col.fieldName] = v),
        validator: (v) {
          if (col.required && v == null) {
            return '${col.label} es requerido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildForeignDropdown(ColumnConfig col) {
    final options = _foreignOptions[col.fieldName] ?? [];
    final currentId = _values[col.fieldName]?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: currentId,
        decoration: InputDecoration(
          labelText: col.label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        isExpanded: true,
        items: [
          const DropdownMenuItem(
              value: null, child: Text('Seleccionar...')),
          ...options.map((o) {
            final id = o['id'].toString();
            final label = o[col.foreignLabel ?? 'id']?.toString() ?? id;
            return DropdownMenuItem(
              value: id,
              child: Text(
                '$label (${id.substring(0, 6)}...)',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
        onChanged: (v) => setState(() => _values[col.fieldName] = v),
        validator: (v) {
          if (col.required && v == null) {
            return '${col.label} es requerido';
          }
          return null;
        },
      ),
    );
  }
}
