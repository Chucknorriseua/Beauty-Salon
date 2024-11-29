//
//  CalendarViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import FirebaseCore

final class Admin_CalendarViewModel: ObservableObject {
    
    static let shared = Admin_CalendarViewModel()
     
    @Published var currentDate: Date = Date()
    @Published var currentWeekIndex: Int = 1
    @Published var weekSlider: [[Date.WeekDay]] = []
    @Published var isPresentedNewTask: Bool = false
    @Published var createWeek: Bool = false
    @Published var productTask: [Shedule] = []
    @Published var shedules: Shedule
    
    private init(shedules: Shedule? = nil) {
        self.shedules = shedules ?? Shedule.sheduleModel()
    }
    
    @MainActor
    func fetchAllSheduleCurrentMaster(masterID: String, sheduleMaster: Shedule) async {
        do {
            try await Admin_DataBase.shared.removeYesterdaysSchedule(masterID: masterID)
            let shedule = try await Admin_DataBase.shared.fetchShedule_CurrentMaster(masterID: masterID)
            let sortedDate = shedule.sorted(by: {$0.creationDate < $1.creationDate})
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.productTask = sortedDate
            }
        } catch {
            print("DEBUG: ERROR--fetchAllSheduleCurrentMaster" , error.localizedDescription)
        }
    }
    
    @MainActor
    func addTaskShedule(masterID: String, addTask: Shedule) async {
        do {
            try await Admin_DataBase.shared.send_ShedulesTo_Master(idMaster: masterID, shedule: addTask)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.productTask.append(addTask)
            }
        } catch {
            print("DEBUG: ERROR--addTaskShedule" , error.localizedDescription)
        }
    }
    
    @MainActor
    func removeSheduleCurrentMaster(shedule: Shedule, clientID: String) async {
        if let index = productTask.firstIndex(where: {$0.id == shedule.id}) {
            self.productTask.remove(at: index)
        }
        do {
            try await Admin_DataBase.shared.remove_MasterShedule(shedule: shedule, clientID: clientID)
        } catch {
            print("DEBUG: Error deleteRecord...", error.localizedDescription)
        }
    }
    
    func getTask(masterID: String, date: Date) -> [Shedule] {
        return productTask.filter({$0.masterId == masterID && Calendar.current.isDate($0.creationDate, inSameDayAs: date)})
        }
    
    func setupWeeks() {
        if weekSlider.isEmpty {
            let currentWeek = Date().FetchWeek()
            if let firstDay = currentWeek.first?.date {
                weekSlider.append(firstDay.createPreviousWeek())
            }
            weekSlider.append(currentWeek)
            if let lastWeek = currentWeek.last?.date {
                weekSlider.append(lastWeek.createNextWeek())
            }
        }
    }
    
    func paginationWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
    
    
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
