//
//  Date+ext.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

// use in array weekSlider: [[Date.WeekDay]] = []
extension Date {
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func FetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weelForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startWeek = weelForDate?.start else { return []}
        
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startWeek) {
                week.append(.init(date: weekDay))
            }
        }
        return week
    }
    
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLasrDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLasrDate) else { return []}
        
        return FetchWeek(nextDate)
    }
    
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLasrDate = calendar.startOfDay(for: self)
        guard let previoustDate = calendar.date(byAdding: .day, value: -1, to: startOfLasrDate) else { return []}
        
        return FetchWeek(previoustDate)
    }
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
}
