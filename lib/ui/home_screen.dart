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

enum Mode { view, addPoint, addArea }

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Mode _mode = Mode.view;

  MapArea? _editingArea;
  List<LatLng> _currentAreaCoords = [];

  static const _initialCamera = CameraPosition(
    target: LatLng(39.92, 32.85),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(mapPointsViewModelProvider).loadPoints();
      await ref.read(mapAreasViewModelProvider).loadAreas();
    });
  }

  Future<MapPoint?> _askForPointInfo(LatLng pos, {MapPoint? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title);
    final descCtrl = TextEditingController(text: existing?.description);
    return showDialog<MapPoint>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Yeni Nokta Ekle' : 'Noktayı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: 'Başlık')),
            TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: 'Açıklama')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isEmpty) return;
              final user = ref.read(authViewModelProvider).user!;
              Navigator.pop(
                  ctx,
                  MapPoint(
                    id: existing?.id,
                    ownerId: user.id!,
                    position: pos,
                    title: t,
                    description: descCtrl.text.trim(),
                  ));
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<MapArea?> _askForAreaInfo(List<LatLng> coords,
      {MapArea? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final descCtrl = TextEditingController(text: existing?.description);
    return showDialog<MapArea>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Yeni Alan Ekle' : 'Alanı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Alan Adı')),
            TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: 'Açıklama')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              if (n.isEmpty) return;
              final user = ref.read(authViewModelProvider).user!;
              Navigator.pop(
                  ctx,
                  MapArea(
                    id: existing?.id,
                    ownerId: user.id!,
                    name: n,
                    description: descCtrl.text.trim(),
                    coords: coords,
                  ));
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapTap(LatLng loc) async {
    final pointsVm = ref.read(mapPointsViewModelProvider);
    if (_mode == Mode.addPoint) {
      final newPoint = await _askForPointInfo(loc);
      if (newPoint != null) await pointsVm.insertPoint(newPoint);
      setState(() => _mode = Mode.view);
    } else if (_mode == Mode.addArea) {
      setState(() => _currentAreaCoords.add(loc));
    }
  }

  Future<void> _saveArea() async {
    final areasVm = ref.read(mapAreasViewModelProvider);
    final result =
    await _askForAreaInfo(_currentAreaCoords, existing: _editingArea);
    if (result != null) {
      if (_editingArea != null) {
        await areasVm.updateArea(result);
      } else {
        await areasVm.insertArea(result);
      }
    }
    setState(() {
      _currentAreaCoords = [];
      _editingArea = null;
      _mode = Mode.view;
    });
  }

  void _cancelArea() {
    setState(() {
      _currentAreaCoords = [];
      _editingArea = null;
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

    // Nokta Marker’ları
    final markers = <Marker>{};
    if (pointsVm.status == PointsStatus.loaded) {
      for (var p in pointsVm.points) {
        if (!isAdmin && p.ownerId != userId) continue;
        markers.add(Marker(
          markerId: MarkerId('pt_${p.id}'),
          position: p.position,
          draggable: true,
          onDragEnd: (newPos) async {
            final upd = MapPoint(
              id: p.id,
              ownerId: p.ownerId,
              position: newPos,
              title: p.title,
              description: p.description,
            );
            await ref.read(mapPointsViewModelProvider).updatePoint(upd);
          },
          infoWindow: InfoWindow(
            title: p.title,
            snippet: p.description,
            onTap: () => _showPointMenu(p),
          ),
          consumeTapEvents: true,
          onTap: () => _showPointMenu(p),
        ));
      }
    }

    // Alan Polygon’ları
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

    // Geçici Alan (ekleme/düzenleme) çizimi
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
      appBar: AppBar(title: Text('Map Page')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: markers,
            polygons: polygons,
            onMapCreated: (ctrl) => _controller.complete(ctrl),
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
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Column(
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
                  onPressed: () => setState(() {
                    _editingArea = null;
                    _currentAreaCoords = [];
                    _mode = Mode.addArea;
                  }),
                ),
              ] else
                FloatingActionButton(
                  heroTag: 'cancelMode',
                  child: Icon(Icons.close),
                  onPressed: () => setState(() {
                    _mode = Mode.view;
                    _editingArea = null;
                    _currentAreaCoords = [];
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPointMenu(MapPoint p) {
    final isOwner =
        p.ownerId == ref.read(authViewModelProvider).user!.id;
    final isAdmin = ref.read(authViewModelProvider).user!.isAdmin;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Düzenle'),
              onTap: () async {
                Navigator.pop(context);
                final edited =
                await _askForPointInfo(p.position, existing: p);
                if (edited != null) {
                  await ref
                      .read(mapPointsViewModelProvider)
                      .updatePoint(edited);
                }
              },
            ),
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(mapPointsViewModelProvider)
                    .deletePoint(p.id!);
              },
            ),
        ]),
      ),
    );
  }

  void _showAreaMenu(MapArea a) {
    final isOwner =
        a.ownerId == ref.read(authViewModelProvider).user!.id;
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
                setState(() {
                  _editingArea = a;
                  _currentAreaCoords = List.from(a.coords);
                  _mode = Mode.addArea;
                });
              },
            ),
          if (isOwner || isAdmin)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(mapAreasViewModelProvider)
                    .deleteArea(a.id!);
              },
            ),
        ]),
      ),
    );
  }
}
