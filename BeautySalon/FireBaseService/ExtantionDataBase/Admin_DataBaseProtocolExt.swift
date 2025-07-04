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
    func convertDocumentToProcedure(_ document: DocumentSnapshot) throws -> Procedure
}

extension Admin_DataBase: Admin_DataBaseDocumentConvertProtocol {
    func convertDocumentToProcedure(_ document: DocumentSnapshot) throws -> Procedure {
        let proce = document.data()
        guard let id = proce?["id"] as? String,
              let title = proce?["title"] as? String,
              let image = proce?["image"] as? String,
              let colorText = proce?["colorText"] as? String,
              let price = proce?["price"] as? String,
              let description = proce?["description"] as? String else {
            throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
        }
        return Procedure(id: id, title: title, price: price, image: image, colorText: colorText, description: description)
    }
    
    func convertDocumentToClient(_ document: DocumentSnapshot) throws -> Client {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let clientID = data?["clientID"] as? String,
              let name =  data?["name"] as? String,
              let email = data?["email"] as? String,
              let phone = data?["phone"] as? String,
              let fcnTokenUser = data?["fcnTokenUser"] as? String,
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
                  let fcnTokenUser = data?["fcnTokenUser"] as? String,
//                  let creationDate = proce["creationDate"] as? String,
                  let tint = proce["tint"] as? String,
                  let procedure = proce["procedure"] as? [[String: Any]],
                  let latitude = data?["latitude"] as? Double,
                  let longitude = data?["longitude"] as? Double,
                  let nameSalonOrManster = data?["nameSalonOrManster"] as? String,
                  let phoneSalonOrMaster = data?["phoneSalonOrMaster"] as? String,
                  let timesTamp = proce["timesTamp"] as? Timestamp else {
                throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
            }
            let procedur: [Procedure] = try procedure.compactMap { proce in
                guard let id = proce["id"] as? String,
                      let title = proce["title"] as? String,
                      let image = proce["image"] as? String,
                      let colorText = proce["colorText"] as? String,
                      let price = proce["price"] as? String,
                      let description = proce["description"] as? String else {
                    throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
                }
                return Procedure(id: id, title: title, price: price, image: image, colorText: colorText, description: description)
            }
            return Shedule(id: id, masterId: masterId, nameCurrent: nameCurrent, taskService: taskService, phone: phone,
                           nameMaster: nameMaster, comment: comment, creationDate: createTampDate, fcnTokenUser: fcnTokenUser, tint: tint, timesTamp: timesTamp, procedure: procedur, latitude: latitude, longitude: longitude, nameSalonOrManster: nameSalonOrManster, phoneSalonOrMaster: phoneSalonOrMaster)
        }
        
