import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 플러그인은 반드시 여기(앱 실행 완료 전)서 등록한다.
    // Flutter 3.47의 didInitializeImplicitFlutterEngine 방식은 플러그인을
    // UIApplicationDidFinishLaunchingNotification 뒤에 등록해서, 그 알림을 기다리는
    // firebase_messaging의 getInitialMessage가 영원히 끝나지 않는다.
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
