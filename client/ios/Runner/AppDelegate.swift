import Flutter
import UIKit
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  static func registerPlugins(with registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    AppDelegate.registerPlugins(with: self)
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      AppDelegate.registerPlugins(with: registry)
    }
    UIApplication.shared.setMinimumBackgroundFetchInterval(
      UIApplication.backgroundFetchIntervalMinimum
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
