import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

/// Google Maps Street View Widget.
class GmapsStView extends StatefulWidget {
  final double latitude;
  final double longitude;
  // final Set<String>? polylineStrs;
  final double? bearing;

  const GmapsStView({
    Key? key,
    this.bearing,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<GmapsStView> createState() => _GmapsStViewState();
}

class _GmapsStViewState extends State<GmapsStView> {
  BitmapDescriptor? markerIcon;

  void addCustomIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/arrow_1.png');

    setState(() {
      markerIcon = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    // toPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              FlutterGoogleStreetView(
                /**
                 * It not necessary but you can set init position
                 * choice one of initPos or initPanoId
                 * do not feed param to both of them, or you should get assert error
                 */
                initPos: LatLng(widget.latitude, widget.longitude),
                //initPanoId: "WddsUw1geEoAAAQIt9RnsQ",

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initSource is a filter setting to filter panorama
                 */
                initSource: StreetViewSource.outdoor,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initBearing can set default bearing of camera.
                 */
                //nitBearing: 30,
                initBearing: widget.bearing,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initTilt can set default tilt of camera.
                 */
                initTilt: 0,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initZoom can set default zoom of camera.
                 */
                initZoom: 1,

                /**
                 *  iOS Only
                 *  It is worked while you set initPos or initPanoId.
                 *  initFov can set default fov of camera.
                 */
                //initFov: 100,

                /**
                 *  Set street view can panning gestures or not.
                 *  default setting is true
                 */
                panningGesturesEnabled: true,

                /**
                 *  Set street view shows street name or not.
                 *  default setting is true
                 */
                //streetNamesEnabled: false,

                /**
                 *  Set street view can allow user move to other panorama or not.
                 *  default setting is true
                 */
                userNavigationEnabled: false,

                /**
                 *  Set street view can zoom gestures or not.
                 *  default setting is true
                 */
                //zoomGesturesEnabled: false,

                /**
                 *  To control street view after street view was initialized.
                 *  You should set [StreetViewCreatedCallback] to onStreetViewCreated.
                 *  And you can using [StreetViewController] object(controller) to control street view.
                 */
                onStreetViewCreated: (controller) async {
                  controller.animateTo(
                      duration: 50,
                      camera: StreetViewPanoramaCamera(
                          bearing: widget.bearing, tilt: 0, zoom: 1));
                },
                // markers: markerIcon == null
                //     ? {}
                //     : {
                //         Marker(
                //           markerId: const MarkerId('current_location'),
                //           position: LatLng(widget.latitude, widget.longitude),
                //           //position: LatLng(1.3546728595207234, 103.68799965195743),
                //           // icon: markerIcon!,
                //         )
                //       },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
