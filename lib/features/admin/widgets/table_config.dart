import 'package:flutter/material.dart';

enum ColumnType {
  text,
  integer,
  decimal,
  boolean,
  date,
  datetime,
  email,
  phone,
  stringEnum,
  uuid,
  json,
  textarea,
}

class ColumnConfig {
  final String fieldName;
  final String label;
  final ColumnType type;
  final bool editable;
  final bool required;
  final List<String>? enumValues;
  final bool showInTable;
  final bool showInForm;
  final double? flex;
  final String? foreignTable;
  final String? foreignLabel;

  const ColumnConfig({
    required this.fieldName,
    required this.label,
    this.type = ColumnType.text,
    this.editable = true,
    this.required = false,
    this.enumValues,
    this.showInTable = true,
    this.showInForm = true,
    this.flex,
    this.foreignTable,
    this.foreignLabel,
  });
}

class TableConfig {
  final String tableName;
  final String displayName;
  final IconData icon;
  final String category;
  final List<ColumnConfig> columns;
  final String primaryKey;

  const TableConfig({
    required this.tableName,
    required this.displayName,
    required this.icon,
    required this.category,
    required this.columns,
    this.primaryKey = 'id',
  });

  List<ColumnConfig> get tableColumns =>
      columns.where((c) => c.showInTable).toList();

  List<ColumnConfig> get formColumns =>
      columns.where((c) => c.showInForm && c.editable).toList();

  ColumnConfig? columnByName(String name) {
    try {
      return columns.firstWhere((c) => c.fieldName == name);
    } catch (_) {
      return null;
    }
  }
}

