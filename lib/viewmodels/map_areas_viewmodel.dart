// lib/viewmodels/map_areas_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/map_area.dart';
import '../services/db_helper.dart';
import 'auth_viewmodel.dart';

enum AreasStatus { initial, loading, loaded, error }

class MapAreasViewModel extends ChangeNotifier {
  final DBHelper _db;
  final AuthViewModel _auth;

  AreasStatus _status = AreasStatus.initial;
  List<MapArea> _areas = [];
  String? _error;

  MapAreasViewModel(this._db, this._auth);

  AreasStatus get status => _status;
  List<MapArea> get areas => _areas;
  String? get error => _error;

  /// Kullanıcı login değilse hiçbir şey yapma
  Future<void> loadAreas() async {
    final user = _auth.user;
    if (user == null) return;

    _status = AreasStatus.loading;
    notifyListeners();

    try {
      final isAdmin = user.isAdmin;
      final uid     = user.id;
      _areas = await _db.fetchAreasByUser(uid, admin: isAdmin);
      _status = AreasStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = AreasStatus.error;
    }

    notifyListeners();
  }

  Future<void> insertArea(MapArea area) async {
    _status = AreasStatus.loading;
    notifyListeners();

    try {
      final newId = await _db.insertArea(area);
      // copyWith ile yeni id'yi ata
      _areas.add(area.copyWith(id: newId));
      _status = AreasStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = AreasStatus.error;
    }

    notifyListeners();
  }

  Future<void> updateArea(MapArea area) async {
    _status = AreasStatus.loading;
    notifyListeners();

    try {
      await _db.updateArea(area);
      final idx = _areas.indexWhere((a) => a.id == area.id);
      if (idx != -1) _areas[idx] = area;
      _status = AreasStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = AreasStatus.error;
    }

    notifyListeners();
  }

  Future<void> deleteArea(int id) async {
    _status = AreasStatus.loading;
    notifyListeners();

    try {
      await _db.deleteArea(id);
      _areas.removeWhere((a) => a.id == id);
      _status = AreasStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = AreasStatus.error;
    }

    notifyListeners();
  }
}