        return Client(id: id, clientID: clientID, name: name, email: email, phone: phone,
                      date: createTampDate, fcnTokenUser: fcnTokenUser, latitude: latitude, longitude: longitude, shedule: shedule)
    }
    
     func convertDocumentToMater(_ document: DocumentSnapshot) throws -> MasterModel {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let masterID = data?["masterID"] as? String,
              let name = data?["name"] as? String,
              let roleMaster = data?["roleMaster"] as? String,
              let desc = data?["description"] as? String,
              let email = data?["email"] as? String,
              let phone = data?["phone"] as? String,
              let image = data?["image"] as? String,
              let likes = data?["likes"] as? Int,
              let fcnTokenUser = data?["fcnTokenUser"] as? String,
              let imageUrl = data?["imagesUrl"] as? [String],
              let adress = data?["adress"] as? String,
              let categories = data?["categories"] as? String,
              let masterMake = data?["masterMake"] as? String,
              let procedure = data?["procedure"] as? [[String: Any]],
              let latitude = data?["latitude"] as? Double,
              let longitude = data?["longitude"] as? Double else {
            throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
        }
         let procedur: [Procedure] = try procedure.compactMap { proce in
             guard let id = proce["id"] as? String,
                   let title = proce["title"] as? String,
                   let price = proce["price"] as? String,
                   let colorText = proce["colorText"] as? String,
                   let image = proce["image"] as? String,
                   let description = proce["description"] as? String else {
                 throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
             }
             return Procedure(id: id, title: title, price: price, image: image, colorText: colorText, description: description)
         }
         return MasterModel(id: id, masterID: masterID, roleMaster: roleMaster, name: name, email: email,
                            phone: phone, adress: adress, description: desc, image: image,
                            imagesUrl: imageUrl, categories: categories, masterMake: masterMake, fcnTokenUser: fcnTokenUser, likes: likes, procedure: procedur, latitude: latitude, longitude: longitude)
    }
    
     func convertDocumentToShedule(_ document: DocumentSnapshot) throws -> Shedule {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let masterId = data?["masterId"] as? String,
              let nameCurrent =  data?["nameCurrent"] as? String,
              let taskService = data?["taskService"] as? String,
              let creationDate = data?["creationDate"] as? Timestamp,
              let phone = data?["phone"] as? String,
              let fcnTokenUser = data?["fcnTokenUser"] as? String,
              let nameMaster = data?["nameMaster"] as? String,
              let procedure = data?["procedure"] as? [[String: Any]],
              let comment = data?["comment"] as? String,
              let tint = data?["tint"] as? String,
              let nameSalonOrManster = data?["nameSalonOrManster"] as? String,
              let phoneSalonOrMaster = data?["phoneSalonOrMaster"] as? String,
              let latitude = data?["latitude"] as? Double,
              let longitude = data?["longitude"] as? Double,
              let timesTamp = data?["timesTamp"] as? Timestamp else { throw NSError(domain: "Not correct create data", code: 0, userInfo: nil) }
        let createTampDate = creationDate.dateValue()
         
         let procedur: [Procedure] = try procedure.compactMap { proce in
             guard let id = proce["id"] as? String,
                   let title = proce["title"] as? String,
                   let image = proce["image"] as? String,
                   let colorText = proce["colorText"] as? String,
                   let price = proce["price"] as? String,
                   let description = proce["description"] as? String else {
                 throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
             }
             return Procedure(id: id, title: title, price: price, image: image, colorText: colorText, description: description)
         }
        return Shedule(id: id, masterId: masterId, nameCurrent: nameCurrent, taskService: taskService, phone: phone,
                       nameMaster: nameMaster, comment: comment, creationDate: createTampDate, fcnTokenUser: fcnTokenUser, tint: tint, timesTamp: timesTamp, procedure: procedur, latitude: latitude, longitude: longitude, nameSalonOrManster: nameSalonOrManster, phoneSalonOrMaster: phoneSalonOrMaster)
    }
    
     func convertDocumentToCompany(_ document: DocumentSnapshot) throws -> Company_Model {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let adminID = data?["adminID"] as? String,
              let name = data?["name"] as? String,
              let roleAdmin = data?["roleAdmin"] as? String,
              let companyName = data?["companyName"] as? String,
              let email = data?["email"] as? String,
              let phone = data?["phone"] as? String,
              let image = data?["image"] as? String,
              let procedure = data?["procedure"] as? [[String: Any]],
              let adress = data?["adress"] as? String,
              let fcnTokenUser = data?["fcnTokenUser"] as? String,
              let desc = data?["description"] as? String,
              let likes = data?["likes"] as? Int,
              let latitude = data?["latitude"] as? Double,
              let longitude = data?["longitude"] as? Double,
              let categories = data?["categories"] as? String else {
            throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
        }
         let procedur: [Procedure] = try procedure.compactMap { proce in
             guard let id = proce["id"] as? String,
                   let title = proce["title"] as? String,
                   let image = proce["image"] as? String,
                   let colorText = proce["colorText"] as? String,
                   let price = proce["price"] as? String,
                   let description = proce["description"] as? String else {
                 throw NSError(domain: "snapShot error data", code: 0, userInfo: nil)
             }
             return Procedure(id: id, title: title, price: price, image: image, colorText: colorText, description: description)
         }
         return Company_Model(id: id, adminID: adminID, roleAdmin: roleAdmin, name: name,
                             companyName: companyName,
                             adress: adress, email: email,
                             phone: phone, description: desc,
                             image: image, procedure: procedur, likes: likes, fcnTokenUser: fcnTokenUser, latitude: latitude, longitude: longitude, categories: categories)
    }
}
