//
//  AdminViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 20/08/2024.
//

import SwiftUI


final class AdminViewModel: ObservableObject {
    
    static let shared = AdminViewModel()
    
    @Published private(set) var allMasters: [MasterModel] = []
    @Published private(set) var recordsClient: [Shedule] = []
    @Published private(set) var recordsSaveClient: [Shedule] = []
    @Published private(set) var chartsMonthlyInfo: [Shedule] = []
    @Published private(set) var addMasterInRoom: [MasterModel] = []
    @Published private(set) var client: [Client] = []
    @Published private(set) var createProcedure: [Procedure] = []
    @Published var procedure: [Procedure] = []
    @Published var createHomeCare: [Procedure] = []
    
    
    @Published var isAlert: Bool = false
    @Published var errorMassage: String = ""
    @Published var totalCost: Double = 0.0
    @Published var selectedMonth: MonthStatistics = MonthStatistics.currentMonth
    
    @Published var adminProfile: Company_Model
    @Published private var masterModel: MasterModel
    @Published private var shedule: Shedule
    
    
    private init(adminProfile: Company_Model? = nil, masterModel: MasterModel? = nil, shedule: Shedule? = nil) {
        self.adminProfile = adminProfile ?? Company_Model.companyModel()
        self.masterModel = masterModel ?? MasterModel.masterModel()
        self.shedule = shedule ?? Shedule.sheduleModel()
        Task {
            await fetchProfileAdmin()
        }
    }
    
    
    var recordsForSelectedMonth: [Shedule] {
        filterRecordsByMonth(recordsSaveClient, selectedMonth)
    }
    
    var monthlyRecords: Int {
        AnalyticsCalculator.getMonthlyRecords(schedules: recordsForSelectedMonth)
    }
    
    var biweeklyRecords: Int {
        AnalyticsCalculator.getBiweeklyRecords(schedules: recordsForSelectedMonth)
    }
    
    var uniqueClients: Int {
        AnalyticsCalculator.getUniqueClients(schedules: client)
    }
    
    var popularMasters: [String: Int] {
        AnalyticsCalculator.getPopularMasters(schedules: recordsForSelectedMonth)
    }
    
    var popularProcedures: [String: Int] {
        AnalyticsCalculator.getPopularProcedures(schedules: recordsForSelectedMonth)
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
    
    private func removeAllInfoChartsOfMonthly(info: Shedule) async {
        
    }
    //  MARK: Fetch profile admin
    func fetchProfileAdmin() async {
        do {
            let profile = try await Admin_DataBase.shared.fetchAdmiProfile()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.adminProfile = profile
                self.procedure = adminProfile.procedure
                self.createProcedure = adminProfile.procedure
            }
            await fethAllData()
            
        } catch {
            await handleError(error: error, wheare: "fetch my profile")
        }
        
    }
    