class DatabaseTables {
  static const List<TableConfig> allTables = [
    // ─── MAESTROS ───────────────────────────────────────
    TableConfig(
      tableName: 'agencias',
      displayName: 'Agencias',
      icon: Icons.business,
      category: 'Maestros',
      columns: [
        ColumnConfig(fieldName: 'codigo', label: 'Código', required: true),
        ColumnConfig(fieldName: 'nombre', label: 'Nombre', required: true),
        ColumnConfig(
            fieldName: 'tipo',
            label: 'Tipo',
            type: ColumnType.stringEnum,
            enumValues: [
              'agencia',
              'oficina_especial',
              'ventanilla',
              'banca_empresas'
            ]),
        ColumnConfig(fieldName: 'departamento', label: 'Departamento'),
        ColumnConfig(fieldName: 'provincia', label: 'Provincia'),
        ColumnConfig(fieldName: 'distrito', label: 'Distrito'),
        ColumnConfig(fieldName: 'direccion', label: 'Dirección'),
        ColumnConfig(
            fieldName: 'lat', label: 'Latitud', type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'lng', label: 'Longitud', type: ColumnType.decimal),
        ColumnConfig(fieldName: 'region', label: 'Región'),
        ColumnConfig(
            fieldName: 'activa',
            label: 'Activa',
            type: ColumnType.boolean),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'asesores_negocio',
      displayName: 'Asesores',
      icon: Icons.person,
      category: 'Maestros',
      columns: [
        ColumnConfig(
            fieldName: 'codigo_empleado',
            label: 'Código Empleado',
            required: true),
        ColumnConfig(
            fieldName: 'nombres', label: 'Nombres', required: true),
        ColumnConfig(
            fieldName: 'apellidos', label: 'Apellidos', required: true),
        ColumnConfig(
            fieldName: 'email', label: 'Email', type: ColumnType.email),
        ColumnConfig(
            fieldName: 'agencia_id',
            label: 'Agencia ID',
            type: ColumnType.uuid,
            foreignTable: 'agencias',
            foreignLabel: 'nombre'),
        ColumnConfig(
            fieldName: 'especialidad',
            label: 'Especialidad',
            type: ColumnType.stringEnum,
            enumValues: [
              'microempresa',
              'pequena_empresa',
              'agropecuario',
              'consumo',
              'hipotecario',
              'banca_empresas'
            ]),
        ColumnConfig(
            fieldName: 'perfil',
            label: 'Perfil',
            type: ColumnType.stringEnum,
            enumValues: [
              'operador',
              'super_operador',
              'supervisor',
              'administrador'
            ]),
        ColumnConfig(
            fieldName: 'zona_asignada', label: 'Zona Asignada'),
        ColumnConfig(
            fieldName: 'activo',
            label: 'Activo',
            type: ColumnType.boolean),
        ColumnConfig(
            fieldName: 'meta_visitas_mes',
            label: 'Meta Visitas/Mes',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'meta_creditos_mes',
            label: 'Meta Créditos/Mes',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'meta_monto_mes',
            label: 'Meta Monto/Mes',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'visitas_mes_actual',
            label: 'Visitas Mes Actual',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'creditos_mes_actual',
            label: 'Créditos Mes Actual',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'monto_mes_actual',
            label: 'Monto Mes Actual',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'user_id',
            label: 'User ID',
            type: ColumnType.uuid,
            editable: false,
            showInTable: false),
        ColumnConfig(
            fieldName: 'token_fcm',
            label: 'Token FCM',
            editable: false,
            showInTable: false,
            showInForm: false),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'clientes',
      displayName: 'Clientes',
      icon: Icons.people,
      category: 'Maestros',
      columns: [
        ColumnConfig(
            fieldName: 'numero_documento',
            label: 'N° Documento',
            required: true),
        ColumnConfig(
            fieldName: 'tipo_documento',
            label: 'Tipo Doc',
            type: ColumnType.stringEnum,
            enumValues: ['DNI', 'RUC', 'CE']),
        ColumnConfig(
            fieldName: 'nombres', label: 'Nombres', required: true),
        ColumnConfig(
            fieldName: 'apellidos', label: 'Apellidos', required: true),
        ColumnConfig(
            fieldName: 'fecha_nacimiento',
            label: 'F. Nacimiento',
            type: ColumnType.date),
        ColumnConfig(
            fieldName: 'estado_civil',
            label: 'Estado Civil',
            type: ColumnType.stringEnum,
            enumValues: [
              'Soltero',
              'Casado',
              'Conviviente',
              'Divorciado',
              'Viudo'
            ]),
        ColumnConfig(
            fieldName: 'genero',
            label: 'Género',
            type: ColumnType.stringEnum,
            enumValues: ['M', 'F', 'otro']),
        ColumnConfig(
            fieldName: 'telefono', label: 'Teléfono', type: ColumnType.phone),
        ColumnConfig(
            fieldName: 'email', label: 'Email', type: ColumnType.email),
        ColumnConfig(fieldName: 'direccion', label: 'Dirección'),
        ColumnConfig(fieldName: 'tipo_negocio', label: 'Tipo Negocio'),
        ColumnConfig(fieldName: 'nombre_negocio', label: 'Nombre Negocio'),
        ColumnConfig(
            fieldName: 'antiguedad_negocio_meses',
            label: 'Antigüedad (meses)',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'ingresos_estimados',
            label: 'Ingresos Est.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'gastos_mensuales',
            label: 'Gastos Mens.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'deuda_actual',
            label: 'Deuda Actual',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'entidades_deuda',
            label: 'Entidades Deuda',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'calificacion_sbs',
            label: 'Calif. SBS',
            type: ColumnType.stringEnum,
            enumValues: [
              'Normal',
              'CPP',
              'Deficiente',
              'Dudoso',
              'Perdida',
              'Sin_Historial'
            ]),
        ColumnConfig(
            fieldName: 'estado_cliente',
            label: 'Estado',
            type: ColumnType.stringEnum,
            enumValues: [
              'activo',
              'moroso',
              'castigado',
              'retirado',
              'prospecto'
            ]),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
        ColumnConfig(
            fieldName: 'updated_at',
            label: 'Actualizado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),

    // ─── CRÉDITOS ───────────────────────────────────────
    TableConfig(
      tableName: 'creditos',
      displayName: 'Créditos',
      icon: Icons.account_balance,
      category: 'Créditos',
      columns: [
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'agencia_id',
            label: 'Agencia ID',
            type: ColumnType.uuid,
            foreignTable: 'agencias',
            foreignLabel: 'nombre'),
        ColumnConfig(
            fieldName: 'producto',
            label: 'Producto',
            type: ColumnType.stringEnum,
            enumValues: [
              'credito_negocios',
              'credito_efectivo',
              'credito_agropecuario',
              'leasing',
              'tarjeta_credito',
              'hipotecario'
            ]),
        ColumnConfig(
            fieldName: 'monto_desembolsado',
            label: 'Monto Desemb.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'plazo_meses',
            label: 'Plazo (meses)',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'tea', label: 'TEA %', type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'cuotas_totales',
            label: 'Cuotas Totales',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'cuotas_pagadas',
            label: 'Cuotas Pagadas',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'cuotas_mora',
            label: 'Cuotas Mora',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'saldo_actual',
            label: 'Saldo Actual',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'fecha_desembolso',
            label: 'F. Desembolso',
            type: ColumnType.date),
        ColumnConfig(
            fieldName: 'fecha_vencimiento',
            label: 'F. Vencimiento',
            type: ColumnType.date),
        ColumnConfig(
            fieldName: 'estado',
            label: 'Estado',
            type: ColumnType.stringEnum,
            enumValues: ['vigente', 'vencido', 'castigado', 'pagado']),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'creditos_preaprobados',
      displayName: 'Preaprobados',
      icon: Icons.auto_awesome,
      category: 'Créditos',
      columns: [
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'monto_maximo',
            label: 'Monto Máximo',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'plazo_sugerido_meses',
            label: 'Plazo Sug. (meses)',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'tea_referencial',
            label: 'TEA Ref. %',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'score_confianza',
            label: 'Score Confianza',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'vigente',
            label: 'Vigente',
            type: ColumnType.boolean),
        ColumnConfig(
            fieldName: 'fecha_calculo',
            label: 'F. Cálculo',
            type: ColumnType.date,
            editable: false),
        ColumnConfig(
            fieldName: 'fecha_vencimiento',
            label: 'F. Vencimiento',
            type: ColumnType.date),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'scores_crediticios',
      displayName: 'Scores Crediticios',
      icon: Icons.score,
      category: 'Créditos',
      columns: [
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'score', label: 'Score', type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'segmento',
            label: 'Segmento',
            type: ColumnType.stringEnum,
            enumValues: ['A', 'B', 'C', 'D', 'E']),
        ColumnConfig(
            fieldName: 'recomendacion', label: 'Recomendación'),
        ColumnConfig(
            fieldName: 'monto_max_sugerido',
            label: 'Monto Máx. Sug.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'nivel_confianza',
            label: 'Nivel Confianza',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'modelo_version', label: 'Modelo Versión'),
        ColumnConfig(
            fieldName: 'calculado_at',
            label: 'Calculado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),

    // ─── SOLICITUDES ────────────────────────────────────
    TableConfig(
      tableName: 'solicitudes_credito',
      displayName: 'Solicitudes',
      icon: Icons.description,
      category: 'Solicitudes',
      columns: [
        ColumnConfig(
            fieldName: 'numero_expediente', label: 'N° Expediente'),
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'agencia_id',
            label: 'Agencia ID',
            type: ColumnType.uuid,
            foreignTable: 'agencias',
            foreignLabel: 'nombre'),
        ColumnConfig(
            fieldName: 'monto_solicitado',
            label: 'Monto Solicitado',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'plazo_meses',
            label: 'Plazo (meses)',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'estado',
            label: 'Estado',
            type: ColumnType.stringEnum,
            enumValues: [
              'borrador',
              'enviado',
              'recibido_comite',
              'en_evaluacion',
              'aprobado',
              'condicionado',
              'rechazado',
              'desembolsado'
            ]),
        ColumnConfig(
            fieldName: 'monto_aprobado',
            label: 'Monto Aprobado',
            type: ColumnType.decimal),
        ColumnConfig(fieldName: 'motivo_rechazo', label: 'Motivo Rechazo'),
        ColumnConfig(
            fieldName: 'tipo_negocio',
            label: 'Tipo Negocio',
            showInTable: false),
        ColumnConfig(
            fieldName: 'nombre_negocio',
            label: 'Nombre Negocio',
            showInTable: false),
        ColumnConfig(
            fieldName: 'ingresos_estimados',
            label: 'Ingresos Est.',
            type: ColumnType.decimal,
            showInTable: false),
        ColumnConfig(
            fieldName: 'gastos_mensuales',
            label: 'Gastos Mens.',
            type: ColumnType.decimal,
            showInTable: false),
        ColumnConfig(
            fieldName: 'destino_credito',
            label: 'Destino Crédito',
            showInTable: false),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
        ColumnConfig(
            fieldName: 'updated_at',
            label: 'Actualizado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'cartera_diaria',
      displayName: 'Cartera Diaria',
      icon: Icons.calendar_today,
      category: 'Solicitudes',
      columns: [
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'agencia_id',
            label: 'Agencia ID',
            type: ColumnType.uuid,
            foreignTable: 'agencias',
            foreignLabel: 'nombre'),
        ColumnConfig(
            fieldName: 'fecha_asignacion',
            label: 'F. Asignación',
            type: ColumnType.date),
        ColumnConfig(
            fieldName: 'tipo_gestion',
            label: 'Tipo Gestión',
            type: ColumnType.stringEnum,
            enumValues: [
              'RENOVACION',
              'AMPLIACION',
              'NUEVA_SOLICITUD',
              'SEGUIMIENTO',
              'RECUPERACION_MORA',
              'DESERTOR'
            ]),
        ColumnConfig(
            fieldName: 'prioridad',
            label: 'Prioridad',
            type: ColumnType.stringEnum,
            enumValues: ['alta', 'media', 'normal']),
        ColumnConfig(
            fieldName: 'score_prioridad',
            label: 'Score Prioridad',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'monto_referencial',
            label: 'Monto Ref.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'estado_visita',
            label: 'Estado Visita',
            type: ColumnType.stringEnum,
            enumValues: [
              'pendiente',
              'visitado',
              'no_encontrado',
              'reagendado',
              'negocio_cerrado'
            ]),
        ColumnConfig(
            fieldName: 'resultado_visita', label: 'Resultado Visita'),
        ColumnConfig(
            fieldName: 'observacion_visita', label: 'Observación'),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'solicitudes_documentos',
      displayName: 'Documentos',
      icon: Icons.attach_file,
      category: 'Solicitudes',
      columns: [
        ColumnConfig(
            fieldName: 'solicitud_id',
            label: 'Solicitud ID',
            type: ColumnType.uuid,
            foreignTable: 'solicitudes_credito',
            foreignLabel: 'numero_expediente'),
        ColumnConfig(fieldName: 'tipo_documento', label: 'Tipo Documento'),
        ColumnConfig(fieldName: 'url_documento', label: 'URL Documento'),
        ColumnConfig(
            fieldName: 'estado',
            label: 'Estado',
            type: ColumnType.stringEnum,
            enumValues: ['LISTO', 'PENDIENTE', 'OBLIGATORIO']),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'fichas_campo',
      displayName: 'Fichas Campo',
      icon: Icons.explore,
      category: 'Solicitudes',
      columns: [
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'tipo_visita',
            label: 'Tipo Visita',
            type: ColumnType.stringEnum,
            enumValues: [
              'prospeccion',
              'renovacion',
              'seguimiento',
              'cobranza'
            ]),
        ColumnConfig(fieldName: 'distrito', label: 'Distrito'),
        ColumnConfig(fieldName: 'resultado', label: 'Resultado'),
        ColumnConfig(fieldName: 'observaciones', label: 'Observaciones'),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),

    // ─── PERFILES ───────────────────────────────────────
    TableConfig(
      tableName: 'perfiles_clientes',
      displayName: 'Perfiles Clientes',
      icon: Icons.person_outline,
      category: 'Perfiles',
      columns: [
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(fieldName: 'tipo_negocio', label: 'Tipo Negocio'),
        ColumnConfig(
            fieldName: 'antiguedad_negocio',
            label: 'Antigüedad Neg.',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'local_propio',
            label: 'Local Propio',
            type: ColumnType.boolean),
        ColumnConfig(
            fieldName: 'zona_negocio',
            label: 'Zona Negocio',
            type: ColumnType.stringEnum,
            enumValues: ['urbano', 'periurbano', 'rural']),
        ColumnConfig(
            fieldName: 'ingreso_mensual_est',
            label: 'Ingreso Mensual',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'gasto_mensual_est',
            label: 'Gasto Mensual',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'patrimonio_estimado',
            label: 'Patrimonio Est.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'puntaje_crediticio',
            label: 'Puntaje Crediticio',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
        ColumnConfig(
            fieldName: 'updated_at',
            label: 'Actualizado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'features_scoring',
      displayName: 'Features Scoring',
      icon: Icons.analytics,
      category: 'Perfiles',
      columns: [
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'promedio_saldo_3m',
            label: 'Prom. Saldo 3m',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'variabilidad_saldo',
            label: 'Variabilidad Saldo',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'ratio_credito_debito',
            label: 'Ratio Créd/Déb',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'frecuencia_transacciones',
            label: 'Frec. Transacc.',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'porcentaje_pagos_puntual',
            label: '% Pagos Puntual',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'ratio_deuda_ingreso',
            label: 'Ratio Deuda/Ing',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'capacidad_pago',
            label: 'Capacidad Pago',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'antiguedad_meses',
            label: 'Antigüedad (meses)',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'calculado_at',
            label: 'Calculado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'movimientos_mensuales',
      displayName: 'Mov. Mensuales',
      icon: Icons.trending_up,
      category: 'Perfiles',
      columns: [
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(fieldName: 'periodo', label: 'Periodo'),
        ColumnConfig(
            fieldName: 'total_creditos',
            label: 'Total Créditos',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'total_debitos',
            label: 'Total Débitos',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'saldo_promedio',
            label: 'Saldo Promedio',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'num_transacciones',
            label: 'N° Transacc.',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'num_pagos_puntual',
            label: 'Pagos Puntuales',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'num_pagos_tardio',
            label: 'Pagos Tardíos',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),

    // ─── COBRANZA ───────────────────────────────────────
    TableConfig(
      tableName: 'consultas_buro',
      displayName: 'Consultas Buró',
      icon: Icons.search,
      category: 'Cobranza',
      columns: [
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'dni_consultado', label: 'DNI Consult.'),
        ColumnConfig(
            fieldName: 'calificacion_sbs', label: 'Calif. SBS'),
        ColumnConfig(
            fieldName: 'entidades_con_deuda',
            label: 'Entidades Deuda',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'deuda_total_pen',
            label: 'Deuda Total S/',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'mayor_deuda',
            label: 'Mayor Deuda',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'dias_mayor_mora',
            label: 'Días Mayor Mora',
            type: ColumnType.integer),
        ColumnConfig(
            fieldName: 'en_lista_negra',
            label: 'Lista Negra',
            type: ColumnType.boolean),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'acciones_cobranza',
      displayName: 'Acciones Cobranza',
      icon: Icons.gavel,
      category: 'Cobranza',
      columns: [
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'credito_id',
            label: 'Crédito ID',
            type: ColumnType.uuid,
            foreignTable: 'creditos',
            foreignLabel: 'id'),
        ColumnConfig(
            fieldName: 'tipo_gestion',
            label: 'Tipo Gestión',
            type: ColumnType.stringEnum,
            enumValues: ['Visita', 'Llamada', 'Mensaje']),
        ColumnConfig(
            fieldName: 'resultado',
            label: 'Resultado',
            type: ColumnType.stringEnum,
            enumValues: [
              'Compromiso de pago',
              'Pago parcial',
              'Sin contacto',
              'Se niega a pagar',
              'Cliente ausente'
            ]),
        ColumnConfig(
            fieldName: 'monto_pagado',
            label: 'Monto Pagado',
            type: ColumnType.decimal),
        ColumnConfig(
            fieldName: 'fecha_compromiso',
            label: 'F. Compromiso',
            type: ColumnType.date),
        ColumnConfig(
            fieldName: 'monto_comprometido',
            label: 'Monto Comprom.',
            type: ColumnType.decimal),
        ColumnConfig(fieldName: 'observaciones', label: 'Observaciones'),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'alertas_cartera',
      displayName: 'Alertas Cartera',
      icon: Icons.notifications_active,
      category: 'Cobranza',
      columns: [
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'cliente_id',
            label: 'Cliente ID',
            type: ColumnType.uuid,
            foreignTable: 'clientes',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'credito_id',
            label: 'Crédito ID',
            type: ColumnType.uuid,
            foreignTable: 'creditos',
            foreignLabel: 'id'),
        ColumnConfig(
            fieldName: 'tipo_alerta',
            label: 'Tipo Alerta',
            type: ColumnType.stringEnum,
            enumValues: [
              'primer_dia_mora',
              'mora_30d',
              'mora_60d',
              'pago_parcial',
              'pago_total',
              'desertor'
            ]),
        ColumnConfig(fieldName: 'mensaje', label: 'Mensaje'),
        ColumnConfig(
            fieldName: 'leida',
            label: 'Leída',
            type: ColumnType.boolean),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
    TableConfig(
      tableName: 'solicitudes_notas_internas',
      displayName: 'Notas Internas',
      icon: Icons.note,
      category: 'Cobranza',
      columns: [
        ColumnConfig(
            fieldName: 'solicitud_id',
            label: 'Solicitud ID',
            type: ColumnType.uuid,
            foreignTable: 'solicitudes_credito',
            foreignLabel: 'numero_expediente'),
        ColumnConfig(
            fieldName: 'asesor_id',
            label: 'Asesor ID',
            type: ColumnType.uuid,
            foreignTable: 'asesores_negocio',
            foreignLabel: 'nombres'),
        ColumnConfig(
            fieldName: 'contenido',
            label: 'Contenido',
            type: ColumnType.textarea),
        ColumnConfig(
            fieldName: 'created_at',
            label: 'Creado',
            type: ColumnType.datetime,
            editable: false,
            showInTable: false),
      ],
    ),
  ];

  static final Map<String, List<TableConfig>> _byCategory = () {
    final map = <String, List<TableConfig>>{};
    for (final table in allTables) {
      map.putIfAbsent(table.category, () => []).add(table);
    }
    return map;
  }();

  static List<String> get categories => _byCategory.keys.toList();

  static List<TableConfig> getByCategory(String category) =>
      _byCategory[category] ?? [];

  static TableConfig? getByTableName(String name) {
    try {
      return allTables.firstWhere((t) => t.tableName == name);
    } catch (_) {
      return null;
    }
  }
}
