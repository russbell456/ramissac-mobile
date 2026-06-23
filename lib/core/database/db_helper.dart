import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/rq_urgente/models/rq_local_model.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sistema_ocs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE requerimientos(id INTEGER PRIMARY KEY AUTOINCREMENT, servicio TEXT, productos TEXT, fecha TEXT, enviado INTEGER)"
        );
      },
    );
  }

  static Future<int> insertarRQ(RQLocal rq) async {
    final db = await database;
    return await db.insert('requerimientos', rq.toMap());
  }

  static Future<int> actualizarRQ(RQLocal rq) async {
    final db = await database;
    return await db.update('requerimientos', rq.toMap(), where: 'id = ?', whereArgs: [rq.id]);
  }

  static Future<List<RQLocal>> obtenerRQs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('requerimientos', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => RQLocal.fromMap(maps[i]));
  }

  static Future<void> eliminarRQ(int id) async {
    final db = await database;
    await db.delete('requerimientos', where: 'id = ?', whereArgs: [id]);
  }
}