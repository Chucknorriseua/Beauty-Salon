//
//  PhoneNumber.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 13/09/2024.
//

import SwiftUI

// Function to format the phone number
func formatPhoneNumber(_ phone: String) -> String {
    // Удаляем все символы, кроме цифр
    var numbersOnly = phone.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
    
    // Ограничиваем длину номера 12 символами (095-XXX-XX-XX)
    if numbersOnly.count > 14 {
        numbersOnly = String(numbersOnly.prefix(14))
    }
    
    // Добавляем префикс если его нет
    if !numbersOnly.hasPrefix("380") {
        numbersOnly = "380" + numbersOnly
    }
    
    // Форматируем номер: +(380)-XXX-XXX-XX-XX
    var formattedString = "+(380) "
    
    let areaCode = String(numbersOnly.dropFirst(3).prefix(3)) // 095
    formattedString += areaCode
    
    if numbersOnly.count > 6 {
        let middle = String(numbersOnly.dropFirst(6).prefix(3)) // 091
        formattedString += "-" + middle
    }
    
    if numbersOnly.count > 9 {
        let lastPart = String(numbersOnly.dropFirst(9)) // XX-XX
        formattedString += "-" + lastPart.prefix(2) + "-" + lastPart.suffix(2)
    }
    
    return formattedString
}

// Function to validate phone number
func isValidPhoneNumber(_ phone: String) -> Bool {
    let phoneRegex = "^\\+\\(380\\) \\d{3}-\\d{3}-\\d{2}-\\d{2}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return predicate.evaluate(with: phone)
}
