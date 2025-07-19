import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapArea {
  final int? id;
  final int ownerId;
  final String name;
  final String description;
  final List<LatLng> coords;

  MapArea({
    this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.coords,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'description': description,
    // coords dışarıda JSON olarak ekleniyor
  };

  factory MapArea.fromMap(Map<String, Object?> m, List<LatLng> coords) => MapArea(
    id: m['id'] as int,
    ownerId: m['ownerId'] as int,
    name: m['name'] as String,
    description: m['description'] as String,
    coords: coords,
  );

  MapArea copyWith({int? id, String? name, String? description, List<LatLng>? coords}) {
    return MapArea(
      id: id ?? this.id,
      ownerId: ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      coords: coords ?? this.coords,
    );
  }
}
