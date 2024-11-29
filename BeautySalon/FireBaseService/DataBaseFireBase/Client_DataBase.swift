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

@MainActor
final class Client_DataBase {
    
    //MARK: Properties
    
    static var shared = Client_DataBase()
    
    private(set) weak var listener: ListenerRegistration?
    
    let auth = Auth.auth()
    
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
    
    
    func setData_ClientFireBase(clientModel: Client) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await clientFs.document(uid).setData(clientModel.clientDic)
    }
    
    func setData_ClientForAdmin(adminID: String, clientModel: Client) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await mainFS.document(adminID).collection("Client").document(uid).setData(clientModel.clientDic)
    }

    func send_RecordForAdmin(adminID: String, record: Shedule) async throws {
        do {
            try await mainFS.document(adminID).collection("Record").addDocument(data: record.shedule)
        } catch {
            print("DEBUG: sendAppoitmentToMaster not correct send...", error.localizedDescription)
            throw error
        }
    }
    
    func fetchClient_DataFB() async throws -> Client? {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid", code: 0) }
        do {
            let snapShot = try await clientFs.document(uid).getDocument(as: Client.self)
            return snapShot
        } catch {
            print("DEBUG: ERROR fetch data current Client...", error.localizedDescription)
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
    
    func deinitListener() {
        listener?.remove()
        listener = nil
    }
    
}
