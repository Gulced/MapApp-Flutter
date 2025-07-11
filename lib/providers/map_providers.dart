import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../viewmodels/map_points_viewmodel.dart';
import '../viewmodels/map_areas_viewmodel.dart';

final mapPointsViewModelProvider = ChangeNotifierProvider((ref){
  final a = ref.read(authViewModelProvider);
  return MapPointsViewModel(a);
});
final mapAreasViewModelProvider = ChangeNotifierProvider((ref){
  final a = ref.read(authViewModelProvider);
  return MapAreasViewModel(a);
});
