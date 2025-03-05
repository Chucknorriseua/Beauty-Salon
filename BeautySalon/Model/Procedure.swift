//
//  Service.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI
import FirebaseFirestore

struct Procedure: Identifiable, Codable, Hashable {
    
    let id: String
    var title: String
    var price: String
    var image: String
    var colorText: String
    var description: String
    
    static func procedureModel() -> Procedure {
        return Procedure(id: "", title: "", price: "", image: "", colorText: "", description: "")
    }
    
    var procedure: [String: Any] {
        var model = [String: Any]()
        model["id"] = self.id
        model["title"] = self.title
        model["price"] = self.price
        model["colorText"] = self.colorText
        model["image"] = self.image
        model["description"] = self.description
        return model
    }
}

