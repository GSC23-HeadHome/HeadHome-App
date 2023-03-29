import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmapsWidget extends StatefulWidget {
  final LatLng center;
  final Set<Polyline>? polylines;
  // final Set<String>? polylineStrs;
  final double? bearing;
  final bool? enableLocationButton;
  final LatLng? marker;

  const GmapsWidget(
      {Key? key,
      this.polylines,
      this.bearing,
      required this.center,
      this.marker,
      this.enableLocationButton})
      : super(key: key);

  @override
  State<GmapsWidget> createState() => _GmapsWidgetState();
}

class _GmapsWidgetState extends State<GmapsWidget> {
  late GoogleMapController mapController;
  BitmapDescriptor? markerIcon;

  // Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    // toPolyline();
  }

  @override
  void didUpdateWidget(GmapsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("gmaps widget rerendered");
  }

  // void toPolyline() {
  //   if (widget.polylineStrs!.isNotEmpty) {
  //     Set<Polyline> tempPolylines = {};
  //     for (int i = 0; i < widget.polylineStrs!.length; i++) {
  //       //Convert polyline string to lat lng
  //       PolylinePoints polylinePoints = PolylinePoints();
  //       List<PointLatLng> polylinePointsList =
  //           polylinePoints.decodePolyline(widget.polylineStrs!.elementAt(i));
  //       List<LatLng> latLngList = <LatLng>[];
  //       for (PointLatLng point in polylinePointsList) {
  //         latLngList.add(LatLng(point.latitude, point.longitude));
  //       }

  //       //Create polyline object
  //       Polyline polyline = Polyline(
  //         polylineId: const PolylineId("polyline"),
  //         points: latLngList,
  //         color: Colors.blue,
  //         width: 5,
  //       );

  //       tempPolylines.add(polyline);
  //     }
  //     debugPrint("Changing Polylines to $tempPolylines");
  //     setState(() {
  //       polylines = tempPolylines;
  //     });
  //   }
  // }

  // @override
  // void didUpdateWidget(covariant GmapsWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   toPolyline();
  // }

  void addCustomIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/arrow.png');
    setState(() {
      markerIcon = icon;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    print("gmaps location:");
    print(widget.center);
    return GoogleMap(
      myLocationEnabled: true,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.center,
        zoom: 15.0,
      ),
      polylines: widget.polylines ?? const <Polyline>{},
      markers: markerIcon == null || widget.marker == null
          ? {}
          : {
              Marker(
                markerId: const MarkerId('current_location'),
                position: widget.marker!,
                infoWindow: const InfoWindow(title: 'Current Location'),
                // icon: markerIcon!,
                rotation: widget.bearing ?? 0.0,
              )
            },
      myLocationButtonEnabled: widget.enableLocationButton == null
          ? false
          : widget.enableLocationButton!,
    );
  }
}
