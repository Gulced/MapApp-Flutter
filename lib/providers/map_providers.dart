// lib/providers/map_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/db_helper.dart';
import 'auth_provider.dart';
import '../viewmodels/map_points_viewmodel.dart';
import '../viewmodels/map_areas_viewmodel.dart';

/// Nokta ViewModel’ını sağlayan provider
final mapPointsViewModelProvider =
ChangeNotifierProvider<MapPointsViewModel>((ref) {
  // AuthViewModel’ı izleyerek kullanıcı/rol değişikliklerine tepki verecek
  final authVm = ref.watch(authViewModelProvider);
  // DBHelper singleton’ı
  final db = DBHelper();
  return MapPointsViewModel(db, authVm);
});

/// Alan ViewModel’ını sağlayan provider
final mapAreasViewModelProvider =
ChangeNotifierProvider<MapAreasViewModel>((ref) {
  final authVm = ref.watch(authViewModelProvider);
  final db = DBHelper();
  return MapAreasViewModel(db, authVm);
});
