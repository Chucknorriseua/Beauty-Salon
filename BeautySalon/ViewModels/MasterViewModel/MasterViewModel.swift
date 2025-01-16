//
//  MasterViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 30/08/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

final class MasterViewModel: ObservableObject {
    
    static let shared = MasterViewModel()
    
    @Published  private(set) var company: [Company_Model] = []
    @Published  private(set) var client: [Client] = []
    
    @Published  var isAlert: Bool = false
    @Published  var errorMassage: String = ""
    
    @Published var admin: Company_Model
    @Published var masterModel: MasterModel
    @Published var sheduleModel: Shedule
    
    var auth = Auth.auth()
    
    private init(sheduleModel: Shedule? = nil, admin: Company_Model? = nil, masterModel: MasterModel? = nil) {
        self.sheduleModel = sheduleModel ?? Shedule.sheduleModel()
        self.admin = admin ?? Company_Model.companyModel()
        self.masterModel = masterModel ?? MasterModel.masterModel()
    }
    
    //  MARK: Get All comapny
    func getCompany() async {
        do {
            
            let fetchAllCompany = try await Master_DataBase.shared.fetchAllCompany()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.company = fetchAllCompany
            }
            await fetchAllData()
            
        } catch {
            await handleError(error: error)
        }
    }
    
   private func fetchAllData() async {
        await withTaskGroup(of: Void.self) {[weak self] group in
            guard let self else { return }
            group.addTask(priority: .high) { await self.fetchProfile_Master(id: self.masterModel.id) }
            group.addTask { await Master_DataBase.shared.updateProfile_Master() }
        }
    }

    //  MARK: Fetch profile master
    func fetchProfile_Master(id: String) async {
        do {
            let master = try await Master_DataBase.shared.fecth_Data_Master_FB()
            //            this may be out of DispatchQueue
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.masterModel = master
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    func fetchCurrentClient() async {
        do {
            let client = try await Master_DataBase.shared.fetch_CurrentClient_FromAdmin(adminID: admin.adminID)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.client = client
            }
        } catch {
            await handleError(error: error)
        }
    }
    //  MARK: Save profile master
    func saveMaster_Profile() async {
        do {
            try await Master_DataBase.shared.setData_For_Master_FB(master: masterModel)
            try await Master_DataBase.shared.setDataMaster_ForAdminRoom(adminId: admin.adminID, master: masterModel)
        } catch {
            await handleError(error: error)
        }
    }
    
    func save_Profile() async {
        do {
            try await Master_DataBase.shared.setData_For_Master_FB(master: masterModel)
        } catch {
            await handleError(error: error)
        }
    }
    
    func uploadArrarURL_Image_Firebase(masterID: String, image: String) async {
        await Master_DataBase.shared.updateImage_ArrayCurrentIndex(id: masterID, masterModel: masterModel)
    }
    //  MARK: Delete image master
    
    func deleteGestureImageForIndex(image: String) async {
        guard let uid = auth.currentUser?.uid else { return }
        
        if let index = masterModel.imagesUrl?.firstIndex(of: image) {
            masterModel.imagesUrl?.remove(at: index)
        }
        
        do {
            try await Master_DataBase.shared.deleteImageFromFirebase(imageURL: image)
            await uploadArrarURL_Image_Firebase(masterID: uid, image: image)
        } catch {
            await handleError(error: error)
        }
    }
    
    func deleteImage(image: String) {
        if let index = masterModel.imagesUrl?.firstIndex(of: image) {
            masterModel.imagesUrl?.remove(at: index)
            Task {
                await deleteGestureImageForIndex(image: image)
            }
        }
        
    }
    private func handleError(error: Error) async {
        isAlert = true
        errorMassage = error.localizedDescription
        print("Error in task: \(error.localizedDescription)")
    }
}
