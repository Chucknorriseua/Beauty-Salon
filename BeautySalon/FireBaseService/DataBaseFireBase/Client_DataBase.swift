//
//  Client_DataBase.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


final class Client_DataBase {
    
    //MARK: Properties
    
    static var shared = Client_DataBase()
    
    private(set) weak var listener: ListenerRegistration?
    
    let auth = Auth.auth()
    @AppStorage("fcnTokenUser") var fcnTokenUser: String = ""
    
    private init() {
        
    }
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    
    private var clientFs: CollectionReference {
        return db.collection("Client")
    }
    
    private var mainFS: CollectionReference {
        return db.collection("BeautySalon")
    }
    
    private var master: CollectionReference {
        return db.collection("Master")
    }
    
    func setData_ClientFireBase(clientModel: Client) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await clientFs.document(uid).setData(clientModel.clientDic)
    }
    
    func setData_ClientForAdmin(adminID: String, clientModel: Client) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await mainFS.document(adminID).collection("Client").document(uid).setData(clientModel.clientDic)
    }
    
    func setData_ClientForMaster(masterID: String, clientModel: Client) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await master.document(masterID).collection("Client").document(uid).setData(clientModel.clientDic)
    }
    
    func addFavoritesSalon(salonID: String, salon: Company_Model) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await clientFs.document(uid).collection("FavoritesSalon").document(salonID).setData(salon.admin_Model_FB)
    }
    
    func addFavoritesMaster(masterID: String, master: MasterModel) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await clientFs.document(uid).collection("FavoritesMaster").document(masterID).setData(master.master_ModelFB)
    }
    
    func send_RecordForAdmin(adminID: String, record: Shedule) async throws {
        do {
            try await mainFS.document(adminID).collection("Record").document(record.id).setData(record.shedule)
            try await saveSendRecordsForAdmin(adminID: adminID, records: record)
        } catch {
            print("DEBUG: sendAppoitmentToMaster not correct send...", error.localizedDescription)
            throw error
        }
    }
    
    func saveSendRecordsForAdmin(adminID: String, records: Shedule) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await clientFs.document(uid).collection("MyRecords").document(records.id).setData(records.shedule)
    }
    
    func send_RecordForMaster(masterID: String, record: Shedule) async throws {
        do {
            try await master.document(masterID).collection("Record").document(record.id).setData(record.shedule)
            try await saveSendRecordsForAdmin(adminID: masterID, records: record)
        } catch {
            print("DEBUG: sendAppoitmentToMaster not correct send...", error.localizedDescription)
            throw error
        }
    }
    
    func fetchClient_DataFB() async throws -> Client? {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid", code: 0) }
        do {
            let snapShot = try await clientFs.document(uid).getDocument(as: Client.self)
            try await clientFs.document(uid).updateData(["fcnTokenUser": fcnTokenUser])
            return snapShot
        } catch {
            print("DEBUG: ERROR fetch data current Client...", error.localizedDescription)
            throw error
        }
    }
    
    func fetchFavorites_Salon() async throws -> [Company_Model] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid", code: 0) }
        do {
            let snapShot = try await clientFs.document(uid).collection("FavoritesSalon").getDocuments()
            
            let salon: [Company_Model] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToCompany(document)
            }
            return salon
        } catch {
            print("DEBUG: Error fetchFavorites_Salon", error.localizedDescription)
            throw error
        }
    }
    
    func fetchHomeCare_Salon(adminID: String) async throws -> [Procedure] {
        do {
            let snapShot = try await mainFS.document(adminID).collection("HomeCare").getDocuments()
            
            let homeCare: [Procedure] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToProcedure(document)
            }
            return homeCare
        } catch {
            print("DEBUG: Error fetchFavorites_Salon", error.localizedDescription)
            throw error
        }
    }
    
    func fetchMyrecordsFromSalonOrMaster() async throws -> [Shedule] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        do {
            let snapShot = try await clientFs.document(uid).collection("MyRecords").getDocuments()
            let shedule: [Shedule] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToShedule(document)
            }
            return shedule
        } catch {
            print("DEBUG: Error fetchAllCompany", error.localizedDescription)
            throw error
        }
    }
    
    func fetchFavorites_Master() async throws -> [MasterModel] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid", code: 0) }
        do {
            let snapShot = try await clientFs.document(uid).collection("FavoritesMaster").getDocuments()
            let master: [MasterModel] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToMater(document)
            }
            return master
        } catch {
            print("DEBUG: Error fetchFavorites_Master", error.localizedDescription)
            throw error
        }
    }
    
    func fetchAdmiProfile(adminId: String) async throws -> Company_Model? {
        do {
            let snapShot = try await mainFS.document(adminId).getDocument(as: Company_Model.self)
            return snapShot
        } catch {
            print("DEBUG: Error fetch profile as admin...", error.localizedDescription)
            throw error
        }
        
    }
    
    //  fetch All Masters in current company
    func getAllMastersFrom_AdminRoom(adminId: String) async throws -> [MasterModel] {
        do {
            
            let snapShot = try await mainFS.document(adminId).collection("Masters").getDocuments()
            let masters: [MasterModel] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToMater(document)
            }
            return masters
        } catch {
            print("DEBUG ERROR FETCH ALL MASTER...", error.localizedDescription)
            throw error
        }
    }
    
    func fetchHomeCallMasters() async throws -> [MasterModel] {
        
        let snapShot = try await master.getDocuments()
        let masters: [MasterModel] = try snapShot.documents.compactMap { document in
            return try Admin_DataBase.shared.convertDocumentToMater(document)
        }
        let masterHousecall = masters.filter {$0.categories == "housecall"}
        return masterHousecall
        
    }
    
    func updateLocationCompany(company: Client) async {
        guard let uid = auth.currentUser?.uid else { return }
        guard let latitude = company.latitude, let longitudes = company.longitude else { return }
        
        do {
            let master = clientFs.document(uid)
            try await master.updateData(["latitude": latitude, "longitude": longitudes])
            
        } catch {
            print("DEBUG: Error updateLocationCompany", error.localizedDescription)
        }
    }
    func remove_FavoritesSalon(salonID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = clientFs.document(uid).collection("FavoritesSalon")
        let snap = try await record.whereField("id", isEqualTo: salonID).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func remove_MyRecords(recordsID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = clientFs.document(uid).collection("MyRecords")
        let snap = try await record.whereField("id", isEqualTo: recordsID).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func remove_FavoritesMaster(masterID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = clientFs.document(uid).collection("FavoritesMaster")
        let snap = try await record.whereField("id", isEqualTo: masterID).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func deleteMyProfileFromFirebase(profile: Client) async throws {
        let profileMy = clientFs.whereField("id", isEqualTo: profile.id)

        let snap = try await profileMy.getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
        try await auth.currentUser?.delete()
    }
    
    func favoritesLikes(salonID: String, userID: String) async throws {
        let salonRef = mainFS.document(salonID)
        let userLikeRef = salonRef.collection("likes").document(userID)
        
        do {
            let likeDoc = try await userLikeRef.getDocument()
            
            if likeDoc.exists {
                print("Пользователь уже поставил лайк")
                return
            }
            try await userLikeRef.setData([
                "hasLiked": true,
                "timestamp": Timestamp()
            ])
            try await salonRef.updateData([
                "likes": FieldValue.increment(Int64(1))
            ])
            
            print("Лайк успешно добавлен")
        } catch {
            print("Ошибка при обновлении лайков:", error.localizedDescription)
            throw error
        }
    }
    
    func favoritesLikeMasters(masterID: String, userID: String) async throws {
        let salonRef = master.document(masterID)
        let userLikeRef = salonRef.collection("likes").document(userID)
        
        do {
            let likeDoc = try await userLikeRef.getDocument()
            
            if likeDoc.exists {
                print("Пользователь уже поставил лайк")
                return
            }
            try await userLikeRef.setData([
                "hasLiked": true,
                "timestamp": Timestamp()
            ])
            try await salonRef.updateData([
                "likes": FieldValue.increment(Int64(1))
            ])
            
            print("Лайк успешно добавлен")
        } catch {
            print("Ошибка при обновлении лайков:", error.localizedDescription)
            throw error
        }
    }
    
    func deinitListener() {
        listener?.remove()
        listener = nil
    }
    
}