    // MARK: HomeCare
    @MainActor
    func addNewHomeCareFirebase(addProcedure: Procedure) async {
        do {
            _ = try await Admin_DataBase.shared.addHomeCare(procedure: addProcedure)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.createHomeCare.append(addProcedure)
            }
        } catch {
            await handleError(error: error, wheare: "addNewHomeCareFirebase")
        }
    }
    
    func deleteCreateHomeCare(procedureID: Procedure) async {
        if let index = createHomeCare.firstIndex(where: {$0.id == procedureID.id}) {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.createHomeCare.remove(at: index)
            }
        }
        do {
            try await Admin_DataBase.shared.remove_HomeCare(id: procedureID.id)
        } catch {
            await handleError(error: error, wheare: "deleteCreateHomeCare")
        }
    }
    
    func fetchHomeCareProduct() async {
        do {
            let homeCare = try await Admin_DataBase.shared.fetchHomeCareProduct()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.createHomeCare = homeCare
            }
        } catch {
            await handleError(error: error, wheare: "fetch client")
        }
    }
    //___________________________________________________________________________________________________
    
    //  MARK: Fetch profile admin
    func refreshProfileAdmin() async {
        do {
            let profile = try await Admin_DataBase.shared.fetchAdmiProfile()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.adminProfile = profile
                self.procedure = adminProfile.procedure
                self.createProcedure = adminProfile.procedure
            }
        } catch {
            await handleError(error: error, wheare: "fetch my profile")
        }
        
    }
    
    private func fethAllData() async {
        await withTaskGroup(of: Void.self) { [weak self] group in
            guard let self else { return }
            
            group.addTask { await self.get_AllAdded_Masters_InRomm() }
            //            group.addTask { await Admin_DataBase.shared.removeOldClients() }
            group.addTask { await self.fetchClientRecords() }
            group.addTask { await self.fetchCurrentClient() }
            
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
            await handleError(error: error, wheare: "add master")
        }
    }
    
    @MainActor
    func addNewProcedure(addProcedure: Procedure) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            if !procedure.contains(where: {$0.id == addProcedure.id}) {
                self.procedure.append(addProcedure)
                
            }
        }
    }
    
    @MainActor
    func addNewProcedureFirebase(addProcedure: Procedure) async {
        do {
            _ = try await Admin_DataBase.shared.addProcedure(procedure: addProcedure)
            await MainActor.run { [weak self] in
                guard let self else { return }
                if !procedure.contains(where: {$0.id == addProcedure.id}) {
                    self.createProcedure.append(addProcedure)
                }
            }
        } catch {
            await handleError(error: error, wheare: "add new procedure")
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
            await handleError(error: error, wheare: "fetch client")
        }
    }
    
    //  MARK: Set save new profile master
    func setNew_Admin_Profile() async {
        
        do {
            try await Admin_DataBase.shared.setCompanyForAdmin(admin: adminProfile)
        } catch {
            await handleError(error: error, wheare: "save new profile")
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
            await handleError(error: error, wheare: "fetch all masters")
        }
        
    }
    
    func fetch_RecordsMonthly() async {
        do {
            let records = try await Admin_DataBase.shared.fetch_RecordsMonthly()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.recordsSaveClient = records
            }
        } catch {
            await handleError(error: error, wheare: "fetch all masters")
        }
        
    }
    
    //  MARK: Fetch all profile master in to rooms
    func get_AllAdded_Masters_InRomm() async {
        do {
            
            let master = try await Admin_DataBase.shared.getAll_Added_Masters()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.addMasterInRoom = master
            }
        } catch {
            await handleError(error: error, wheare: "get all add masters")
        }
        
    }
    
    func sendCurrentMasterRecord(masterID: String, shedule: Shedule) async {
        do {
            try await Admin_DataBase.shared.send_ShedulesTo_Master(idMaster: masterID, shedule: shedule)
            await deleteRecord(record: shedule)
        } catch {
            await handleError(error: error, wheare: "send record master")
        }
    }
    
    
    func updateRecordsFromClient(record: Shedule, clientID: String) async {
        do {
            try await Admin_DataBase.shared.changeRecordFromClient(record: record, id: record.id)
            try await Admin_DataBase.shared.saveChangeSendClient(clientID: clientID, record: record)

        } catch {
            await handleError(error: error, wheare: "update record client")
        }
    }
    
    
    func fetchClientRecords() async {
        do {
            let records = try await Admin_DataBase.shared.fetch_ClientRecords()
            let sortedDate = records.sorted(by: {$0.creationDate < $1.creationDate})
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.recordsClient = sortedDate
                self.recordsSaveClient = records
            }
        } catch {
            await handleError(error: error, wheare: "get client records")
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
            await handleError(error: error, wheare: "delete record")
        }
    }
    
    func deleteProcedure(procedureID: Procedure) async {
        if let index = procedure.firstIndex(where: {$0.id == procedureID.id}) {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.procedure.remove(at: index)
            }
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
            try await Admin_DataBase.shared.removeProcedureFireBase(procedureID: procedureID.id)
        } catch {
            await handleError(error: error, wheare: "delete product")
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
            await handleError(error: error, wheare: "delete")
        }
    }
    
    @MainActor
    func removeProcedure(selectedProcedure: [Procedure]) {
        for procedure in selectedProcedure {
            if let index = self.procedure.firstIndex(where: { $0.id == procedure.id }) {
                self.procedure.remove(at: index)
            }
        }
    }
    
    @MainActor
    func clearMemory() {
        allMasters.removeAll()
    }
    
    @MainActor
    private func handleError(error: Error, wheare: String) async {
        isAlert = true
        errorMassage = "\(error.localizedDescription), \(wheare)"
        print("Error in task: \(error.localizedDescription)")
    }
    
}

extension MonthStatistics {
    var monthNumber: Int {
        switch self {
        case .january: return 1
        case .february: return 2
        case .march: return 3
        case .april: return 4
        case .may: return 5
        case .june: return 6
        case .july: return 7
        case .august: return 8
        case .september: return 9
        case .october: return 10
        case .november: return 11
        case .december: return 12
        }
    }
}

extension MonthStatistics {
    static var currentMonth: MonthStatistics {
        let currentMonthNumber = Calendar.current.component(.month, from: Date())
        return MonthStatistics.allCases.first { $0.monthNumber == currentMonthNumber } ?? .january
    }
}
