import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDbProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

class LocalDatabase {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bbva_fuerza_ventas.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE solicitudes_borrador (
            id TEXT PRIMARY KEY,
            cliente_id TEXT,
            cliente_nombre TEXT,
            paso_actual INTEGER DEFAULT 1,
            datos_json TEXT,
            monto_solicitado REAL DEFAULT 0,
            asesor_id TEXT,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE visitas_pendientes (
            id TEXT PRIMARY KEY,
            cartera_id TEXT,
            resultado TEXT,
            observacion TEXT,
            timestamp_visita TEXT,
            lat REAL,
            lng REAL,
            pendiente_sync INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE cartera_cache (
            id TEXT PRIMARY KEY,
            datos_json TEXT,
            fecha TEXT,
            updated_at INTEGER
          )
        ''');
      },
    );
  }

  Future<void> guardarBorrador(Map<String, dynamic> data) async {
    final db = await database;
    final row = {
      'id': data['id'],
      'cliente_id': data['cliente_id'],
      'cliente_nombre': data['cliente_nombre'],
      'paso_actual': data['paso_actual'] ?? 1,
      'datos_json': jsonEncode(data),
      'monto_solicitado': data['monto_solicitado'] ?? 0,
      'asesor_id': data['asesor_id'],
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    await db.insert('solicitudes_borrador', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> obtenerBorrador(String id) async {
    final db = await database;
    final rows = await db.query('solicitudes_borrador',
        where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final json = row['datos_json'] as String?;
    if (json != null) return jsonDecode(json) as Map<String, dynamic>;
    return row;
  }

  Future<List<Map<String, dynamic>>> obtenerBorradores(String asesorId, {bool pendientesSync = false}) async {
    final db = await database;
    final rows = pendientesSync
        ? await db.query('solicitudes_borrador', where: 'pendiente_sync = 1')
        : await db.query('solicitudes_borrador',
            where: 'asesor_id = ?', whereArgs: [asesorId],
            orderBy: 'updated_at DESC');
    return rows.map((r) {
      final json = r['datos_json'] as String?;
      if (json != null) return jsonDecode(json) as Map<String, dynamic>;
      return r;
    }).toList();
  }

  Future<void> eliminarBorrador(String id) async {
    final db = await database;
    await db.delete('solicitudes_borrador', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> guardarVisitaPendiente(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('visitas_pendientes', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> obtenerVisitasPendientes() async {
    final db = await database;
    return db.query('visitas_pendientes',
        where: 'pendiente_sync = 1');
  }

  Future<void> marcarSincronizada(String id) async {
    final db = await database;
    await db.update('visitas_pendientes', {'pendiente_sync': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cacheCartera(List<Map<String, dynamic>> visitas) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final batch = db.batch();
    batch.delete('cartera_cache', where: 'fecha = ?', whereArgs: [today]);
    for (final v in visitas) {
      batch.insert('cartera_cache', {
        'id': v['id'],
        'datos_json': jsonEncode(v),
        'fecha': today,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> obtenerCarteraCache() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return db.query('cartera_cache',
        where: 'fecha = ?', whereArgs: [today]);
  }

  Future<void> limpiarTodo() async {
    final db = await database;
    await db.delete('solicitudes_borrador');
    await db.delete('visitas_pendientes');
    await db.delete('cartera_cache');
  }
}
