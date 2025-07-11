import 'package:flutter/material.dart';
import '../models/map_area.dart';
import '../services/db_helper.dart';
import 'auth_viewmodel.dart';

enum AreasStatus { initial, loading, loaded, error }

class MapAreasViewModel extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final AuthViewModel _auth;
  AreasStatus _status = AreasStatus.initial;
  List<MapArea> _areas = [];
  String? _error;

  MapAreasViewModel(this._auth);

  AreasStatus get status => _status;
  List<MapArea> get areas => _areas;
  String? get error => _error;

  Future<void> loadAreas() async {
    if (_auth.user == null) return;
    _status = AreasStatus.loading;
    notifyListeners();
    try {
      final isAdmin = _auth.user!.isAdmin;
      final uid = _auth.user!.id!;
      _areas = await _db.fetchAreasByUser(uid, admin: isAdmin);
      _status = AreasStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = AreasStatus.error;
    }
    notifyListeners();
  }

  Future<void> insertArea(MapArea a) async {
    await _db.insertArea(a);
    await loadAreas();
  }

  Future<void> updateArea(MapArea a) async {
    await _db.updateArea(a);
    await loadAreas();
  }

  Future<void> deleteArea(int id) async {
    await _db.deleteArea(id);
    await loadAreas();
  }
}
