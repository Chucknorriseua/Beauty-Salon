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
    
    @Published private(set) var company: [Company_Model] = []
    @Published private(set) var salonFavorites: [Company_Model] = []
    @Published var createProcedure: [Procedure] = []
    @Published var sheduleFromClient: [Shedule] = []
    @Published var sheduleStatic: [Shedule] = []
    @Published private(set) var client: [Client] = []
    @Published var totalCost: Double = 0.0
    
    @Published  var isAlert: Bool = false
    @Published  var errorMassage: String = ""
    
    @Published var admin: Company_Model
    @Published var masterModel: MasterModel
    @Published var sheduleModel: Shedule
    @Published var selectedMonth: MonthStatistics = MonthStatistics.currentMonth
    
    var auth = Auth.auth()
    
  private init(sheduleModel: Shedule? = nil, admin: Company_Model? = nil, masterModel: MasterModel? = nil) {
        self.sheduleModel = sheduleModel ?? Shedule.sheduleModel()
        self.admin = admin ?? Company_Model.companyModel()
        self.masterModel = masterModel ?? MasterModel.masterModel()
        Task {
            await getCompany()
        }
    }
    
    
    var recordsForSelectedMonth: [Shedule] {
        filterRecordsByMonth(sheduleStatic, selectedMonth)
    }
    
    
    var monthlyRecords: Int {
        AnalyticsCalculator.getMonthlyRecords(schedules: recordsForSelectedMonth)
    }
    
    var biweeklyRecords: Int {
        AnalyticsCalculator.getBiweeklyRecords(schedules: recordsForSelectedMonth)
    }
    
    var popularProcedures: [String: Int] {
        AnalyticsCalculator.getPopularProcedures(schedules: recordsForSelectedMonth)
    }
    var uniqueClients: Int {
        AnalyticsCalculator.getUniqueClients(schedules: client)
    }
    
    var totalCostProcedure: Double {
        AnalyticsCalculator.getTotalCostProcedure(schedules: recordsForSelectedMonth)
    }
    
    private func filterRecordsByMonth(_ schedules: [Shedule], _ month: MonthStatistics) -> [Shedule] {
        let calendar = Calendar.current
        return schedules.filter { schedule in
            let components = calendar.dateComponents([.month], from: schedule.creationDate)
            return components.month == month.monthNumber
        }
    }
    
// MARK: Procedure
    @MainActor
    func addNewProcedureFirebase(addProcedure: Procedure) async {
        do {
            _ = try await Master_DataBase.shared.addProcedure(procedure: addProcedure)
            await MainActor.run { [weak self] in
                guard let self else { return }
                if !createProcedure.contains(where: {$0.id == addProcedure.id}) {
                    self.createProcedure.append(addProcedure)
                }
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    func deleteCreateProcedure(procedureID: Procedure) async {
        if let index = createProcedure.firstIndex(where: {$0.id == procedureID.id}) {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.createProcedure.remove(at: index)
            }
        }
        do {
            try await Master_DataBase.shared.removeProcedureFireBase(procedureID: procedureID.id)
        } catch {
            await handleError(error: error)
        }
    }
//___________________________________________________________________________________________________
    
    
    func deleteShedule(sheduleID: Shedule) async {
        if let index = sheduleFromClient.firstIndex(where: {$0.id == sheduleID.id}) {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.sheduleFromClient.remove(at: index)
            }
        }
        do {
            try await Master_DataBase.shared.remove_SheduleFromClient(sheduleID: sheduleID.id)
        } catch {
            await handleError(error: error)
        }
    }
    
    func addSheduleInMyStatic(sheduleID: Shedule) async {
        do {
            try await Master_DataBase.shared.setSheduleInStatic(sheduleID: sheduleID.id, shedule: sheduleID)
        } catch {
            await handleError(error: error)
        }
    }
    
    //  MARK: Get All comapny
    func getCompany() async {
        do {
            
            let fetchAllCompany = try await Master_DataBase.shared.fetchAllCompany()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.company = fetchAllCompany
            }
            await fetchProfile_Master()
   
        } catch {
            print("error getCompany", error.localizedDescription)
//            await handleError(error: error)
        }
    }
    
    func fetchClientFromHomeOrAway() async {
        do {
            let client = try await Master_DataBase.shared.fetch_CurrentClient_FromMaster()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.client = client
            }
            await fetchSheduleForStatic()
        } catch {
            print("error getCompany", error.localizedDescription)
//            await handleError(error: error)
        }
    }
    
    func fetchSheduleFromClient() async {
        do {
            let shedule = try await Master_DataBase.shared.fetchSheduleFromClinet()
            let sortedDate = shedule.sorted(by: {$0.creationDate < $1.creationDate})
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.sheduleFromClient = sortedDate
                print("Shedule:", shedule)
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    func fetchSheduleForStatic() async {
        do {
            let shedule = try await Master_DataBase.shared.fetchSheduleForStatic()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.sheduleStatic = shedule
                print("Shedule:", shedule)
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    @MainActor
    func addMyFavoritesSalon(salon: Company_Model) async {
        do {
            try await Master_DataBase.shared.addFavoritesSalon(salonID: salon.adminID, salon: salon)
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
    
    @MainActor
    func removeFavoritesSalon(salon: Company_Model) async {
        do {
            if let index = self.salonFavorites.firstIndex(where: { $0.id == salon.id }) {
                try await Master_DataBase.shared.remove_FavoritesSalon(salonID: salon.id)
                self.salonFavorites.remove(at: index)
            }
        } catch {
            await handleError(error: error)
        }
    }
    
    func fetchFavoritesSalon() async {
        do {
          let salon = try await Master_DataBase.shared.fetchFavorites_Salon()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.salonFavorites = salon
            }
        } catch {
            print("error fetchFavoritesSalon", error.localizedDescription)
            await handleError(error: error)
        }
    }

    //  MARK: Fetch profile master
   func fetchProfile_Master() async {
        do {
            let master = try await Master_DataBase.shared.fecth_Data_Master_FB()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.masterModel = master
                self.createProcedure = masterModel.procedure
                print("MASTER:", master)
            }
        } catch {
//            await handleError(error: error)
            print("Error fetch master data")
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
    
    func updateRecordsFromClient(record: Shedule, clientID: String) async {
        do {
            try await Master_DataBase.shared.changeRecordFromClient(record: record, id: record.id)
            try await Master_DataBase.shared.saveChangeSendClient(clientID: clientID, record: record)
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
    @MainActor
    private func handleError(error: Error) async {
        isAlert = true
        errorMassage = error.localizedDescription
        print("Error in task: \(error.localizedDescription)")
    }
}
