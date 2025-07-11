import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPoint {
  final int? id;
  final int ownerId;
  final LatLng position;
  final String description;
  MapPoint({this.id, required this.ownerId, required this.position, required this.description});
  Map<String,dynamic> toMap()=> {
    'id':id,'ownerId':ownerId,
    'latitude':position.latitude,'longitude':position.longitude,
    'description':description,
  };
  factory MapPoint.fromMap(Map<String,dynamic> m)=> MapPoint(
    id:m['id'],ownerId:m['ownerId'],
    position:LatLng(m['latitude'],m['longitude']),
    description:m['description'],
  );
}
