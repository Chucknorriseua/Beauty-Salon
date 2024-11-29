//
//  KeyboardResponder.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 15/09/2024.
//
import SwiftUI
@MainActor
class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    var notificationCenter: NotificationCenter
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            DispatchQueue.main.async { [weak self] in
                self?.currentHeight = keyboardFrame.height
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.currentHeight = 0
        }
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
