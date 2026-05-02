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
      targetWidth: width.round(),
    );
    var imageFrame = await imageCodec.getNextFrame();
    var imageByteData = await imageFrame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return imageByteData!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> getColoredMarker(Color color) async {
    final ByteData data = await rootBundle.load(
      'assets/images/marker_image.png',
    );
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn);

    canvas.drawImage(image, Offset.zero, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List(), width: 30);
  }

  void initMarkers() async {
    // var markerAssetImage = BitmapDescriptor.bytes(
    //   await getImageFromRawData('assets/images/marker_image.png', 30),
    // );
    var customIcon = await getColoredMarker(Colors.red);
    //  BitmapDescriptor.asset(
    //   width: 30,
    //   ImageConfiguration.empty,
    //   'assets/images/marker_image.png',
    // );
    var myMarkers = places
        .map(
          (place) => Marker(
            icon: customIcon,
            infoWindow: InfoWindow(title: place.name , snippet: place.name),
            position: place.latLng,
            markerId: MarkerId(place.id.toString()),
          ),
        )
        .toSet();
    markers.addAll(myMarkers);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: initialCameraPosition,
          style: _mapStyle,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          markers: markers,
        ),
        // Positioned(
        //   left: 16,
        //   right: 16,
        //   bottom: 16,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       googleMapController.animateCamera(
        //         CameraUpdate.newCameraPosition(
        //           CameraPosition(
        //             zoom: 18,
        //             target: LatLng(30.768090681310408, 31.32845033933248),
        //           ),
        //         ),
        //       );
        //     },
        //     child: Text('Change Location'),
        //   ),
        // ),
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
