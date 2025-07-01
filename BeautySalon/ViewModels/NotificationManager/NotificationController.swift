//
//  NotificationController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 10/10/2024.
//

import SwiftUI
import UserNotifications
import AppTrackingTransparency
import AdSupport

final class NotificationController {
    
    static let sharet = NotificationController()
    
    var notificationCenter = UNUserNotificationCenter.current()

    func notify(title: String, subTitle: String, timeInterval: Int) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
    
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Ошибка запроса разрешений: \(error.localizedDescription)")
            }
            print("✅ Разрешение на уведомления: \(granted)")
            self.getNotificationsSetting()
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func getNotificationsSetting() {
        notificationCenter.getNotificationSettings { settings in
            print("Notifications settings: \(settings)")
            if settings.authorizationStatus == .authorized {
                print("Notifications are authorized.")
                self.requestTrackingPermission()
            } else {
                print("Notifications are not authorized.")
                self.requestTrackingPermission()
            }
        }
    }
    
    func requestTrackingPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Отслеживание разрешено, IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied:
                    print("Отслеживание запрещено")
                case .notDetermined:
                    print("Пользователь еще не выбрал")
                case .restricted:
                    print("Доступ ограничен (например, родительский контроль)")
                @unknown default:
                    break
                }
            }
        }
    }
}
