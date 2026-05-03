import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  late CameraPosition initialCameraPosition;
  late Location location;
  @override
  void initState() {
    initialCameraPosition = CameraPosition(
      target: LatLng(30.762578494071878, 31.31647130125389),
      zoom: 12,
    );
    location = Location();
    updateMyLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(initialCameraPosition: initialCameraPosition),
    );
  }

  Future<void> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        //! TODO: show error bar
      }
    }
  }

  Future<bool> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void getLocationData() {
    location.onLocationChanged.listen((locationData) {});
  }

  void updateMyLocation() async {
    await checkAndRequestLocationService();
    bool hasPermission = await checkAndRequestLocationPermission();
    if (hasPermission) {
      getLocationData();
    } else {}
  }
}
