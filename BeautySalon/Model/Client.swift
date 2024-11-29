//
//  ClientModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import Foundation
import FirebaseFirestore

struct Client: Identifiable, Codable, Hashable {
    
    let id: String
    var clientID: String
    var name: String
    let email: String
    var phone: String
    let date: Date
    var latitude: Double?
    var longitude: Double?
    
    static func clientModel() -> Client {
        return Client(id: "", clientID: "", name: "", email: "", phone: "", date: Date(), latitude: 0.0, longitude: 0.0)
    }
    
    var clientDic: [String: Any] {
        var dic = [String: Any]()
        dic["id"] = self.id
        dic["clientID"] = self.clientID
        dic["name"] = self.name
        dic["email"] = self.email
        dic["phone"] = self.phone
        dic["date"] = self.date
        dic["latitude"] = self.latitude
        dic["longitude"] = self.longitude
        return dic
    }
    
}
