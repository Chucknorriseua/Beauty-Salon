//
//  ClientViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI
import FirebaseFirestore

final class ClientViewModel: ObservableObject {
    
    static let shared = ClientViewModel()
    
    @Published private(set) var salonFavorites: [Company_Model] = []
    @Published private(set) var masterFavorites: [MasterModel] = []
    @Published private(set) var comapny: [Company_Model] = []
    @Published private(set) var mastersInRoom: [MasterModel] = []
    @Published private(set) var homeCall: [MasterModel] = []
    @Published private(set) var homeCareSalon: [Procedure] = []
    @Published var procedure: [Procedure] = []
    
    @Published var isAlert: Bool = false
    @Published var isFetchDataLoader: Bool = false
    @Published var errorMassage: String = ""
    @Published var totalCost: Double = 0.0
    @Published var plusFavorites: Int = 0
    
    @Published var adminProfile: Company_Model
    @Published var clientModel: Client
    @Published var mastersProfile: MasterModel
    
    @Published var currentDate: Date = Date()
    
    private init(adminProfile: Company_Model? = nil, clientModel: Client? = nil, mastersProfile: MasterModel? = nil) {
        self.adminProfile = adminProfile ?? Company_Model.companyModel()
        self.clientModel = clientModel ?? Client.clientModel()
        self.mastersProfile = mastersProfile ?? MasterModel.masterModel()
        Task {
            await fetchAll_Comapny()
        }
    }
    
    
    
// MARK: Favorites
    @MainActor
    func addMyFavoritesSalon(salon: Company_Model) async {
        do {
            try await Client_DataBase.shared.addFavoritesSalon(salonID: salon.adminID, salon: salon)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if !salonFavorites.contains(where: {$0.id == salon.id}) {
          
                    self.salonFavorites.append(salon)
                }
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    func fetchFavoritesSalon() async {
        do {
          let salon = try await Client_DataBase.shared.fetchFavorites_Salon()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.salonFavorites = salon
            }
        } catch {
            print("error fetchFavoritesSalon", error.localizedDescription)
            await handleError(error: error)
        }
    }
    
    @MainActor
    func removeFavoritesSalon(salon: Company_Model) async {
        do {
            if let index = self.salonFavorites.firstIndex(where: { $0.id == salon.id }) {
                try await Client_DataBase.shared.remove_FavoritesSalon(salonID: salon.id)
                self.salonFavorites.remove(at: index)
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    @MainActor
    func addMyFavoritesMaster(master: MasterModel) async {
        do {
            try await Client_DataBase.shared.addFavoritesMaster(masterID: master.id, master: master)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if !masterFavorites.contains(where: {$0.id == master.id}) {
              
                    self.masterFavorites.append(master)
                }
            }
        } catch {
        await handleError(error: error)
        }
    }
    
    func fetchFavoritesMaster() async {
        do {
          let master = try await Client_DataBase.shared.fetchFavorites_Master()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.masterFavorites = master
            }
        } catch {
            print("error fetchFavoritesMaster", error.localizedDescription)
            await handleError(error: error)
        }
    }
    
    @MainActor
    func removeMyFavoritesMaster(master: MasterModel) async {
        do {
            if let index = self.masterFavorites.firstIndex(where: { $0.id == master.id }) {
                try await Client_DataBase.shared.remove_FavoritesMaster(masterID: master.id)
                self.masterFavorites.remove(at: index)
            }
        } catch {
            await handleError(error: error)
        }
    }
    
//_______________________________________________________________________________________________________
    
    
// MARK: PROCEDURE
    @MainActor
    func addNewProcedure(addProcedure: Procedure) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !procedure.contains(where: {$0.id == addProcedure.id}) {
                self.totalCost += Double(String(addProcedure.price)) ?? 0.0
                self.procedure.append(addProcedure)
            }
        }

    }
    
    @MainActor
    func removeProcedure(selectedProcedure: [Procedure]) {
        for procedure in selectedProcedure {
            if let index = self.procedure.firstIndex(where: { $0.id == procedure.id }) {
                self.totalCost -= Double(String(procedure.price)) ?? 0.0
                self.procedure.remove(at: index)
            }
        }
    }
//_______________________________________________________________________________________________________

    func fetchAll_Comapny() async {
        do {
          let comapnies = try await Master_DataBase.shared.fetchAllCompany()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.comapny = comapnies
            }
            await fetch_ProfileClient()
            await fetchHomeCallMaster()
            
        } catch {
            print("error fetchAll_Comapny", error.localizedDescription)
//            await handleError(error: error)
        }
    }
    
   private func fetch_ProfileClient() async {
        do {
            guard let client = try await Client_DataBase.shared.fetchClient_DataFB() else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.clientModel = client
            }
        } catch {
            await handleError(error: error)
        }
    }
 
    func fetchCurrent_AdminSalon(adminId: String) async {
        do {
            guard let admin = try await Client_DataBase.shared.fetchAdmiProfile(adminId: adminId) else { return}
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.adminProfile = admin
            }
            await fetchAllMasters_FromAdmin()
            await fetchHomeCare(adminID: adminId)
        } catch {
            await handleError(error: error)
        }
    }
    
// MARK: HOME CARE
        func fetchHomeCare(adminID: String) async {
            do {
              let homeCare = try await Client_DataBase.shared.fetchHomeCare_Salon(adminID: adminID)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.homeCareSalon = homeCare
                }
            } catch {
                print("error fetchHomeCare", error.localizedDescription)
                await handleError(error: error)
            }
        }
//_______________________________________________________________________________________________________
    
   private func fetchAllMasters_FromAdmin() async {
        let adminId = adminProfile.adminID
        do {
            let masters = try await Client_DataBase.shared.getAllMastersFrom_AdminRoom(adminId: adminId)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.mastersInRoom = masters
            }
            await MainActor.run { [weak self] in
                self?.isFetchDataLoader = true
            }
        } catch {
            await handleError(error: error)
        }
    }
    
   private func fetchHomeCallMaster() async {
        do {
            let masters = try await Client_DataBase.shared.fetchHomeCallMasters()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.homeCall = masters
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    func send_SheduleForAdmin(adminID: String, record: Shedule) async {
        do {
            try await Client_DataBase.shared.send_RecordForAdmin(adminID: adminID, record: record)
            try await Client_DataBase.shared.setData_ClientForAdmin(adminID: adminID, clientModel: clientModel)
        } catch {
            await handleError(error: error)
        }
    }
    
    func send_SheduleForMaster(masterID: String, record: Shedule) async {
        do {
            try await Client_DataBase.shared.send_RecordForMaster(masterID: masterID, record: record)
        } catch {
            await handleError(error: error)
        }
    }
    
    func save_UserProfile() async {
        let adminID = adminProfile.adminID
        do {
            try await Client_DataBase.shared.setData_ClientFireBase(clientModel: clientModel)
            try await Client_DataBase.shared.setData_ClientForAdmin(adminID: adminID, clientModel: clientModel)
        } catch {
            await handleError(error: error)
        }
    }
    @MainActor
    private func handleError(error: Error) async {
        isAlert = true
        errorMassage = error.localizedDescription
        print("Error in task: \(error.localizedDescription)")
    }
}
