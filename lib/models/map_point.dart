import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPoint {
  final int? id;
  final int ownerId;
  final LatLng position;
  final String title;
  final String description;

  MapPoint({
    this.id,
    required this.ownerId,
    required this.position,
    required this.title,
    required this.description,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'title': title,
    'description': description,
  };

  factory MapPoint.fromMap(Map<String, Object?> m) => MapPoint(
    id: m['id'] as int,
    ownerId: m['ownerId'] as int,
    position: LatLng(m['latitude'] as double, m['longitude'] as double),
    title: m['title'] as String,
    description: m['description'] as String,
  );

  MapPoint copyWith({int? id, String? title, String? description}) {
    return MapPoint(
      id: id ?? this.id,
      ownerId: ownerId,
      position: position,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
