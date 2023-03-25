import UIKit
import Firebase
import FirebaseMessaging
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyDvqPCNKLAaB_MWnVaS7tyViGowrhyY0nQ")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
