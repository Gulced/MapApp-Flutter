// lib/viewmodels/map_points_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/map_point.dart';
import '../services/db_helper.dart';
import 'auth_viewmodel.dart';

enum PointsStatus { initial, loading, loaded, error }

class MapPointsViewModel extends ChangeNotifier {
  final DBHelper _db;
  final AuthViewModel _auth;

  PointsStatus _status = PointsStatus.initial;
  List<MapPoint> _points = [];
  String? _error;

  MapPointsViewModel(this._db, this._auth);

  PointsStatus get status => _status;
  List<MapPoint> get points => _points;
  String? get error => _error;

  /// Kullanıcı login değilse hiçbir şey yapma
  Future<void> loadPoints() async {
    final user = _auth.user;
    if (user == null) return;

    _status = PointsStatus.loading;
    notifyListeners();

    try {
      final isAdmin = user.isAdmin;
      final uid     = user.id;
      _points = await _db.fetchPointsByUser(uid, admin: isAdmin);
      _status = PointsStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = PointsStatus.error;
    }

    notifyListeners();
  }

  /// Yeni nokta ekle ve listeye ekle
  Future<void> insertPoint(MapPoint p) async {
    _status = PointsStatus.loading;
    notifyListeners();

    try {
      final newId = await _db.insertPoint(p);
      _points.add(p.copyWith(id: newId));
      _status = PointsStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = PointsStatus.error;
    }

    notifyListeners();
  }

  /// Varolan noktayı güncelle ve listede değiştir
  Future<void> updatePoint(MapPoint p) async {
    _status = PointsStatus.loading;
    notifyListeners();

    try {
      await _db.updatePoint(p);
      final idx = _points.indexWhere((pt) => pt.id == p.id);
      if (idx != -1) _points[idx] = p;
      _status = PointsStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = PointsStatus.error;
    }

    notifyListeners();
  }

  /// Noktayı sil ve listeden çıkar
  Future<void> deletePoint(int id) async {
    _status = PointsStatus.loading;
    notifyListeners();

    try {
      await _db.deletePoint(id);
      _points.removeWhere((pt) => pt.id == id);
      _status = PointsStatus.loaded;
    } catch (e) {
      _error  = e.toString();
      _status = PointsStatus.error;
    }

    notifyListeners();
  }
}
