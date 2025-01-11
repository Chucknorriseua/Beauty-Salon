//
//  AdminViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 20/08/2024.
//

import SwiftUI
import FirebaseFirestore


final class AdminViewModel: ObservableObject {
    
    static let shared = AdminViewModel()
    
    @Published private(set) var allMasters: [MasterModel] = []
    @Published private(set) var recordsClient: [Shedule] = []
    @Published private(set) var addMasterInRoom: [MasterModel] = []
    @Published private(set) var client: [Client] = []
    
    @Published  var isAlert: Bool = false
    @Published  var errorMassage: String = ""
    
    @Published var adminProfile: Company_Model
    @Published var masterModel: MasterModel
    
    private init(adminProfile: Company_Model? = nil, masterModel: MasterModel? = nil) {
        self.adminProfile = adminProfile ?? Company_Model.companyModel()
        self.masterModel = masterModel ?? MasterModel.masterModel()
       
    }
    
    //  MARK: Fetch profile admin
    func fetchProfileAdmin() async {
        do {
            let profile = try await Admin_DataBase.shared.fetchAdmiProfile()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.adminProfile = profile
            }
            await fethAllData()
            
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("Error fetchProfileAdmin...", error.localizedDescription)
        }
        
    }
    
    private func fethAllData() async {
        await withTaskGroup(of: Void.self) { [weak self] group in
            guard let self else { return }
            group.addTask { await Admin_DataBase.shared.updateProfile_Admin()}
            group.addTask { await self.get_AllAdded_Masters_InRomm()}
            group.addTask { await Admin_DataBase.shared.removeYesterdaysClient()}
        }
    }
    
    //  MARK: ADD Master it to room
    func add_MasterToRoom(masterID: String, master: MasterModel) async {
        do {
            _ = await Admin_DataBase.shared.isMasterAllReadyInRoom(masterId: masterID)
            if !addMasterInRoom.contains(where: {$0.id == master.id}) {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.addMasterInRoom.append(master)
                }
            }
            try await Admin_DataBase.shared.add_MasterToRoom(idMaster: masterID, master: master)
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error add master in to room", error.localizedDescription)
        }
    }
    
    func fetchCurrentClient() async {
        do {
            let client = try await Admin_DataBase.shared.fetch_CurrentClient_SentRecord()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.client = client
            }
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error fetch current user...", error.localizedDescription)
        }
    }
    
    //  MARK: Set save new profile master
    func setNew_Admin_Profile() async {
        
        do {
            try await Admin_DataBase.shared.setCompanyForAdmin(admin: adminProfile)
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error save new data on firebase...", error.localizedDescription)
        }
    }
    //  MARK: Fetch all profile master in to rooms
    func fetchAllMastersFireBase() async {
        do {
            
            let master = try await Admin_DataBase.shared.fetch_All_MastersOn_FireBase()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.allMasters = master
                
            }
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error fetchAllMasters...", error.localizedDescription)
        }
        
    }
    
    //  MARK: Fetch all profile master in to rooms
    private func get_AllAdded_Masters_InRomm() async {
        do {
            
            let master = try await Admin_DataBase.shared.getAll_Added_Masters()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.addMasterInRoom = master
            }
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error fetchAllMasters...", error.localizedDescription)
        }
        
    }
    
    func sendCurrentMasterRecord(masterID: String, shedule: Shedule) async {
        
        do {
            try await Admin_DataBase.shared.send_ShedulesTo_Master(idMaster: masterID, shedule: shedule)
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error send current master records...", error.localizedDescription)
        }
    }
    
    func getPagination_DataRecord(isLoading: Bool = false) async {
        do {
            let records = try await Admin_DataBase.shared.fetch_ClientRecords(isLoad: isLoading)
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                if isLoading {
                    self.recordsClient = records
                } else {
                    let newRec = records.filter { newRec in
                        !self.recordsClient.contains(where: {$0.id == newRec.id})
                    }
                    self.recordsClient.append(contentsOf: newRec)
                }
            }
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error fetchRecordsClient...", error.localizedDescription)
        }
    }
    
    func deleteRecord(record: Shedule) async {
        if let index = recordsClient.firstIndex(where: {$0.id == record.id}) {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.recordsClient.remove(at: index)
            }
        }
        do {
            try await Admin_DataBase.shared.removeRecordFireBase(id: record.id)
            
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error deleteRecord...", error.localizedDescription)
        }
    }
    
    
    func deleteMasterFromSalon(master: MasterModel) async {
        if let index = addMasterInRoom.firstIndex(where: {$0.id == master.id}) {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.addMasterInRoom.remove(at: index)
            }
        }
        do {
            try await Admin_DataBase.shared.remove_MasterFromSalon(masterID: master.masterID)
        } catch {
            isAlert = true
            errorMassage = error.localizedDescription
            print("DEBUG: Error deleteRecord...", error.localizedDescription)
        }
    }
    
    @MainActor
    func clearMemory() {
        allMasters.removeAll()
    }
    
}
