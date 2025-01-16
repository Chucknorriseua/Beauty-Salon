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
    var description: String
    
    static func procedureModel() -> Procedure {
        return Procedure(id: "", title: "", price: "", description: "")
    }
    
    var procedure: [String: Any] {
        var model = [String: Any]()
        model["id"] = self.id
        model["title"] = self.title
        model["price"] = self.price
        model["description"] = self.description
        return model
    }
}

