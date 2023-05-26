import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Custom in-app Google Maps widget.
class GmapsWidget extends StatefulWidget {
  final LatLng center;
  final Set<Polyline>? polylines;

  final double? bearing;
  final bool? enableLocationButton;
  final LatLng? marker;

  const GmapsWidget({
    Key? key,
    this.polylines,
    this.bearing,
    required this.center,
    this.marker,
    this.enableLocationButton,
  }) : super(key: key);

  @override
  State<GmapsWidget> createState() => _GmapsWidgetState();
}

class _GmapsWidgetState extends State<GmapsWidget> {
  /// Stores map controller variables.
  late GoogleMapController mapController;
  BitmapDescriptor? markerIcon;

  @override
  void initState() {
    super.initState();
    addCustomIcon();
  }

  /// Add custom icon as map marker.
  void addCustomIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/arrow_1.png',
    );

    setState(() {
      markerIcon = icon;
    });
  }

  /// Sets the mapcontroller when the map is initialised.
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("gmaps location: ${widget.center}");
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
