import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    
    
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      print("iOS Running...")
      // 앱 실행 시 뱃지를 0으로 설정
     application.applicationIconBadgeNumber = 0
      
    if #available(iOS 10.0,*) {
     UNUserNotificationCenter.current().delegate = self as?
     UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
 
}
