//
//  MasterModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import Foundation
import Firebase

struct MasterModel: Identifiable, Codable, Hashable {
    
    let id: String
    var masterID: String
    var name: String
    let email: String
    var phone: String
    var description: String
    var image: String?
    var imagesUrl: [String]?
    
    var latitude: Double?
    var longitude: Double?
    
    static func masterModel() -> MasterModel {
        return MasterModel(id: "", masterID: "", name: "", email: "", phone: "", description: "", image: "", imagesUrl: [], latitude: 0.0, longitude: 0.0)
    }
    
    var master_ModelFB: [String: Any] {
        var model = [String: Any]()
        model["id"] = self.id
        model["masterID"] = self.masterID
        model["name"] = self.name
        model["description"] = self.description
        model["email"] = self.email
        model["phone"] = self.phone
        model["latitude"] = self.latitude
        model["longitude"] = self.longitude
        if let image = self.image { model["image"] = image }
        if let imagesUrl = self.imagesUrl { model["imagesUrl"] = imagesUrl }
        return model
    }

}
