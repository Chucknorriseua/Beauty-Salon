//
//  BeautyMastersApp.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 16/08/2024.
//

import SwiftUI
import Firebase
import FirebaseStorage
import SDWebImageSwiftUI
import GoogleSignIn

@main
struct BeautyMastersApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    init() {
        FirebaseApp.configure()
        
    }

    
    var body: some Scene {
        WindowGroup {
            CoordinatorViewModel()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let notification = NotificationController()
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
//            print("Device push notification token - \(tokenString)")
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        notification.requestAuthorization()
        notification.notificationCenter.delegate = self
        
        let cache = SDImageCache(namespace: "tiny")
          cache.config.maxMemoryCost = 100 * 1024 * 1024 // 100MB memory
          cache.config.maxDiskSize = 50 * 1024 * 1024 // 50MB disk
          SDImageCachesManager.shared.addCache(cache)
          SDWebImageManager.defaultImageCache = SDImageCachesManager.shared

//          SDImageLoadersManager.shared.addLoader(SDImagePhotosLoader.shared)
          SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        notification.notificationCenter.setBadgeCount(0) { error in
            if let error = error {
                print("applicationDidBecomeActive: ", error.localizedDescription)
            }
        }
    }

    // MARK: UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == UUID().uuidString {
            print("Handling notification with the local identifier")
        }
        completionHandler()
    }
}
