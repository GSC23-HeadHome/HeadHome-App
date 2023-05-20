import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

class GmapsStView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    print(bearing);
    Set<Marker> markers = {
  Marker(
    markerId: MarkerId('marker1'),
    position: LatLng(latitude, longitude),
    onTap: () {
      // Handle marker tap
    },
    icon: BitmapDescriptor.defaultMarker,
  ),
  // Marker(
  //   markerId: MarkerId('marker2'),
  //   position: LatLng(latitude, longitude),
  //   onTap: () {
  //     // Handle marker tap
  //   },
  //   icon: BitmapDescriptor.defaultMarker,
  // ),
  // Add more markers as needed
};
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
                initPos: LatLng(latitude, longitude),
                //initPos: LatLng(37.769263, -122.450727),
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
                initBearing: bearing,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initTilt can set default tilt of camera.
                 */
                initTilt: 0,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initZoom can set default zoom of camera.
                 */
                initZoom: 1.5,

                /**
                 *  iOS Only
                 *  It is worked while you set initPos or initPanoId.
                 *  initFov can set default fov of camera.
                 */
                //initFov: 120,

                /**
                 *  Set street view can panning gestures or not.
                 *  default setting is true
                 */
                //panningGesturesEnabled: false,

                /**
                 *  Set street view shows street name or not.
                 *  default setting is true
                 */
                //streetNamesEnabled: false,

                /**
                 *  Set street view can allow user move to other panorama or not.
                 *  default setting is true
                 */
                //userNavigationEnabled: false,

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
                          bearing: 15, tilt: 10, zoom: 3));
                },

                markers: markers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
