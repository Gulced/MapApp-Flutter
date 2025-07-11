import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapArea {
  final int? id;
  final int ownerId;
  final String name;
  final List<LatLng> coords;
  MapArea({this.id, required this.ownerId, required this.name, required this.coords});
  Map<String,dynamic> toMap()=> {
    'id':id,'ownerId':ownerId,'name':name,
    'coords':jsonEncode(coords.map((c)=>{'lat':c.latitude,'lng':c.longitude}).toList()),
  };
  factory MapArea.fromMap(Map<String,dynamic> m){
    final raw = jsonDecode(m['coords']) as List;
    final pts = raw.map((e)=>LatLng(e['lat'],e['lng'])).toList();
    return MapArea(id:m['id'],ownerId:m['ownerId'],name:m['name'],coords:pts);
  }
}
