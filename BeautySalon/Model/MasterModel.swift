//
//  MasterModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import Foundation

struct MasterModel: Identifiable, Codable, Hashable {
    
    let id: String
    var masterID: String
    var roleMaster: String
    var name: String
    let email: String
    var phone: String
    var adress: String
    var description: String
    var image: String?
    var imagesUrl: [String]?
    var categories: String
    var masterMake: String
    var fcnTokenUser: String
    var likes: Int
    var procedure: [Procedure]
    var latitude: Double?
    var longitude: Double?
    
    
    static func masterModel() -> MasterModel {
        return MasterModel(id: "", masterID: "", roleMaster: "", name: "", email: "", phone: "", adress: "", description: "", image: "", imagesUrl: [], categories: "", masterMake: "", fcnTokenUser: "", likes: 0, procedure: [], latitude: 0.0, longitude: 0.0)
    }
    
    var master_ModelFB: [String: Any] {
        var model = [String: Any]()
        model["id"] = self.id
        model["masterID"] = self.masterID
        model["name"] = self.name
        model["roleMaster"] = self.roleMaster
        model["description"] = self.description
        model["email"] = self.email
        model["phone"] = self.phone
        model["adress"] = self.adress
        model["fcnTokenUser"] = self.fcnTokenUser
        model["categories"] = self.categories
        model["masterMake"] = self.masterMake
        model["likes"] = self.likes
        model["procedure"] = self.procedure.map {$0.procedure}
        model["latitude"] = self.latitude
        model["longitude"] = self.longitude
        if let image = self.image { model["image"] = image }
        if let imagesUrl = self.imagesUrl { model["imagesUrl"] = imagesUrl }
        return model
    }

}
extension MasterModel: SearchAble {
    var companyName: String { "" }
}
