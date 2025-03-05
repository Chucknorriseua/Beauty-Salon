//
//  Shedule.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 20/08/2024.
//

import SwiftUI
import FirebaseFirestore

struct Shedule: Identifiable, Codable, Hashable {
    
    var id: String
    var masterId: String
    var nameCurrent: String
    var taskService: String
    var phone: String
    var nameMaster: String
    var comment: String
    var creationDate: Date
    var fcnTokenUser: String
    var tint: String
    var timesTamp: Timestamp
    var procedure: [Procedure]
    
    static func sheduleModel() -> Shedule {
        return Shedule(id: "", masterId: "", nameCurrent: "", taskService: "", phone: "", nameMaster: "", comment: "", creationDate: Date(), fcnTokenUser: "", tint: "", timesTamp: Timestamp(date: Date()), procedure: [])
    }
    
    var tinColor: Color {
        switch tint {
        case "Color": return Color.init(hex: "#4F988D")
        case "Color1": return Color.init(hex: "#4786B0")
        case "Color2": return Color.init(hex: "#C23240")
        case "Color3": return Color.init(hex: "#608C7D")
        case "Color4": return Color.init(hex: "#D87ABB")
        case "Color5": return Color.init(hex: "#DC953E")
        default:
            return Color.init(hex: "#4F988D")
        }
    }
    
    var shedule: [String: Any] {
        var model = [String: Any]()
        model["id"] = self.id
        model["masterId"] = self.masterId
        model["nameCurrent"] = self.nameCurrent
        model["taskService"] = self.taskService
        model["phone"] = self.phone
        model["nameMaster"] = self.nameMaster
        model["comment"] = self.comment
        model["fcnTokenUser"] = self.fcnTokenUser
        model["creationDate"] = self.creationDate
        model["tint"] = self.tint
        model["timesTamp"] = self.timesTamp
        model["procedure"] = self.procedure.map {$0.procedure }
        return model
    }
}
