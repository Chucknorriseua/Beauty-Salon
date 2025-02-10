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
    
    
    @Published private(set) var comapny: [Company_Model] = []
    @Published private(set) var mastersInRoom: [MasterModel] = []
    @Published private(set) var homeCall: [MasterModel] = []
    @Published var procedure: [Procedure] = []
    
    @Published var isAlert: Bool = false
    @Published var errorMassage: String = ""
    @Published var totalCost: Double = 0.0
    
    @Published var adminProfile: Company_Model
    @Published var clientModel: Client
    
    @Published var currentDate: Date = Date()
    
  private init(adminProfile: Company_Model? = nil, clientModel: Client? = nil) {
        self.adminProfile = adminProfile ?? Company_Model.companyModel()
        self.clientModel = clientModel ?? Client.clientModel()
        Task {
            await fetchAll_Comapny()
        }
    }
    
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
        } catch {
            await handleError(error: error)
        }
    }
    
   private func fetchAllMasters_FromAdmin() async {
        let adminId = adminProfile.adminID
        do {
            let masters = try await Client_DataBase.shared.getAllMastersFrom_AdminRoom(adminId: adminId)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.mastersInRoom = masters
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
