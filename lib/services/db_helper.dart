// lib/services/db_helper.dart

import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 4,               // <-- Yeni sürüm numarası
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        isAdmin INTEGER DEFAULT 0
      )
    ''');

    // Örnek admin hesabı ekleyelim
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
        title TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE areas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ownerId INTEGER,
        name TEXT,
        description TEXT,
        coords TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // users tablosuna isAdmin ekle (version 1→2)
    if (oldV < 2) {
      final cols = await db.rawQuery("PRAGMA table_info('users')");
      if (!cols.any((c) => c['name'] == 'isAdmin')) {
        await db.execute('ALTER TABLE users ADD COLUMN isAdmin INTEGER DEFAULT 0');
      }
    }

    // points ve areas tablolarına title/description ekle (version 2→4)
    if (oldV < 4) {
      // points tablosu
      final pointCols = await db.rawQuery("PRAGMA table_info('points')");
      if (!pointCols.any((c) => c['name'] == 'title')) {
        await db.execute('ALTER TABLE points ADD COLUMN title TEXT');
      }
      if (!pointCols.any((c) => c['name'] == 'description')) {
        await db.execute('ALTER TABLE points ADD COLUMN description TEXT');
      }

      // areas tablosu
      final areaCols = await db.rawQuery("PRAGMA table_info('areas')");
      if (!areaCols.any((c) => c['name'] == 'description')) {
        await db.execute('ALTER TABLE areas ADD COLUMN description TEXT');
      }
      // coords zaten onCreate'da var; gerekirse benzer kontrol eklenebilir
    }
  }

  // --- User işlemleri ---
  Future<int> createUser(User u) async {
    final db = await database;
    return db.insert('users', u.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  // --- Nokta işlemleri ---
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

  // --- Alan işlemleri ---
  Future<int> insertArea(MapArea a) async {
    final db = await database;
    final m = a.toMap();
    m['coords'] = jsonEncode(
      a.coords.map((c) => {'lat': c.latitude, 'lng': c.longitude}).toList(),
    );
    return db.insert('areas', m);
  }

  Future<List<MapArea>> fetchAreasByUser(int uid, {bool admin = false}) async {
    final db = await database;
    final rows = await db.query(
      'areas',
      where: admin ? null : 'ownerId = ?',
      whereArgs: admin ? null : [uid],
    );
    return rows.map((m) {
      final raw = jsonDecode(m['coords'] as String) as List<dynamic>;
      final coords = raw
          .map((e) => LatLng((e['lat'] as num).toDouble(), (e['lng'] as num).toDouble()))
          .toList();
      return MapArea.fromMap(m, coords);
    }).toList();
  }

  Future<int> updateArea(MapArea a) async {
    final db = await database;
    final m = a.toMap();
    m['coords'] = jsonEncode(
      a.coords.map((c) => {'lat': c.latitude, 'lng': c.longitude}).toList(),
    );
    return db.update('areas', m, where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> deleteArea(int id) async {
    final db = await database;
    return db.delete('areas', where: 'id = ?', whereArgs: [id]);
  }
}
