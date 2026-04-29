import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latLng;

  PlaceModel({
    required this.id,
    required this.name,
    required this.latLng
  });
}

List<PlaceModel> places = [
  PlaceModel(id: 1, name: 'مسجد التقوى', latLng: LatLng(30.76283961468181, 31.3174322029239),),
  PlaceModel(id: 2, name: 'مطعم السفير', latLng: LatLng(30.765522645442122, 31.32615786379276),),
  PlaceModel(id: 3, name: 'مخبز الهدي', latLng: LatLng(30.76785258476167, 31.320444212214365),),
];