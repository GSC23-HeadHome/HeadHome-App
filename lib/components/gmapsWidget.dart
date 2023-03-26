import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GmapsWidget extends StatefulWidget {
  final LatLng center;
  final Set<String>? polylineStrs;
  final double? bearing;

  const GmapsWidget(
      {Key? key, this.polylineStrs, this.bearing, required this.center})
      : super(key: key);

  @override
  State<GmapsWidget> createState() => _GmapsWidgetState();
}

class _GmapsWidgetState extends State<GmapsWidget> {
  late GoogleMapController mapController;
  //BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor? markerIcon;

  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    toPolyline();
  }

  Future<void> toPolyline() async {
    if (widget.polylineStrs!.isNotEmpty) {
      for (int i = 0; i < widget.polylineStrs!.length; i++) {
        //Convert polyline string to lat lng
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> polylinePointsList =
            polylinePoints.decodePolyline(widget.polylineStrs!.elementAt(i));
        List<LatLng> latLngList = <LatLng>[];
        for (PointLatLng point in polylinePointsList) {
          latLngList.add(LatLng(point.latitude, point.longitude));
        }

        //Create polyline object
        Polyline polyline = Polyline(
          polylineId: const PolylineId("polyline"),
          points: latLngList,
          color: Colors.blue,
          width: 5,
        );
        polylines.add(polyline);
      }
    }
  }

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
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.center,
        zoom: 15.0,
      ),
      polylines: polylines,
      markers: markerIcon == null
          ? {}
          : {
              Marker(
                markerId: const MarkerId('current_location'),
                position: widget.center,
                infoWindow: const InfoWindow(title: 'Current Location'),
                icon: markerIcon!,
                rotation: widget.bearing ?? 0.0,
              )
            },
    );
  }
}
