// lib/ui/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/map_point.dart';
import '../models/map_area.dart';
import '../providers/auth_provider.dart';
import '../providers/map_providers.dart';
import '../viewmodels/map_points_viewmodel.dart';
import '../viewmodels/map_areas_viewmodel.dart';

/// Harita ekranında hangi modda olduğumuzu tutar
enum Mode { view, addPoint, addArea }

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Mode _mode = Mode.view;
  List<LatLng> _currentAreaCoords = [];

  static const _initialCamera = CameraPosition(
    target: LatLng(39.92, 32.85), // Ankara
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapPointsViewModelProvider).loadPoints();
      ref.read(mapAreasViewModelProvider).loadAreas();
    });
  }

  void _onMapTap(LatLng loc) {
    if (_mode == Mode.addPoint) {
      final auth = ref.read(authViewModelProvider).user!;
      ref.read(mapPointsViewModelProvider).insertPoint(
        MapPoint(ownerId: auth.id!, position: loc, description: 'Yeni Nokta'),
      );
      setState(() => _mode = Mode.view);
    } else if (_mode == Mode.addArea) {
      setState(() => _currentAreaCoords.add(loc));
    }
  }

  void _saveArea() {
    final auth = ref.read(authViewModelProvider).user!;
    ref.read(mapAreasViewModelProvider).insertArea(
      MapArea(ownerId: auth.id!, name: 'Yeni Alan', coords: _currentAreaCoords),
    );
    setState(() {
      _currentAreaCoords = [];
      _mode = Mode.view;
    });
  }

  void _cancelArea() {
    setState(() {
      _currentAreaCoords = [];
      _mode = Mode.view;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = ref.watch(authViewModelProvider);
    final pointsVm = ref.watch(mapPointsViewModelProvider);
    final areasVm = ref.watch(mapAreasViewModelProvider);
    final isAdmin = authVm.user?.isAdmin ?? false;
    final userId = authVm.user?.id;

    // Marker seti
    final markers = <Marker>{};
    if (pointsVm.status == PointsStatus.loaded) {
      for (var p in pointsVm.points) {
        if (!isAdmin && p.ownerId != userId) continue;
        markers.add(Marker(
          markerId: MarkerId('pt_${p.id}'),
          position: p.position,
          infoWindow: InfoWindow(
            title: p.description,
            onTap: () => _showPointMenu(p),
          ),
        ));
      }
    }

    // Polygon seti
    final polygons = <Polygon>{};
    if (areasVm.status == AreasStatus.loaded) {
      for (var a in areasVm.areas) {
        if (!isAdmin && a.ownerId != userId) continue;
        polygons.add(Polygon(
          polygonId: PolygonId('ar_${a.id}'),
          points: a.coords,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.2),
          consumeTapEvents: true,
          onTap: () => _showAreaMenu(a),
        ));
      }
    }

    // Geçici alan çizimi
    if (_mode == Mode.addArea && _currentAreaCoords.length > 1) {
      polygons.add(Polygon(
        polygonId: PolygonId('tmp_area'),
        points: _currentAreaCoords,
        strokeWidth: 2,
        fillColor: Colors.green.withOpacity(0.3),
      ));
    }

    final loading = pointsVm.status == PointsStatus.loading ||
        areasVm.status == AreasStatus.loading;

    return Scaffold(
      appBar: AppBar(title: Text('Ana Sayfa')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: markers,
            polygons: polygons,
            onMapCreated: (ctrl) {
              print('>>> Map created!');
              _controller.complete(ctrl);
            },
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (_mode == Mode.addArea)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _saveArea, child: Text('Kaydet')),
                  OutlinedButton(onPressed: _cancelArea, child: Text('İptal')),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFab(isAdmin),
    );
  }

  Widget _buildFab(bool isAdmin) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_mode == Mode.view) ...[
          FloatingActionButton(
            heroTag: 'addPoint',
            child: Icon(Icons.location_on),
            onPressed: () => setState(() => _mode = Mode.addPoint),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'addArea',
            child: Icon(Icons.crop_square),
            onPressed: () => setState(() => _mode = Mode.addArea),
          ),
        ] else
          FloatingActionButton(
            heroTag: 'cancelMode',
            child: Icon(Icons.close),
            onPressed: () => setState(() {
              _mode = Mode.view;
              _currentAreaCoords = [];
            }),
          ),
      ],
    );
  }

  void _showPointMenu(MapPoint p) {
    final isOwner = p.ownerId == ref.read(authViewModelProvider).user!.id;
    final isAdmin = ref.read(authViewModelProvider).user!.isAdmin;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                // Düzenleme işlemini buraya ekleyebilirsiniz
              },
            ),
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                ref.read(mapPointsViewModelProvider).deletePoint(p.id!);
              },
            ),
        ]),
      ),
    );
  }

  void _showAreaMenu(MapArea a) {
    final isOwner = a.ownerId == ref.read(authViewModelProvider).user!.id;
    final isAdmin = ref.read(authViewModelProvider).user!.isAdmin;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                // Düzenleme işlemini buraya ekleyebilirsiniz
              },
            ),
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                ref.read(mapAreasViewModelProvider).deleteArea(a.id!);
              },
            ),
        ]),
      ),
    );
  }
}
