import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  GoogleMapController? googleMapController;
  late Location location;
  late LocationService locationService;
  @override
  void initState() {
    super.initState();
    initMapStyle();
    initialCameraPosition = CameraPosition(
      target: LatLng(30.762578494071878, 31.31647130125389),
      zoom: 12,
    );
    location = Location();
    locationService = LocationService();
    updateMyLocation();
  }

  String? _mapStyle;

  Future<void> initMapStyle() async {
    final style = await rootBundle.loadString(
      'assets/map_styles/night_style.json',
    );
    setState(() {
      _mapStyle = style;
    });
  }

  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: markers,
          zoomControlsEnabled: false,
          initialCameraPosition: initialCameraPosition,
          style: _mapStyle,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          // markers: markers,
        ),
      ],
    );
  }

  // void getLocationData() {
  //   location.changeSettings(distanceFilter: 2);

  //   location.onLocationChanged.listen((locationData) {
  //     var cameraPosition = CameraPosition(
  //       zoom: 15,
  //       target: LatLng(locationData.latitude!, locationData.longitude!),
  //     );
  //     var myLocationMarker = Marker(
  //       markerId: MarkerId('my_location_marker'),
  //       position: LatLng(locationData.latitude!, locationData.longitude!),
  //     );
  //     markers.add(myLocationMarker);
  //     setState(() {});
  //     googleMapController?.animateCamera(
  //       CameraUpdate.newCameraPosition(cameraPosition),
  //     );
  //   });
  // }

  void updateMyLocation() async {
    await locationService.checkAndRequestLocationService();
    bool hasPermission = await locationService
        .checkAndRequestLocationPermission();
    if (hasPermission) {
      location.changeSettings(distanceFilter: 2);
      locationService.getRealTimeLocationData((locationData) {
        location.onLocationChanged.listen((locationData) {
          setMyLocationMarker(locationData);
          setMyCameraPosition(locationData);
        });
      });
    } else {}
  }

  void setMyCameraPosition(LocationData locationData) {
    var cameraPosition = CameraPosition(
      zoom: 15,
      target: LatLng(locationData.latitude!, locationData.longitude!),
    );
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  void setMyLocationMarker(LocationData locationData) {
    var myLocationMarker = Marker(
      markerId: MarkerId('my_location_marker'),
      position: LatLng(locationData.latitude!, locationData.longitude!),
    );
    markers.add(myLocationMarker);
    setState(() {});
  }
}

// Zoom levels
// world view ==> 0 - 3
// country view ==> 4 - 6
// city view ==> 10 - 12
// street view ==> 13 - 17
// building view ==> 18 - 20


/// Steps to get user location
  // inquire about location service
  // request permission
  // get user location
  // display location 