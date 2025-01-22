//
//  Admin_DataBaseProtocolExt.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 14/10/2024.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseStorage

protocol Admin_DataBaseDocumentConvertProtocol {
    func convertDocumentToMater(_ document: DocumentSnapshot) throws -> MasterModel
    func convertDocumentToShedule(_ document: DocumentSnapshot) throws -> Shedule
    func convertDocumentToCompany(_ document: DocumentSnapshot) throws -> Company_Model
    func convertDocumentToClient(_ document: DocumentSnapshot) throws -> Client
}

extension Admin_DataBase: Admin_DataBaseDocumentConvertProtocol {
    func convertDocumentToClient(_ document: DocumentSnapshot) throws -> Client {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let clientID = data?["clientID"] as? String,
              let name =  data?["name"] as? String,
              let email = data?["email"] as? String,
              let phone = data?["phone"] as? String,
              let date = data?["date"] as? Timestamp,
              let latitude = data?["latitude"] as? Double,
              let shedules = data?["shedule"] as? [[String: Any]],
              let longitude = data?["longitude"] as? Double else { throw NSError(domain: "Not correct create data", code: 0, userInfo: nil)  }
              let createTampDate = date.dateValue()
        
        let shedule: [Shedule] = try shedules.compactMap { proce in
            guard let id = proce["id"] as? String,
                  let masterId = proce["masterId"] as? String,
                  let nameCurrent = proce["nameCurrent"] as? String,
                  let taskService = proce["taskService"] as? String,
                  let phone = proce["phone"] as? String,
                  let nameMaster = proce["nameMaster"] as? String,
                  let comment = proce["comment"] as? String,
                  let creationDate = proce["creationDate"] as? String,
                  let tint = proce["tint"] as? String,
                  let procedure = proce["procedure"] as? [[String: Any]],
                  let timesTamp = proce["timesTamp"] as? Timestamp else {
                throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
            }
            let procedur: [Procedure] = try procedure.compactMap { proce in
                guard let id = proce["id"] as? String,
                      let title = proce["title"] as? String,
                      let price = proce["price"] as? String,
                      let description = proce["description"] as? String else {
                    throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
                }
                return Procedure(id: id, title: title, price: price, description: description)
            }
            return Shedule(id: id, masterId: masterId, nameCurrent: nameCurrent, taskService: taskService, phone: phone,
                           nameMaster: nameMaster, comment: comment, creationDate: createTampDate, tint: tint, timesTamp: timesTamp, procedure: procedur)
        }
        
        return Client(id: id, clientID: clientID, name: name, email: email, phone: phone,
                      date: createTampDate, latitude: latitude, longitude: longitude, shedule: shedule)
    }
    
     func convertDocumentToMater(_ document: DocumentSnapshot) throws -> MasterModel {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let masterID = data?["masterID"] as? String,
              let name = data?["name"] as? String,
              let desc = data?["description"] as? String,
              let email = data?["email"] as? String,
              let phone = data?["phone"] as? String,
              let image = data?["image"] as? String,
              let imageUrl = data?["imagesUrl"] as? [String],
              let latitude = data?["latitude"] as? Double,
              let longitude = data?["longitude"] as? Double else {
            throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
        }
        return MasterModel(id: id, masterID: masterID, name: name, email: email,
                           phone: phone, description: desc, image: image,
                           imagesUrl: imageUrl, latitude: latitude, longitude: longitude)
    }
    
     func convertDocumentToShedule(_ document: DocumentSnapshot) throws -> Shedule {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let masterId = data?["masterId"] as? String,
              let nameCurrent =  data?["nameCurrent"] as? String,
              let taskService = data?["taskService"] as? String,
              let creationDate = data?["creationDate"] as? Timestamp,
              let phone = data?["phone"] as? String,
              let nameMaster = data?["nameMaster"] as? String,
              let procedure = data?["procedure"] as? [[String: Any]],
              let comment = data?["comment"] as? String,
              let tint = data?["tint"] as? String,
              let timesTamp = data?["timesTamp"] as? Timestamp else { throw NSError(domain: "Not correct create data", code: 0, userInfo: nil) }
        let createTampDate = creationDate.dateValue()
         
         let procedur: [Procedure] = try procedure.compactMap { proce in
             guard let id = proce["id"] as? String,
                   let title = proce["title"] as? String,
                   let price = proce["price"] as? String,
                   let description = proce["description"] as? String else {
                 throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
             }
             return Procedure(id: id, title: title, price: price, description: description)
         }
        return Shedule(id: id, masterId: masterId, nameCurrent: nameCurrent, taskService: taskService, phone: phone,
                       nameMaster: nameMaster, comment: comment, creationDate: createTampDate, tint: tint, timesTamp: timesTamp, procedure: procedur)
    }
    
     func convertDocumentToCompany(_ document: DocumentSnapshot) throws -> Company_Model {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let adminID = data?["adminID"] as? String,
              let name = data?["name"] as? String,
              let companyName = data?["companyName"] as? String,
              let email = data?["email"] as? String,
              let phone = data?["phone"] as? String,
              let image = data?["image"] as? String,
              let procedure = data?["procedure"] as? [[String: Any]],
              let adress = data?["adress"] as? String,
              let desc = data?["description"] as? String,
              let latitude = data?["latitude"] as? Double,
              let longitude = data?["longitude"] as? Double,
              let categories = data?["categories"] as? String else {
            throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
        }
         let procedur: [Procedure] = try procedure.compactMap { proce in
             guard let id = proce["id"] as? String,
                   let title = proce["title"] as? String,
                   let price = proce["price"] as? String,
                   let description = proce["description"] as? String else {
                 throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
             }
             return Procedure(id: id, title: title, price: price, description: description)
         }
        return Company_Model(id: id, adminID: adminID, name: name,
                             companyName: companyName,
                             adress: adress, email: email,
                             phone: phone, description: desc,
                             image: image, procedure: procedur, latitude: latitude, longitude: longitude, categories: categories)
    }
}
