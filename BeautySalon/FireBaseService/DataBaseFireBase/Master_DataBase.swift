//
//  Master_DataBase.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 09/09/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


final class Master_DataBase {
    
    
    //MARK: Properties
    
    static var shared = Master_DataBase()
    
    private(set) weak var listener: ListenerRegistration?
    
    let auth = Auth.auth()
    @AppStorage("fcnTokenUser") var fcnTokenUser: String = ""
    private init() {
        
    }
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    
    private var masterFs: CollectionReference {
        return db.collection("Master")
    }
    
    private var mainFS: CollectionReference {
        return db.collection("BeautySalon")
    }
    
    private var clientFs: CollectionReference {
        return db.collection("Client")
    }
    
    // MARK:  /\_____________________________SET-DATA-MASTER___________________________________/\
    
    func setData_For_Master_FB(master: MasterModel) async throws {
        guard let uid = auth.currentUser?.uid else { return }
    
        try await masterFs.document(uid).setData(master.master_ModelFB)
    }
    
    func setDataMaster_ForAdminRoom(adminId: String, master: MasterModel) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await mainFS.document(adminId).collection("Masters").document(uid).setData(master.master_ModelFB)
    }
    
    func setSheduleInStatic(sheduleID: String, shedule: Shedule) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await masterFs.document(uid).collection("StaticShedule").document(sheduleID).setData(shedule.shedule)
    }
    
    func addFavoritesSalon(salonID: String, salon: Company_Model) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await masterFs.document(uid).collection("FavoritesSalon").document(salonID).setData(salon.admin_Model_FB)
    }
    
    func addProcedure(procedure: Procedure) async throws {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        try await masterFs.document(uid).updateData(["procedure": FieldValue.arrayUnion([procedure.procedure])])
        }
    
    // MARK:  /\_____________________________FETCH-DATA-MASTER___________________________________/\
    func fecth_Data_Master_FB() async throws -> MasterModel {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        do {
            let snapShot = try await masterFs.document(uid).getDocument(as: MasterModel.self)
            try await masterFs.document(uid).updateData(["fcnTokenUser": fcnTokenUser])
            return snapShot
        } catch {
            print("DEBUG: Error fecth_Data_Master_FB", error.localizedDescription)
            throw error
        }
    }
    
    func fetch_Shedule_ForMaster(adminId: String) async throws -> [Shedule] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        do {
            let snapShot = try await mainFS.document(adminId).collection("Masters").document(uid).collection("Shedule").getDocuments()
            let shedul: [Shedule] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToShedule(document)
            }
            return shedul
        } catch {
            print("DEBUG: Error fetch_Shedule_ForMaster", error.localizedDescription)
            throw error
        }
    }
    
    func fetchSheduleFromClinet() async throws -> [Shedule] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        do {
            let snapShot = try await masterFs.document(uid).collection("Record").getDocuments()
            let shedule: [Shedule] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToShedule(document)
            }
            return shedule
        } catch {
            print("DEBUG: Error fetchAllCompany", error.localizedDescription)
            throw error
        }
    }
    
    func saveChangeSendClient(clientID: String, record: Shedule) async throws {
        let recordID = record.id
        let clientRef = clientFs.document(clientID)
        let clientSnapshot = try await clientRef.getDocument()

        if clientSnapshot.exists {
            let recordRef = clientRef.collection("MyRecords").document(recordID)
            
            try await recordRef.updateData(record.shedule)
            print("✅ Запись успешно обновлена для клиента с ID: \(clientID)")
        } else {
            print("❌ Клиент с ID \(clientID) не найден!")
        }
    }
    
    func fetchSheduleForStatic() async throws -> [Shedule] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        do {
            let snapShot = try await masterFs.document(uid).collection("StaticShedule").getDocuments()
            let shedule: [Shedule] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToShedule(document)
            }
            return shedule
        } catch {
            print("DEBUG: Error fetchAllCompany", error.localizedDescription)
            throw error
        }
    }
    
    //  MARK: Fetch all comapny with Fire Base BeautySalon/Company.... name admin and company
    func fetchAllCompany() async throws -> [Company_Model] {
        do {
            let snapShot = try await mainFS.getDocuments()
            let companies: [Company_Model] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToCompany(document)
            }
            return companies
        } catch {
            print("DEBUG: Error fetchAllCompany", error.localizedDescription)
            throw error
        }
    }
    
    func fetchFavorites_Salon() async throws -> [Company_Model] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid", code: 0) }
        do {
            let snapShot = try await masterFs.document(uid).collection("FavoritesSalon").getDocuments()
            
            let salon: [Company_Model] = try snapShot.documents.compactMap { document in
                return try Admin_DataBase.shared.convertDocumentToCompany(document)
            }
            return salon
        } catch {
            print("DEBUG: Error fetchFavorites_Salon", error.localizedDescription)
            throw error
        }
    }
    
    func fetch_CurrentClient_FromAdmin(adminID: String) async throws -> [Client] {
        do {
            let snapShot = try await mainFS.document(adminID).collection("Client").getDocuments()
       
            let client: [Client] = try snapShot.documents.compactMap { doc in
                return try Admin_DataBase.shared.convertDocumentToClient(doc)
            }

            return client
        } catch {
            print("DEBUG: Error fetch_CurrentClient_FromAdmin", error.localizedDescription)
            throw error
        }
    }
    
    func fetch_CurrentClient_FromMaster() async throws -> [Client] {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid", code: 0) }
        do {
            let snapShot = try await masterFs.document(uid).collection("Client").getDocuments()
       
            let client: [Client] = try snapShot.documents.compactMap { doc in
                return try Admin_DataBase.shared.convertDocumentToClient(doc)
            }

            return client
        } catch {
            print("DEBUG: Error fetch_CurrentClient_FromAdmin", error.localizedDescription)
            throw error
        }
    }
    
    
    // MARK:  /\_____________________________UPDATE-PUT-DATA-DELETE-MASTER___________________________________/\
    func changeRecordFromClient(record: Shedule, id: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        var idrec = record
        idrec.id = id
        let shedule = masterFs.document(uid).collection("Record").document(record.id)
        try await shedule.updateData(["creationDate": record.creationDate])

    }
    
    // Put data on Storage
    
    func uploadImageToStorage(path: String, imageData: Data) async -> URL? {
        do {
            guard let image = UIImage(data: imageData) else { return nil}
            let targetSize = CGSize(width: 900, height: 900)
            let resizedImage = image.resizeImageUpload(image: image, targetSize: targetSize)
            
            guard let imageSize = resizedImage.jpegData(compressionQuality: 0.3) else { return nil}
            
            let store = storage.reference().child(path)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            _ = try await store.putDataAsync(imageSize, metadata: metadata)
            
            let dowload = try await store.downloadURL()
            return dowload
        } catch {
            print("DEBUG: Error uploadImageToStorage", error.localizedDescription)
            return nil
        }
    }
    
    func uploadImage_URLAvatar_Storage_Master(imageData: Data) async -> URL? {
        guard let uid = auth.currentUser?.uid else { return nil}
        let path = "masterImage/\(uid)"
        return await uploadImageToStorage(path: path, imageData: imageData)
    }
    
    func addImage_ArrayURL_Storage(imageData: Data) async -> URL? {
        guard let uid = auth.currentUser?.uid else { return nil }
        let imageID = UUID().uuidString
        let path = "imagesUrl/\(uid)/\(imageID).jpg"
        return await uploadImageToStorage(path: path, imageData: imageData)
    }
    
    //    Update Image fire store
    func updateImageFireBase_Master(id: String, url: URL) async {
        
        do {
            let master = masterFs.document(id)
            try await master.updateData(["image": url.absoluteString])
        } catch {
      }
    }
    
    
    // Update image url if image is empty load on fire store
    
    func updateImage_URLS_FireBase_Master(id: String, urls: [URL]) async {
        
        do {
            let master = masterFs.document(id)
            let snapshot = try await master.getDocument()
            
            if var existingUrls = snapshot.data()?["imagesUrl"] as? [String] {
                existingUrls.append(contentsOf: urls.map({ $0.absoluteString }))
                
                try await master.updateData(["imagesUrl": existingUrls])
            } else {
                try await master.updateData(["imagesUrl": urls.map({ $0.absoluteString })])
            }
        } catch {
            print("DEBUG: Error updateImage_URLS_FireBase_Master", error.localizedDescription)
        }
    }
    //    Update Image fire store
    func updateImage_ArrayCurrentIndex(id: String, masterModel: MasterModel) async {
        guard let imageUrl = masterModel.imagesUrl else { return }
        
        do {
            let master = masterFs.document(id)
            try await master.updateData(["imagesUrl": imageUrl])
            
        } catch {
            print("DEBUG: Error updateImage_ArrayCurrentIndex", error.localizedDescription)
        }
    }
    
    func maxUploadImage(id: String, newImagesCount: Int) async -> Bool {
        do {
            let master = try await masterFs.document(id).getDocument()
            
            if let existingImages = master.data()?["imagesUrl"] as? [String] {
                let totalImages = existingImages.count + newImagesCount

                if totalImages > 20 {
                    print("You can upload a maximum of 20 images. Already uploaded: \(existingImages.count)")
                    return false
                }
            }
        } catch {
            print("Error checking image count:", error.localizedDescription)
        }
        return true
    }
    
    //    Load and upload image array URL image FB
    @MainActor
    func uploadMultipleImages(id: String, imageData: [Data]) async {
        let canUpload = await maxUploadImage(id: id, newImagesCount: imageData.count)
        if !canUpload {
            return
        }
        let imagesToUpload = Array(imageData.prefix(20))
        var urls: [URL] = []
        
        await withTaskGroup(of: URL?.self) { [weak self] group in
            guard let self else { return }
            
            for data in imagesToUpload {
                group.addTask {
                    guard let image = UIImage(data: data) else { return nil }
                    
                    let targetSize = CGSize(width: 900, height: 900)
                    let resizedImage = image.resizeImageUpload(image: image, targetSize: targetSize)
                    
                    var compressionQuality: CGFloat = 0.3
                    var compressedImageData = resizedImage.jpegData(compressionQuality: compressionQuality)
                    
                    while let data = compressedImageData, data.count > 1 * 1024 * 1024 {
                        compressionQuality -= 0.1
                        if compressionQuality < 0.1 {
                            break
                        }
                        compressedImageData = resizedImage.jpegData(compressionQuality: compressionQuality)
                    }
                    
                    guard let imageData = compressedImageData else { return nil }
                    
                    // Загрузка сжатого изображения
                    return await self.addImage_ArrayURL_Storage(imageData: imageData)
                }
            }
            for await result in group {
                if let url = result {
                    urls.append(url)
                }
            }
        }
        if !urls.isEmpty {
            await updateImage_URLS_FireBase_Master(id: id, urls: urls)
        }
    }
    
    func updateLocationCompany(company: MasterModel) async {
        guard let uid = auth.currentUser?.uid else { return }
        guard let latitude = company.latitude, let longitudes = company.longitude else { return }
        
        do {
            let master = masterFs.document(uid)
            try await master.updateData(["latitude": latitude, "longitude": longitudes])
            
        } catch {
            print("DEBUG: Error updateLocationCompany", error.localizedDescription)
        }
    }
    
    func deleteImageFromFirebase(imageURL: String) async throws {
        let store = storage.reference(forURL: imageURL)
        try await store.delete()
    }
    
    func remove_FavoritesSalon(salonID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = masterFs.document(uid).collection("FavoritesSalon")
        let snap = try await record.whereField("id", isEqualTo: salonID).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func removeProcedureFireBase(procedureID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = masterFs.document(uid)

        let snapshot = try await record.getDocument()
        guard let data = snapshot.data(),
              var procedures = data["procedure"] as? [[String: Any]] else { return }
        procedures.removeAll { procedure in
            guard let id = procedure["id"] as? String else { return false }
            return id == procedureID
        }
        try await record.updateData(["procedure": procedures])
    }
    
    
    func remove_SheduleFromClient(sheduleID: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let record = masterFs.document(uid).collection("Record")
        let snap = try await record.whereField("id", isEqualTo: sheduleID).getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
    }
    
    func deleteMyProfileFromFirebase(profile: MasterModel) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let profileMy = masterFs.whereField("id", isEqualTo: profile.id)

        let snap = try await profileMy.getDocuments()
        for doc in snap.documents {
            try await doc.reference.delete()
        }
        
        if let imageUrl = profile.image, !imageUrl.isEmpty {
            let storageRef = Storage.storage().reference().child("masterImage/\(uid)/")
            try await storageRef.delete()
        }
        let storageRef = Storage.storage().reference().child("imagesUrl/\(uid)/")
        let listResult = try await storageRef.listAll()
        
        for item in listResult.items {
            try await item.delete()
        }
        
        try await auth.currentUser?.delete()
    }
    
    func deinitListener() {
        listener?.remove()
        listener = nil
    }
    
    func checkPassword_For(adminID: String) async -> Bool {
        guard let uid = auth.currentUser?.uid else { return false}
        do {
            let snapShot = mainFS.document(adminID).collection("Masters").document(uid)
            let checkPassword = try await snapShot.getDocument()
            
            if let passwordRoom = checkPassword.data()?["masterID"] as? String {
                if passwordRoom == adminID {
                } else {
                    return true
                }
            }
            return false
        } catch {
            return false
        }
    }
}
