/// Connection parameters for the HeadHome hardware.
class BluetoothConstants {
  static const String deviceName = "HeadHome";
  static const String serviceUUID = "d2769ce4-4941-41a8-87a8-7d8198a9ea85";
  static const String characteristicUUIDTX =
      "21b3d0b5-a458-480a-b063-629c7c1bad7b";
  static const String characteristicUUIDRX =
      "d6729370-102e-4eb3-a6e2-c1ac1fed26ff";
}

/// Fallback profile picture if user does not have a profile picture.
const String defaultProfilePic = "https://picsum.photos/200";

/// Connection parameters for the backend service at [baseUrl].
class ApiConstants {
  // static String baseUrl = 'https://HeadHome.chayhuixiang.repl.co';
  static String baseUrl = 'https://headhome-backend-nyji2662eq-as.a.run.app';
  static String travellog = 'travellog';
  static String volunteers = 'volunteers';
  static String caregiver = 'caregiver';
  static String carereceiver = 'carereceiver';
  static String contactcg = 'contactcg';
  static String sos = 'sos';
}
