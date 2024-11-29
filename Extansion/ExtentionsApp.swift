//
//  ExtentionsApp.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 11/09/2024.
//

import SwiftUI

extension UIApplication {
    
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
