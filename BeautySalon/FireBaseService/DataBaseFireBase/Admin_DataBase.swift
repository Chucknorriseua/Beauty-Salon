//
//  DataBaseFireBase.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 25/08/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


@MainActor
final class Admin_DataBase {
    
//MARK: Properties
    
    static var shared = Admin_DataBase()
    
    private(set) weak var listener: ListenerRegistration?
    
    let auth = Auth.auth()
    
    private init() {}
    
    private let db = Firestore.firestore()
    
    
    private let storage = Storage.storage().reference()
    
    private var mainFS: CollectionReference {
        return db.collection("BeautySalon")
    }
    
    private var masterFs: CollectionReference {
        return db.collection("Master")
    }
    
    
    // MARK:  /\_____________________________ADMIN___________________________________/\
    
    //    MARK: Save company on Fire Base BeautySalon/Company.... name admin and company
    func setCompanyForAdmin(admin: Company_Model) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await mainFS.document(uid).setData(admin.admin_Model_FB, merge: true)
    }

// Send shedule for master about client
    func send_ShedulesTo_Master(idMaster: String, shedule: Shedule) async throws {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }

        do {
            var id = shedule
            id.masterId = idMaster
            try await mainFS.document(uid).collection("Masters").document(idMaster).collection("Shedule").addDocument(data: id.shedule)

        } catch {
            print("DEBUG: sendAppoitmentToMaster not correct send...", error.localizedDescription)
            throw error
        }
    }
    
    // add a master to your room
    func add_MasterToRoom(idMaster: String, master: MasterModel) async throws {
            guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
            try await mainFS.document(uid).collection("Masters").document(master.masterID).setData(master.master_ModelFB)
        }
    
    func addProcedure(procedure: Procedure) async throws {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        try await mainFS.document(uid).updateData(["procedure": FieldValue.arrayUnion([procedure.procedure])])
        }
    
    func isMasterAllReadyInRoom(masterId: String) async -> Bool {
        let ref = mainFS.document(masterId).collection("Masters").document(masterId)
        do {
            let document = try await ref.getDocument()
            return document.exists
        } catch {
            print("DEBUG: Error isMasterAllReadyInRoom", error.localizedDescription)
            return false
        }
    }
    
    // MARK: Fetch Method
//  Fetch profile as Admin
    func fetchAdmiProfile() async throws -> Company_Model {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        
        do { let snapShot = try await mainFS.document(uid).getDocument(as: Company_Model.self)
            return snapShot
        } catch {
            print("DEBUG: Error fetch profile as admin...", error.localizedDescription)
            throw error
        }
    }
    
//  fetch All Masters in current company
    func fetch_All_MastersOn_FireBase() async throws -> [MasterModel] {
        do {
            let snapShot = try await masterFs.getDocuments()
            let masters: [MasterModel] = try snapShot.documents.compactMap {[weak self] document in
                return try self?.convertDocumentToMater(document)
            }
            return masters
        } catch {
            print("DEBUG ERROR FETCH ALL MASTER...", error.localizedDescription)
            throw error
        }
        
    }
    //  fetch All Masters in current company
        func getAll_Added_Masters() async throws -> [MasterModel] {
            guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
            do {
                
                let snapShot = try await mainFS.document(uid).collection("Masters").getDocuments()
                let masters: [MasterModel] = try snapShot.documents.compactMap { [weak self] document in
                    return try self?.convertDocumentToMater(document)
                }
                return masters
            } catch {
                print("DEBUG ERROR FETCH ALL MASTER...", error.localizedDescription)
                throw error
            }
            
        }
    
    func fetchShedule_CurrentMaster(masterID: String) async throws -> [Shedule] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil)}
        do {
            let snapShot = try await mainFS.document(uid).collection("Masters").document(masterID).collection("Shedule").getDocuments()
            let shedule: [Shedule] = try snapShot.documents.compactMap {[weak self] doc in
                return try self?.convertDocumentToShedule(doc)
            }
            return shedule
        } catch {
            print("DEBUG: ERROR FETCH CURRENT MASTRER SHEDULE1111", error.localizedDescription)
            throw error
        }
    }

    func fetch_CurrentClient_SentRecord() async throws -> [Client] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil)}
        do {
            let snapShot = try await mainFS.document(uid).collection("Client").getDocuments()
            let client: [Client] = try snapShot.documents.compactMap {[weak self] doc in
                return try self?.convertDocumentToClient(doc)
            }
            return client
        } catch {
            print("DEBUG: ERROR FETCH CURRENT MASTRER SHEDULE22222", error.localizedDescription)
            throw error
        }
    }
    
    func fetch_ClientRecords() async throws -> [Shedule] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil)}
        do {
        let snapShot = try await mainFS.document(uid).collection("Record").getDocuments()
        let shedule: [Shedule] = try snapShot.documents.compactMap {[weak self] doc in
            return try self?.convertDocumentToShedule(doc)
        }
        return shedule
        } catch {
            print("DEBUG: ERROR FETCH records amount", error.localizedDescription)
            throw error
        }
    }
