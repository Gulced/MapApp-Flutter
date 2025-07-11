import 'package:flutter/material.dart';
import '../models/map_point.dart';
import '../services/db_helper.dart';
import 'auth_viewmodel.dart';

enum PointsStatus { initial, loading, loaded, error }

class MapPointsViewModel extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final AuthViewModel _auth;
  PointsStatus _status = PointsStatus.initial;
  List<MapPoint> _points = [];
  String? _error;

  MapPointsViewModel(this._auth);

  PointsStatus get status => _status;
  List<MapPoint> get points => _points;
  String? get error => _error;

  Future<void> loadPoints() async {
    if (_auth.user == null) return;
    _status = PointsStatus.loading;
    notifyListeners();
    try {
      final isAdmin = _auth.user!.isAdmin;
      final uid = _auth.user!.id!;
      _points = await _db.fetchPointsByUser(uid, admin: isAdmin);
      _status = PointsStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = PointsStatus.error;
    }
    notifyListeners();
  }

  Future<void> insertPoint(MapPoint p) async {
    await _db.insertPoint(p);
    await loadPoints();
  }

  Future<void> updatePoint(MapPoint p) async {
    await _db.updatePoint(p);
    await loadPoints();
  }

  Future<void> deletePoint(int id) async {
    await _db.deletePoint(id);
    await loadPoints();
  }
}
