//
//  PhoneFormatter.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/11/2024.
//

import SwiftUI

extension View {
    
    func formatPhoneNumber(_ number: String) -> String {
        let digist = number.filter({$0.isNumber})
        let groups = stride(from: 0, to: digist.count, by: 3).map {
            let endIndex = min($0 + 3, digist.count)
            let range = digist.index(digist.startIndex, offsetBy: $0)..<digist.index(digist.startIndex, offsetBy: endIndex)
            return String(digist[range])
        }
        return groups.joined(separator: "-")
    }
}