//    func fetch_ClientRecords(isLoad: Bool = false) async throws -> [Shedule] {
//        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil)}
//        var query = mainFS.document(uid).collection("Record").order(by: "creationDate", descending: false).limit(to: pageSize)
//        
//        if let lastDoc = lastDocument, !isLoad {
//            query = query.start(afterDocument: lastDoc)
//        }
//        
//        do {
//            
//            let snapShot = try await query.getDocuments()
//     
//            let newRec = snapShot.documents.compactMap { document in
//                try? document.data(as: Shedule.self)
//            }
//            
//            lastDocument = snapShot.documents.last
//            return newRec
//        } catch {
//            print("DEBUG: ERROR FETCH records amount", error.localizedDescription)
//            throw error
//        }
//    }
    
// MARK: Update Image
// update profile as admin

//    func updateProfile_Admin() async {
//        guard let uid = auth.currentUser?.uid else { return }
//        
//        listener = mainFS.document(uid).addSnapshotListener({ snap, error in
//            
//            if let error = error {
//                print("Error", error.localizedDescription)
//            }
//            
//            guard let document = snap, document.exists else { return }
//            
//            if let data = try? document.data(as: Company_Model.self) {
//                
//                DispatchQueue.main.async {
//                    AdminViewModel.shared.adminProfile = data
//                }
//            }
//        })
//    }
    
    //    Update Image fire store
    func updateLocationCompany(company: Company_Model) async {
        guard let uid = auth.currentUser?.uid else { return }
        guard let latitude = company.latitude, let longitudes = company.longitude else { return }
        
        do {
            let master = mainFS.document(uid)
            try await master.updateData(["latitude": latitude, "longitude": longitudes])
            
        } catch {
            print("DEBUG: Error updateLocationCompany", error.localizedDescription)
        }
    }
    
    func changeRecordFromClient(record: Shedule, id: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        var idrec = record
        idrec.id = id
        let shedule = mainFS.document(uid).collection("Record").document(record.id)
        try await shedule.updateData(["nameMaster": record.nameMaster, "creationDate": record.creationDate, "procedure": record.procedure.map({$0.procedure})])

    }
    
    
    func upDatedImage_URL_Firebase_Admin(imageData: Data) async -> URL? {
        guard let uid = auth.currentUser?.uid else { return nil }
        
        guard let imageData = UIImage(data: imageData) else { return nil}
        let targetSize = CGSize(width: 900, height: 900)
        let resizedImage = imageData.resizeImageUpload(image: imageData, targetSize: targetSize)
        guard let image = resizedImage.jpegData(compressionQuality: 0.3) else { return nil}
        do {
            let store = storage.child("image/\(uid)")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            _ = try await store.putDataAsync(image, metadata: metadata)
            
            let dowload = try await store.downloadURL()
            return dowload
        } catch {
            print("DEBUG: Error upload image...", error.localizedDescription)
            return nil
        }
    }
    
    func uploadImageFireBase_Admin(id: String, url: URL) async {
        do {
            let adminFB = mainFS.document(id)
            try await adminFB.updateData(["image": url.absoluteString])
            
        } catch {
            print("DEBUG: Error uploadImageFireBase", error.localizedDescription)
        }
    }
//    MARK: REMOVE
    func removeRecordFireBase(id: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record =  mainFS.document(uid).collection("Record")
        let snap = try await record.whereField("id", isEqualTo: id).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func removeProcedureFireBase(procedureID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = mainFS.document(uid)

        let snapshot = try await record.getDocument()
        guard let data = snapshot.data(),
              var procedures = data["procedure"] as? [[String: Any]] else { return }
        procedures.removeAll { procedure in
            guard let id = procedure["id"] as? String else { return false }
            return id == procedureID
        }
        try await record.updateData(["procedure": procedures])
    }
    
    func remove_MasterFromSalon(masterID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record =  mainFS.document(uid).collection("Masters")
        let snap = try await record.whereField("masterID", isEqualTo: masterID).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func remove_MasterShedule(shedule: Shedule, clientID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record =  mainFS.document(uid).collection("Masters").document(clientID).collection("Shedule")
        let snap = try await record.whereField("id", isEqualTo: shedule.id).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func removeOldSchedules(masterID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let record = mainFS.document(uid)
            .collection("Masters")
            .document(masterID)
            .collection("Shedule")
        
        let snap = try await record
            .whereField("creationDate", isLessThan: startOfToday)
            .getDocuments()

        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func removeYesterdaysClient() async  {
        guard let uid = auth.currentUser?.uid else { return }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let record = mainFS.document(uid).collection("Record")
        do {
            let snap = try await record
                .whereField("creationDate", isLessThan: startOfToday)
                .getDocuments()
            
            for doc in snap.documents {
                try await doc.reference.delete()
            }
        } catch {
            print("removeYesterdaysClient", error.localizedDescription)
        }
    }
    
    func deinitListener() {
        listener?.remove()
        listener = nil
    }

}

//func fetch_CurrentClient_SentRecord() async throws -> [Client] {
//    guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil)}
//    do {
//        let snapShot = try await mainFS.document(uid).collection("Client").getDocuments()
//        let client: [Client] = try snapShot.documents.compactMap {[weak self] doc in
//            return try self?.convertDocumentToClient(doc)
//        }
//        return client
//    } catch {
//        print("DEBUG: ERROR FETCH CURRENT MASTRER SHEDULE22222", error.localizedDescription)
//        throw error
//    }
//}
