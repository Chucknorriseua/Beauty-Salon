//
//  MasterCalendarViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 18/09/2024.
//

import SwiftUI
import FirebaseFirestore

final class MasterCalendarViewModel: ObservableObject {
    
    static let shared = MasterCalendarViewModel()
     
    @Published var currentDate: Date = Date()
    @Published var currentWeekIndex: Int = 1
    @Published var weekSlider: [[Date.WeekDay]] = []
    @Published var isPresentedNewTask: Bool = false
    @Published var createWeek: Bool = false
    @Published private(set) var productTask: [Shedule] = [] 
    

    @Published var company: Company_Model
    @Published var shedule: Shedule
    
    private init(shedule: Shedule? = nil, company: Company_Model? = nil) {
        self.shedule = shedule ?? Shedule.sheduleModel()
        self.company = company ?? Company_Model.companyModel()
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
    
    func getMasterShedule(date: Date) -> [Shedule] {
        return productTask.filter({Calendar.current.isDate($0.creationDate, inSameDayAs: date)})
    }
    
    func getSheduleMaster() async {
        let adminID = company.adminID
        do {
            let shedule = try await Master_DataBase.shared.fetch_Shedule_ForMaster(adminId: adminID)
            let sortedDate =  shedule.sorted(by: {$0.creationDate < $1.creationDate})
            await MainActor.run { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.productTask = sortedDate
            }
        } catch {
            print("DEBUG: ERROR getSheduleMaster....", error.localizedDescription)
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
