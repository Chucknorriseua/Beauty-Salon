//
//  Company_Model.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import Foundation

struct Company_Model: Identifiable, Codable, Hashable {
    
    let id: String
    var adminID: String
    var name: String
    var companyName: String
    var adress: String
    let email: String
    var phone: String
    var description: String
    var image: String?
    var procedure: [Procedure]
    var likes: Int
    var fcnTokenUser: String
    var latitude: Double?
    var longitude: Double?
    var categories: String
    
    static func companyModel() -> Company_Model {
        return Company_Model(id: "", adminID: "", name: "", companyName: "", adress: "", email: "", phone: "", description: "", image: "", procedure: [], likes: 0, fcnTokenUser: "", latitude: 0.0, longitude: 0.0, categories: "")
    }
    
    var admin_Model_FB: [String: Any] {
        var model = [String: Any]()
        model["id"] = self.id
        model["adminID"] = self.adminID
        model["name"] = self.name
        model["companyName"] = self.companyName
        model["adress"] = self.adress
        model["email"] = self.email
        model["phone"] = self.phone
        model["description"] = self.description
        model["image"] = self.image
        model["fcnTokenUser"] = self.fcnTokenUser
        model["procedure"] = self.procedure.map {$0.procedure}
        model["likes"] = self.likes
        model["latitude"] = self.latitude
        model["longitude"] = self.longitude
        model["categories"] = self.categories
        return model
    }
}

extension Company_Model: SearchAble {}
