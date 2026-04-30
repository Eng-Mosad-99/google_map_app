import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/models/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController googleMapController;

  @override
  void initState() {
    super.initState();
    initMapStyle();
    initMarkers();
    initialCameraPosition = CameraPosition(
      target: LatLng(30.762578494071878, 31.31647130125389),
      zoom: 14,
    );
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

  Future<Uint8List> getImageFromRawData(String image, double width) async {
    var imageData = await rootBundle.load(image);
    var imageCodec = await ui.instantiateImageCodec(
      imageData.buffer.asUint8List(),
      targetWidth: width.toInt(),
    );
    var imageFrame = await imageCodec.getNextFrame();
    var imageByteData = await imageFrame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return imageByteData!.buffer.asUint8List();
  }

  void initMarkers() async {
    var markerAssetImage =  BitmapDescriptor.bytes(await getImageFromRawData('assets/images/marker_image.png', 30));
    //  BitmapDescriptor.asset(
    //   width: 30,
    //   ImageConfiguration.empty,
    //   'assets/images/marker_image.png',
    // );
    var myMarkers = places
        .map(
          (place) => Marker(
            icon: markerAssetImage,
            infoWindow: InfoWindow(title: place.name),
            position: place.latLng,
            markerId: MarkerId(place.id.toString()),
          ),
        )
        .toSet();
    markers.addAll(myMarkers);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          style: _mapStyle,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          markers: markers,
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: ElevatedButton(
            onPressed: () {
              googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    zoom: 18,
                    target: LatLng(30.768090681310408, 31.32845033933248),
                  ),
                ),
              );
            },
            child: Text('Change Location'),
          ),
        ),
      ],
    );
  }
}

// Zoom levels
// world view ==> 0 - 3
// country view ==> 4 - 6
// city view ==> 10 - 12
// street view ==> 13 - 17
// building view ==> 18 - 20
