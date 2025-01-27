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
    var tint: String
    var timesTamp: Timestamp
    var procedure: [Procedure]
    
    static func sheduleModel() -> Shedule {
        return Shedule(id: "", masterId: "", nameCurrent: "", taskService: "", phone: "", nameMaster: "", comment: "", creationDate: Date(), tint: "", timesTamp: Timestamp(date: Date()), procedure: [])
    }
    
    var tinColor: Color {
        switch tint {
        case "Color": return .mint.opacity(0.4)
        case "Color1": return .blue.opacity(0.4)
        case "Color2": return .red.opacity(0.4)
        case "Color3": return .green.opacity(0.4)
        case "Color4": return .pink.opacity(0.4)
        case "Color5": return .orange.opacity(0.4)
        default:
            return .mint
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
        model["creationDate"] = self.creationDate
        model["tint"] = self.tint
        model["timesTamp"] = self.timesTamp
        model["procedure"] = self.procedure.map {$0.procedure }
        return model
    }
}
