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
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth

@main
struct BeautyMastersApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
    }

    
    var body: some Scene {
        WindowGroup {
            CoordinatorViewModel()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    let notification = NotificationController()
    @AppStorage ("fcnTokenUser") var fcnTokenUser: String = ""
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ APNs Token получен: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("✅ FCM Token: \(token)")
            self.fcnTokenUser = token
        } else {
            print("❌ Ошибка получения FCM токена")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        notification.requestNotificationAuthorization()
        notification.notificationCenter.delegate = self
        Messaging.messaging().delegate = self
        
        
        let cache = SDImageCache.shared
        cache.config.maxMemoryCost = 50 * 1024 * 1024 // 50 MB
        cache.config.maxDiskSize = 200 * 1024 * 1024 // 200 MB
        cache.config.shouldCacheImagesInMemory = true
        cache.config.diskCacheReadingOptions = .mappedIfSafe
        
          SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
          SDImageCachesManager.shared.addCache(cache)
//          SDImageLoadersManager.shared.addLoader(SDImagePhotosLoader.shared)
          SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
          cache.clearMemory()
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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

