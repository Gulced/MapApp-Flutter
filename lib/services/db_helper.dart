// lib/services/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/map_point.dart';
import '../models/map_area.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'app.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            isAdmin INTEGER DEFAULT 0
          )
        ''');
        await db.insert('users', {
          'email': 'admin@admin.com',
          'password': 'admin',
          'isAdmin': 1,
        });
        await db.execute('''
          CREATE TABLE points(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ownerId INTEGER,
            latitude REAL,
            longitude REAL,
            description TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE areas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ownerId INTEGER,
            name TEXT,
            coords TEXT
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          final cols = await db.rawQuery("PRAGMA table_info('users')");
          final exists = cols.any((c) => c['name'] == 'isAdmin');
          if (!exists) {
            await db.execute(
              'ALTER TABLE users ADD COLUMN isAdmin INTEGER DEFAULT 0',
            );
          }
        }
      },
    );
    return _db!;
  }

  Future<int> createUser(User u) async {
    final db = await database;
    return db.insert('users', u.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }

  Future<int> insertPoint(MapPoint p) async {
    final db = await database;
    return db.insert('points', p.toMap());
  }

  Future<List<MapPoint>> fetchPointsByUser(int uid, {bool admin = false}) async {
    final db = await database;
    final rows = await db.query(
      'points',
      where: admin ? null : 'ownerId = ?',
      whereArgs: admin ? null : [uid],
    );
    return rows.map((m) => MapPoint.fromMap(m)).toList();
  }

  Future<int> updatePoint(MapPoint p) async {
    final db = await database;
    return db.update('points', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deletePoint(int id) async {
    final db = await database;
    return db.delete('points', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertArea(MapArea a) async {
    final db = await database;
    return db.insert('areas', a.toMap());
  }

  Future<List<MapArea>> fetchAreasByUser(int uid, {bool admin = false}) async {
    final db = await database;
    final rows = await db.query(
      'areas',
      where: admin ? null : 'ownerId = ?',
      whereArgs: admin ? null : [uid],
    );
    return rows.map((m) => MapArea.fromMap(m)).toList();
  }

  Future<int> updateArea(MapArea a) async {
    final db = await database;
    return db.update('areas', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> deleteArea(int id) async {
    final db = await database;
    return db.delete('areas', where: 'id = ?', whereArgs: [id]);
  }
}
